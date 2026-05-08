import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  AuthService._internal() {
    _init();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepository = UserRepository();

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
        _currentUser = _mapFirebaseUser(firebaseUser);
        _userController.add(_currentUser);
        _saveSession(_currentUser!);
      } else {
        final prefs = await SharedPreferences.getInstance();
        if (!prefs.containsKey('user_session')) {
          _currentUser = null;
          _userController.add(null);
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
        _currentUser = UserModel.fromMap(jsonDecode(session));
        _userController.add(_currentUser);
      }
    } catch (e) {
      debugPrint("Erro ao carregar sessão local: $e");
    }
  }

  Future<void> _saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_session', jsonEncode(user.toMap()));
  }

  Future<void> loginWithEmail(String email, String password) async {
    try {
      final response = await _userRepository.login(email, password);

      final userData = response['user'] ?? response;
      _currentUser = UserModel.fromMap(userData);

      _userController.add(_currentUser);
      await _saveSession(_currentUser!);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> registerWithEmail(String email, String password) async {
    try {
      final response = await _userRepository.register(email, password);

      final userData = response['user'] ?? response;
      _currentUser = UserModel.fromMap(userData);

      _userController.add(_currentUser);
      await _saveSession(_currentUser!);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.additionalUserInfo?.isNewUser == true) {
        await _syncUserWithApi(userCredential.user);
      }
    } catch (e) {
      debugPrint("Erro Google Login: $e");
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await Future.wait([_auth.signOut(), GoogleSignIn().signOut()]);

      _currentUser = null;
      _userController.add(null);

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_session');

      debugPrint("Sessão encerrada (API + Firebase) com sucesso.");
    } catch (e) {
      debugPrint("Erro ao realizar logout: $e");
    }
  }

  Future<void> _syncUserWithApi(User? firebaseUser) async {
    if (firebaseUser == null) return;
    final userModel = _mapFirebaseUser(firebaseUser);
    if (userModel != null) {
      try {
        await _userRepository.createUser(userModel);
      } catch (e) {
        debugPrint("Aviso: Falha na sincronização do perfil social: $e");
      }
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
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      updatedAt: user.metadata.lastSignInTime ?? DateTime.now(),
    );
  }
}
