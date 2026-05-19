import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../models/user_preferences.dart';
import 'api_client.dart';
import 'token_manager.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiClient _apiClient = ApiClient();
  final TokenManager _tokenManager = TokenManager();
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  final _userController = StreamController<UserModel?>.broadcast();
  UserModel? _currentUser;
  bool _isSocialLoginInProgress = false;

  UserModel? get currentUser => _currentUser;

  Stream<UserModel?> get userStream async* {
    yield _currentUser;
    yield* _userController.stream;
  }

  User? get currentFirebaseUser => _auth.currentUser;

  AuthService._internal() {
    _init();
    _apiClient.onUnauthorized = () => logout();
  }

  void _init() {
    // Inicializa o Google Sign In silenciosamente para preparar o SDK
    unawaited(_googleSignIn.initialize());

    // Ouve mudanças no estado do Firebase (Login/Logout/Restart do App)
    _auth.authStateChanges().listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        debugPrint("Firebase Auth State: Logado (${firebaseUser.email})");

        // Se estivermos em um login social manual, deixamos que o fluxo de login
        // cuide da sincronização após o handshake de tokens.
        if (_isSocialLoginInProgress) {
          debugPrint("Sync automático ignorado: Login social em andamento...");
          return;
        }

        // Se o usuário atual for null ou o UID mudou, precisamos sincronizar
        // Mas se o usuário atual já for o correto e tiver um ID de banco real,
        // podemos evitar a chamada de rede se não houver mudança de perfil.
        if (_currentUser == null || _currentUser!.firebaseUid != firebaseUser.uid) {
           await _syncUserWithApi(firebaseUser);
        }
      } else {
        debugPrint("Firebase Auth State: Deslogado");
        _currentUser = null;
        _userController.add(null);
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('user_session');
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
        _currentUser = UserModel.fromMap(data);
        _userController.add(_currentUser);
      }
    } catch (e) {
      debugPrint("Erro ao carregar sessão: $e");
    }
  }

  Future<void> refreshUser() async {
    if (_currentUser == null) return;

    try {
      final response = await _apiClient.fetchUser(_currentUser!.id);
      final userData = response['user'] ?? response['data'] ?? response;
      if (userData is Map && userData.isNotEmpty) {
        _currentUser = UserModel.fromMap(userData as Map<String, dynamic>);
        _userController.add(_currentUser);
        await _saveSession(_currentUser!);
      }
    } catch (e) {
      debugPrint("Erro ao dar refresh no usuário: $e");
      if (_auth.currentUser != null) {
        await _syncUserWithApi(_auth.currentUser);
      }
    }
  }

  Future<void> _saveSession(UserModel user) async {
    try {
      if (user.hasValidDatabaseId) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_session', jsonEncode(user.toMap()));
      }
    } catch (e) {
      debugPrint("Erro ao salvar sessão: $e");
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    final response = await _apiClient.signIn(email: email, password: password);
    
    // Salva o token para as próximas requisições
    final String? apiToken = response['data']?['token'] ?? response['token'];
    if (apiToken != null) {
      await _tokenManager.saveToken(apiToken);
      debugPrint("✅ JWT de E-mail salvo.");
    }

    final userData = response['data']?['user'] ?? response['user'] ?? response;
    final user = UserModel.fromMap(userData);

    // Garante que o email não seja perdido se o backend não retornar
    _currentUser = (user.email.isEmpty || user.email == "null")
        ? user.copyWith(email: email)
        : user;

    _userController.add(_currentUser);
    await _saveSession(_currentUser!);
  }

  Future<void> registerWithEmail({
    required String email,
    required String password,
    String? name,
    String? phone
  }) async {
    final response = await _apiClient.signUp(
      email: email,
      password: password,
      name: name,
      phone: phone
    );
    
    // Salva o token para as próximas requisições
    final String? apiToken = response['data']?['token'] ?? response['token'];
    if (apiToken != null) {
      await _tokenManager.saveToken(apiToken);
      debugPrint("✅ JWT de Registro salvo.");
    }

    final userData = response['data']?['user'] ?? response['user'] ?? response;
    final user = UserModel.fromMap(userData);

    // Garante que o email não seja perdido se o backend não retornar
    _currentUser = (user.email.isEmpty || user.email == "null")
        ? user.copyWith(email: email)
        : user;

    _userController.add(_currentUser);
    await _saveSession(_currentUser!);
  }

  Future<bool> loginWithGoogle() async {
    _isSocialLoginInProgress = true;
    try {
      debugPrint("Iniciando Google Sign-In...");
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();

      if (googleUser == null) {
        debugPrint("Google Sign-In cancelado pelo usuário.");
        _isSocialLoginInProgress = false;
        return false;
      }

      final auth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: auth.idToken
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        await _firebaseLoginWithApi(firebaseUser);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("❌ Erro no login com Google: $e");
      _isSocialLoginInProgress = false;
      rethrow;
    } finally {
      // Mantemos o flag por mais um tempo para garantir que eventos residuais do Firebase
      // não disparem o sync automático antes do fim da transição.
      Future.delayed(const Duration(seconds: 2), () => _isSocialLoginInProgress = false);
    }
  }

  Future<void> _firebaseLoginWithApi(User user) async {
    debugPrint("Trocando token Firebase por token do Backend...");
    final idToken = await user.getIdToken();
    if (idToken == null) throw 'Falha ao obter ID Token do Firebase';

    try {
      // 1. Obtém o Token JWT do Backend (HS256)
      final response = await _apiClient.firebaseAuth(idToken);
      final String? apiToken = response['data']?['token'] ?? response['token'];

      if (apiToken != null) {
        await _tokenManager.saveToken(apiToken);
        debugPrint("✅ JWT do Backend salvo.");
      }

      // 2. Sincroniza o perfil (Upsert) enviando o Firebase Token como prova de identidade
      await _syncUserWithApi(user);
      
    } catch (e) {
      debugPrint("❌ Falha na integração com a API: $e");
      rethrow;
    }
  }

  Future<void> _syncUserWithApi(User? firebaseUser) async {
    if (firebaseUser == null) return;

    final idToken = await firebaseUser.getIdToken();

    try {
      final userModel = _mapFirebaseUser(firebaseUser);
      if (userModel == null) return;
      final response = await _apiClient.syncProfile(
          userModel,
          firebaseToken: idToken
      );

      final userData = response['data']?['user'] ?? response['user'] ?? response['data'];

      if (userData is Map) {
        _currentUser = UserModel.fromMap(userData.cast<String, dynamic>());
        _userController.add(_currentUser);
        await _saveSession(_currentUser!);
        debugPrint("🚀 Perfil sincronizado com o Backend. UUID: ${_currentUser!.id}");
      }
    } catch (e) {
      debugPrint("⚠️ Erro na sincronização com API: $e");

      await Future.delayed(const Duration(milliseconds: 2500));

      if (_currentUser == null) {
         _currentUser = _mapFirebaseUser(firebaseUser);
         _userController.add(_currentUser);
      }
    }
  }

  Future<void> logout() async {
    debugPrint("Iniciando processo de logout...");
    try {
      await _auth.signOut().catchError((e) => debugPrint("Firebase signOut: $e"));
      await _googleSignIn.signOut().catchError((e) => debugPrint("Google signOut: $e"));
      await _tokenManager.deleteToken();
    } catch (e) {
      debugPrint("Aviso ao deslogar serviços: $e");
    }

    _currentUser = null;
    _userController.add(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_session');
    debugPrint("Logout local concluído.");
  }

  Future<void> updateUserProfile({
    String? name,
    String? profileType,
    String? preferredColor,
    List<String>? neurodivergencies,
  }) async {
    if (_currentUser == null) return;

    String email = _currentUser!.email;
    if ((email.isEmpty || email == "null") && _auth.currentUser?.email != null) {
      email = _auth.currentUser!.email!;
    }

    final updatedPreferences = _currentUser!.preferences.copyWith(
      profileType: profileType ?? _currentUser!.preferences.profileType,
      preferredColor: preferredColor ?? _currentUser!.preferences.preferredColor,
      neurodivergencies: neurodivergencies ?? _currentUser!.preferences.neurodivergencies,
    );

    final updatedUser = _currentUser!.copyWith(
      name: name ?? _currentUser!.name,
      email: email,
      preferences: updatedPreferences,
    );

    // Se ainda não temos UUID, usamos o syncProfile (Upsert)
    if (!updatedUser.hasValidDatabaseId) {
      final idToken = await _auth.currentUser?.getIdToken();
      await _apiClient.syncProfile(
          updatedUser,
          firebaseToken: idToken
      );
      await refreshUser();
      return;
    }

    final updatedData = {
      'name': name ?? _currentUser!.name,
      'email': email,
      'preferences': updatedPreferences.toMap(),
      'profile_type': profileType ?? updatedPreferences.profileType,
      'preferred_color': preferredColor ?? updatedPreferences.preferredColor,
      'neurodivergencies': neurodivergencies ?? updatedPreferences.neurodivergencies,
    };

    try {
      final response = await _apiClient.updateUser(_currentUser!.id, updatedData);
      final userData = response['user'] ?? response['data'] ?? response;

      if (userData is Map && userData.isNotEmpty) {
        _currentUser = UserModel.fromMap(userData as Map<String, dynamic>);
        _userController.add(_currentUser);
        await _saveSession(_currentUser!);
      }
    } catch (e) {
      debugPrint("❌ Erro ao atualizar perfil: $e");
      rethrow;
    }
  }

  UserModel? _mapFirebaseUser(User? user) {
    if (user == null) return null;
    return UserModel(
      id: user.uid,
      firebaseUid: user.uid,
      email: user.email ?? '',
      name: user.displayName,
      phone: user.phoneNumber,
      photoUrl: user.photoURL,
      preferences: UserPreferences(userId: user.uid),
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      updatedAt: user.metadata.lastSignInTime ?? DateTime.now(),
    );
  }
}
