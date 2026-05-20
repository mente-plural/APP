import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';
import '../../models/user_preferences.dart';
import '../token_manager.dart';
import '../user/user_client.dart';
import '../user/user_service.dart';
import 'auth_client.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthClient _authClient = AuthClient();
  final UserClient _userClient = UserClient();
  final TokenManager _tokenManager = TokenManager();
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  final _userController = StreamController<UserModel?>.broadcast();
  UserModel? _currentUser;
  bool _isSocialLoginInProgress = false;

  UserModel? get currentUser => _currentUser;

  // 💡 Stream que garante que o novo ouvinte receba o valor atual IMEDIATAMENTE.
  // Isso resolve o problema de o AuthGate perder o evento de login.
  Stream<UserModel?> get userStream async* {
    yield _currentUser; // Emite o estado atual logo de cara
    yield* _userController.stream; // Depois ouve as mudanças futuras
  }

  User? get currentFirebaseUser => _auth.currentUser;

  AuthService._internal() {
    _init();
    _authClient.onUnauthorized = () => logout();
    _userClient.onUnauthorized = () => logout();
  }

  void _init() {
    unawaited(_googleSignIn.initialize());

    _auth.authStateChanges().listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        if (_isSocialLoginInProgress) return;
        // Se temos um usuário local e ele já bate com o do Firebase, não sincronizamos de novo
        if (_currentUser != null && _currentUser!.firebaseUid == firebaseUser.uid) {
          return;
        }
        await _syncUserWithApi(firebaseUser);
      } else {
        // Se o Firebase está nulo, mas temos um usuário logado via e-mail (sem firebaseUid),
        // NÃO limpamos a sessão.
        final bool isSocialUser = _currentUser?.firebaseUid != null && 
                                 _currentUser!.firebaseUid!.isNotEmpty;

        if (_currentUser != null && isSocialUser) {
          debugPrint("AuthService: Usuário social deslogado do Firebase. Limpando sessão.");
          _currentUser = null;
          _userController.add(null);
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('user_session');
        }
      }
    });

    _loadSession();
  }

  Future<void> loginWithEmail(String email, String password) async {
    final response = await _authClient.signIn(email: email, password: password);

    final String? apiToken = response['data']?['token'] ?? response['token'];
    if (apiToken != null) await _tokenManager.saveToken(apiToken);

    final dynamic userData = response['data']?['user'] ?? response['data'] ?? response['user'];
    if (userData == null) {
      throw Exception("Payload de usuário ausente na resposta da API.");
    }

    debugPrint("AuthService: userData recebido no login: $userData");
    final user = UserModel.fromMap(userData as Map<String, dynamic>);

    _currentUser = (user.email.isEmpty || user.email == "null")
        ? user.copyWith(email: email)
        : user;

    debugPrint("AuthService: _currentUser setado para ID: ${_currentUser?.id}, Email: ${_currentUser?.email}");

    // Primeiro salvamos a sessão
    await _saveSession(_currentUser!);
    
    // Notificamos os ouvintes (StreamBuilder)
    _userController.add(_currentUser);
    
    debugPrint("AuthService: Login E-mail concluído para ${_currentUser?.id}");
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
      final response = await _userClient.fetchUser(_currentUser!.id);
      final userData = response['user'] ?? response['data'] ?? response;
      if (userData is Map && userData.isNotEmpty) {
        _currentUser = UserModel.fromMap(userData as Map<String, dynamic>);
        _userController.add(_currentUser);
        await _saveSession(_currentUser!);
      }
    } catch (e) {
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


  Future<void> registerWithEmail({
    required String email,
    required String password,
    String? name,
    String? phone
  }) async {
    final response = await _authClient.signUp(
      email: email,
      password: password,
      name: name,
      phone: phone
    );
    
    final String? apiToken = response['data']?['token'] ?? response['token'];
    if (apiToken != null) await _tokenManager.saveToken(apiToken);

    final userData = response['data']?['user'] ?? response['data'] ?? response['user'] ?? response;
    final user = UserModel.fromMap(userData);

    _currentUser = (user.email.isEmpty || user.email == "null")
        ? user.copyWith(email: email)
        : user;

    _userController.add(_currentUser);
    await _saveSession(_currentUser!);
  }

  Future<bool> loginWithGoogle() async {
    _isSocialLoginInProgress = true;
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) {
        _isSocialLoginInProgress = false;
        return false;
      }

      final auth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(idToken: auth.idToken);
      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        await _firebaseLoginWithApi(firebaseUser);
        return true;
      }
      return false;
    } catch (e) {
      _isSocialLoginInProgress = false;
      rethrow;
    } finally {
      Future.delayed(const Duration(seconds: 2), () => _isSocialLoginInProgress = false);
    }
  }

  Future<void> _firebaseLoginWithApi(User user) async {
    final idToken = await user.getIdToken();
    if (idToken == null) throw 'Falha ao obter ID Token do Firebase';

    try {
      final response = await _authClient.firebaseAuth(idToken);
      final String? apiToken = response['data']?['token'] ?? response['token'];
      if (apiToken != null) await _tokenManager.saveToken(apiToken);
      await _syncUserWithApi(user);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _syncUserWithApi(User? firebaseUser) async {
    if (firebaseUser == null) return;
    final idToken = await firebaseUser.getIdToken();

    try {
      final userModel = _mapFirebaseUser(firebaseUser);
      if (userModel == null) return;
      final response = await _userClient.syncProfile(userModel, firebaseToken: idToken);
      final userData = response['data']?['user'] ?? response['data'] ?? response['user'] ?? response;

      if (userData is Map && userData.isNotEmpty) {
        _currentUser = UserModel.fromMap(userData.cast<String, dynamic>());
        _userController.add(_currentUser);
        await _saveSession(_currentUser!);
      }
    } catch (e) {
      if (_currentUser == null) {
         _currentUser = _mapFirebaseUser(firebaseUser);
         _userController.add(_currentUser);
      }
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      await _tokenManager.deleteToken();
    } catch (e) {
      debugPrint("Aviso ao deslogar serviços: $e");
    }

    _currentUser = null;
    _userController.add(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_session');
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authClient.forgotPassword(email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await _authClient.resetPassword(token, newPassword);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserProfile({
    String? name,
    String? phone,
    String? profileType,
    String? preferredColor,
    List<String>? neurodivergencies,
    bool? highContrast,
    double? fontSizeMultiplier,
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
      highContrast: highContrast ?? _currentUser!.preferences.highContrast,
      fontSizeMultiplier: fontSizeMultiplier ?? _currentUser!.preferences.fontSizeMultiplier,
    );

    final updatedUser = _currentUser!.copyWith(
      name: name ?? _currentUser!.name,
      phone: phone ?? _currentUser!.phone,
      email: email,
      preferences: updatedPreferences,
    );

    if (!updatedUser.hasValidDatabaseId) {
      final idToken = await _auth.currentUser?.getIdToken();
      final response = await _userClient.syncProfile(updatedUser, firebaseToken: idToken);
      final userData = response['data']?['user'] ?? response['data'] ?? response['user'] ?? response;
      
      if (userData is Map && userData.isNotEmpty) {
        _currentUser = UserModel.fromMap(userData.cast<String, dynamic>());
        _userController.add(_currentUser);
        await _saveSession(_currentUser!);
      } else {
        await refreshUser();
      }
      return;
    }

    final updatedData = {
      'name': name ?? _currentUser!.name,
      'phone': phone ?? _currentUser!.phone,
      'email': email,
      'preferences': updatedPreferences.toMap(),
    };

    try {
      final response = await _userClient.updateUser(_currentUser!.id, updatedData);
      final userData = response['user'] ?? response['data'] ?? response;

      if (userData is Map && userData.isNotEmpty) {
        _currentUser = UserModel.fromMap(userData as Map<String, dynamic>);
        _userController.add(_currentUser);
        await _saveSession(_currentUser!);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadProfilePhoto(String filePath) async {
    if (_currentUser == null) return;
    
    try {
      final response = await _userClient.uploadProfilePhoto(_currentUser!.id, filePath);
      final userData = response['user'] ?? response['data'] ?? response;

      if (userData is Map && userData.isNotEmpty) {
        _currentUser = UserModel.fromMap(userData as Map<String, dynamic>);
        _userController.add(_currentUser);
        await _saveSession(_currentUser!);
      }
    } catch (e) {
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
      // 💡 CORREÇÃO: Garanta que o modelo local espelhe o padrão do backend ('FOR_ME')
      // para que o AuthGate libere a HomePage direto no primeiro login social!
      preferences: UserPreferences(
        userId: user.uid,
        profileType: null, // ou UserProfileType.FOR_ME se for um Enum no seu Dart
        preferredColor: null,
        neurodivergencies: [],
        highContrast: false,
        fontSizeMultiplier: 1.0,
      ),
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      updatedAt: user.metadata.lastSignInTime ?? DateTime.now(),
    );
  }
}
