import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../models/user_preferences.dart';
import 'api_client.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  AuthService._internal() {
    _init();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiClient _apiClient = ApiClient();

  final _userController = StreamController<UserModel?>.broadcast();
  UserModel? _currentUser;

  Stream<UserModel?> get userStream async* {
    yield _currentUser;
    yield* _userController.stream;
  }

  User? get currentFirebaseUser => _auth.currentUser;

  void _init() {
    _auth.authStateChanges().listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        // Se já temos um usuário e o UID é o mesmo, talvez não precisemos remapear agora, 
        // mas é seguro fazer para garantir consistência inicial.
        if (_currentUser == null || _currentUser!.firebaseUid != firebaseUser.uid) {
          _currentUser = _mapFirebaseUser(firebaseUser);
          _userController.add(_currentUser);
        }
        
        // Sempre tenta sincronizar com a API para obter o perfil completo (incluindo UUID do DB)
        _syncUserWithApi(firebaseUser);
      } else {
        if (_currentUser != null) {
          _currentUser = null;
          _userController.add(null);
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('user_session');
        }
      }
    });
    _loadSession();
  }

  Future<void> _loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final session = prefs.getString('user_session');
      if (session != null) {
        final Map<String, dynamic> data = jsonDecode(session);
        final loadedUser = UserModel.fromMap(data);
        // Só carrega se não houver um usuário atual mais recente (ex: do authStateChanges)
        if (_currentUser == null || _currentUser!.firebaseUid == loadedUser.firebaseUid) {
           _currentUser = loadedUser;
           _userController.add(_currentUser);
        }
      }
    } catch (e) {
      debugPrint("Erro ao carregar sessão: $e");
    }
  }

  Future<void> refreshUser() async {
    if (_currentUser == null) return;

    // Se o ID atual não for um UUID válido, não adianta tentar o GET (o backend rejeita)
    // Em vez disso, forçamos a sincronização para obter o UUID real do banco
    if (!_currentUser!.hasValidDatabaseId) {
      debugPrint("ID atual não é UUID (${_currentUser!.id}). Sincronizando com a API...");
      if (_auth.currentUser != null) {
        await _syncUserWithApi(_auth.currentUser);
      }
      return;
    }

    try {
      final response = await _apiClient.fetchUser(_currentUser!.id);
      final userData = response['user'] ?? response;
      if (userData is Map && userData.isNotEmpty) {
        _currentUser = UserModel.fromMap(userData as Map<String, dynamic>);
        _userController.add(_currentUser);
        await _saveSession(_currentUser!);
        debugPrint("Usuário atualizado via API.");
      }
    } catch (e) {
      debugPrint("Erro ao dar refresh no usuário: $e");
      // Fallback em caso de erro na busca
      if (_auth.currentUser != null) {
        await _syncUserWithApi(_auth.currentUser);
      }
    }
  }

  Future<void> _saveSession(UserModel user) async {
    try {
      // Só salva se o ID for um UUID válido, para evitar salvar sessões com IDs temporários do Firebase
      if (user.hasValidDatabaseId) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_session', jsonEncode(user.toMap()));
      }
    } catch (e) {
      debugPrint("Erro ao salvar sessão: $e");
    }
  }

  Future<void> loginWithEmail(String email, String password,
      {String? profile}) async {
    final response = await _apiClient.signIn(
        email: email, password: password, profile: profile);
    final userData = response['user'] ?? response;
    _currentUser = UserModel.fromMap(userData);
    _userController.add(_currentUser);
    await _saveSession(_currentUser!);
  }

  Future<void> registerWithEmail({
    required String email,
    required String password,
    String? name,
    String? phone,
    String? profile,
  }) async {
    final response = await _apiClient.signUp(
      email: email,
      password: password,
      name: name,
      phone: phone,
      profile: profile,
    );
    final userData = response['user'] ?? response;
    _currentUser = UserModel.fromMap(userData);
    _userController.add(_currentUser);
    await _saveSession(_currentUser!);
  }

  Future<void> loginWithGoogle({String? profile}) async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    await _syncUserWithApi(userCredential.user, profile: profile);
  }

  Future<void> logout() async {
    debugPrint("Iniciando processo de logout...");
    try {
      await _auth.signOut().catchError((e) => debugPrint("Firebase signOut: $e"));
      await GoogleSignIn().signOut().catchError((e) => debugPrint("Google signOut: $e"));
    } catch (e) {
      debugPrint("Aviso ao deslogar serviços: $e");
    }

    _currentUser = null;
    _userController.add(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_session');
    debugPrint("Logout local concluído.");
  }

  Future<void> _syncUserWithApi(User? firebaseUser, {String? profile}) async {
    if (firebaseUser == null) return;
    final userModel = _mapFirebaseUser(firebaseUser);
    if (userModel != null) {
      try {
        final response = await _apiClient.syncProfile(
            userModel, profile: profile);
        final userData = response['user'] ?? response;
        if (userData is Map && userData.isNotEmpty) {
          _currentUser = UserModel.fromMap(userData as Map<String, dynamic>);
          _userController.add(_currentUser);
          await _saveSession(_currentUser!);
        }
      } catch (e) {
        debugPrint("Erro na sincronização social: $e");
        _userController.add(userModel);
      }
    }
  }

  Future<void> updateUserProfile({
    String? name,
    String? profileType,
    String? preferredColor,
    List<String>? neurodivergencies,
  }) async {
    if (_currentUser == null) {
      debugPrint("Erro: Tentativa de atualizar perfil sem usuário logado.");
      return;
    }

    // Tenta recuperar o e-mail do Firebase se estiver vazio no modelo atual
    String email = _currentUser!.email;
    if (email.isEmpty && _auth.currentUser?.email != null) {
      email = _auth.currentUser!.email!;
    }

    // Prepara as preferências atualizadas
    final updatedPreferences = _currentUser!.preferences.copyWith(
      profileType: profileType,
      preferredColor: preferredColor,
      neurodivergencies: neurodivergencies,
    );

    final updatedUser = _currentUser!.copyWith(
      name: name,
      email: email,
      preferences: updatedPreferences,
    );

    // Se o ID atual não for um UUID válido do banco, usamos o syncProfile.
    if (!updatedUser.hasValidDatabaseId) {
      debugPrint("ID atual não é UUID (${updatedUser.id}). Usando syncProfile para fallback.");
      debugPrint("Payload - Email: ${updatedUser.email}, Profile: ${profileType ?? updatedUser.preferences.profileType}");

      try {
        // Passamos o profileType explicitamente para garantir que o syncProfile o use no root
        final response = await _apiClient.syncProfile(
          updatedUser, 
          profile: profileType ?? updatedUser.preferences.profileType
        );
        final userData = response['user'] ?? response;
        if (userData is Map && userData.isNotEmpty) {
          _currentUser = UserModel.fromMap(userData as Map<String, dynamic>);
          _userController.add(_currentUser);
          await _saveSession(_currentUser!);
          debugPrint("Sincronização de fallback concluída com sucesso. Novo ID: ${_currentUser!.id}");
        }
        return;
      } catch (e) {
        debugPrint("Erro ao sincronizar perfil (fallback): $e");
        rethrow;
      }
    }

    // Se já temos um UUID, usamos o PATCH convencional
    final updatedData = {
      if (name != null) 'name': name,
      'preferences': updatedPreferences.toMap(),
    };

    try {
      final response = await _apiClient.updateUser(_currentUser!.id, updatedData);
      final userData = response['user'] ?? response;
      _currentUser = UserModel.fromMap(userData);
      _userController.add(_currentUser);
      await _saveSession(_currentUser!);
    } catch (e) {
      debugPrint("Erro ao atualizar perfil via PATCH: $e");
      rethrow;
    }
  }

  UserModel? _mapFirebaseUser(User? user) {
    if (user == null) return null;
    final email = user.email ?? '';
    return UserModel(
      id: user.uid,
      firebaseUid: user.uid,
      email: email,
      name: user.displayName,
      phone: user.phoneNumber,
      photoUrl: user.photoURL,
      preferences: UserPreferences(userId: user.uid),
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      updatedAt: user.metadata.lastSignInTime ?? DateTime.now(),
    );
  }
}
