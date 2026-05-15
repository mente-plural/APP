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


    unawaited(
      _googleSignIn.initialize().then((_) {

        _googleSignIn.authenticationEvents.listen((event) {
          final GoogleSignInAccount? user = switch (event) {
            GoogleSignInAuthenticationEventSignIn() => event.user,
            GoogleSignInAuthenticationEventSignOut() => null,
          };

          if (user != null && _auth.currentUser != null) {
            _syncUserWithApi(_auth.currentUser);
          }
        });


      }),
    );

    _auth.authStateChanges().listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        if (_currentUser == null || _currentUser!.firebaseUid != firebaseUser.uid) {
          _currentUser = _mapFirebaseUser(firebaseUser);
          _userController.add(_currentUser);
        }
        _syncUserWithApi(firebaseUser);
      } else {
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
        final loadedUser = UserModel.fromMap(data);

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



    if (!_currentUser!.hasValidDatabaseId) {
      debugPrint("ID atual não é UUID (${_currentUser!.id}). Sincronizando com a API...");
      if (_auth.currentUser != null) {
        await _syncUserWithApi(_auth.currentUser);
      }
      return;
    }

    try {
      final response = await _apiClient.fetchUser(_currentUser!.id);
      debugPrint("API Refresh Response: ${jsonEncode(response)}");
      
      final userData = response['user'] ?? response['data'] ?? response;
      if (userData is Map && userData.isNotEmpty) {
        _currentUser = UserModel.fromMap(userData as Map<String, dynamic>);
        _userController.add(_currentUser);
        await _saveSession(_currentUser!);
        debugPrint("Usuário atualizado via API. Nome: ${_currentUser!.name}");
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
    try {
      // 1. Autenticação com Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) return;

      // 2. Credencial para o Firebase
      final auth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(idToken: auth.idToken);

      // 3. Login no Firebase do Flutter
      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) throw 'Falha ao obter usuário do Firebase';

      // 4. Obter o ID Token (JWT do Google) para validar no SEU backend
      final String? idTokenJWT = await firebaseUser.getIdToken();

      // 5. Trocar o Token do Firebase pelo Token do SEU Backend
      if (idTokenJWT != null) {
        final backendResponse = await _apiClient.firebaseAuth(idTokenJWT);

        // Verificando onde o token está vindo na sua estrutura sendRes
        final String? apiToken = backendResponse['data']?['token'] ?? backendResponse['token'];

        if (apiToken != null) {
          await _tokenManager.saveToken(apiToken);
          debugPrint("✅ JWT do Backend salvo e pronto para uso.");
        } else {
          throw 'O Backend não retornou um token válido.';
        }
      }

      // 6. Sincronização final com os dados de neurodiversidade
      await _syncUserWithApi(firebaseUser, profile: profile);

    } catch (e) {
      debugPrint("❌ Erro crítico no Login Social: $e");
      rethrow;
    }
  }

  Future<void> _syncUserWithApi(User? firebaseUser, {String? profile}) async {
    if (firebaseUser == null) return;

    try {
      final userModel = _mapFirebaseUser(firebaseUser);
      if (userModel == null) return;

      // Agora o ApiClient já tem o Token salvo no passo anterior,
      // então o header 'Authorization' será enviado corretamente.
      final response = await _apiClient.syncProfile(userModel, profile: profile);

      final userData = response['data']?['user'] ?? response['user'] ?? response['data'];

      if (userData is Map) {
        _currentUser = UserModel.fromMap(userData.cast<String, dynamic>());
        _userController.add(_currentUser);
        await _saveSession(_currentUser!);
        debugPrint("🚀 Perfil sincronizado com sucesso.");
      }
    } catch (e) {
      debugPrint("⚠️ Erro na sincronização de perfil: $e");
    }
  }
  Future<void> logout() async {
    debugPrint("Iniciando processo de logout...");
    try {
      await _auth.signOut().catchError((e) => debugPrint("Firebase signOut: $e"));
      await _googleSignIn.signOut().catchError((e) => debugPrint("Google signOut: $e"));
      

      await TokenManager().deleteToken();
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
    if (_currentUser == null) {
      debugPrint("Erro: Tentativa de atualizar perfil sem usuário logado.");
      return;
    }

    // 1. Prioridade total para garantir o E-mail (evita erro 400 do Fastify)
    String email = _currentUser!.email;

    // Verifica se o email local está nulo ou vazio e tenta o Firebase como backup real
    if ((email.isEmpty || email == "null") && _auth.currentUser?.email != null) {
      email = _auth.currentUser!.email!;
    }

    // Se após a tentativa o email continuar vazio, abortamos para não quebrar no backend
    if (email.isEmpty || !email.contains('@')) {
      debugPrint("❌ Erro Crítico: E-mail inválido ou ausente. Abortando sincronização.");
      return;
    }

    // 2. Prepara as preferências atualizadas
    final updatedPreferences = _currentUser!.preferences.copyWith(
      profileType: profileType ?? _currentUser!.preferences.profileType,
      preferredColor: preferredColor ?? _currentUser!.preferences.preferredColor,
      neurodivergencies: neurodivergencies ?? _currentUser!.preferences.neurodivergencies,
    );

    // 3. Cria o modelo de usuário atualizado
    final updatedUser = _currentUser!.copyWith(
      name: name ?? _currentUser!.name,
      email: email, // Garante que o e-mail validado vá aqui
      preferences: updatedPreferences,
      phone: _currentUser!.phone,
      photoUrl: _currentUser?.photoUrl
    );

    // 4. Caso o usuário ainda não tenha um UUID do banco (Onboarding inicial)
    if (!updatedUser.hasValidDatabaseId) {
      debugPrint("🔄 ID atual não é UUID (${updatedUser.id}). Usando syncProfile como Upsert.");

      try {
        final response = await _apiClient.syncProfile(
            updatedUser,
            profile: profileType ?? updatedUser.preferences.profileType
        );

        final userData = response['user'] ?? response['data'] ?? response;
        if (userData is Map && userData.isNotEmpty) {
          _currentUser = UserModel.fromMap(userData as Map<String, dynamic>);
          _userController.add(_currentUser);
          await _saveSession(_currentUser!);
          debugPrint("✅ Sincronização (Upsert) concluída. ID: ${_currentUser!.id}");
        }
        return;
      } catch (e) {
        debugPrint("❌ Erro no fallback syncProfile: $e");
        rethrow;
      }
    }

    // 5. Caso já tenha UUID, faz o PATCH normal
    final updatedData = {
      'name': name ?? _currentUser!.name,
      'email': email, // O backend exige para identificar o usuário no log/token
      'preferences': updatedPreferences.toMap(),
      // Campos redundantes para o seu Schema do Fastify
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
        debugPrint("✅ Perfil atualizado via PATCH.");
      }
    } catch (e) {
      debugPrint("❌ Erro ao atualizar perfil via PATCH: $e");
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
