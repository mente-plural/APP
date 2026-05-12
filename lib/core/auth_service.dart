import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
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
        _currentUser = _mapFirebaseUser(firebaseUser);
        _userController.add(_currentUser);
        _saveSession(_currentUser!);
      } else {
        if (_currentUser?.firebaseUid != null) {
          await logout();
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
        _currentUser = UserModel.fromMap(data);
        _userController.add(_currentUser);
      }
    } catch (e) {
      debugPrint("Erro ao carregar sessão: $e");
    }
  }

  Future<void> _saveSession(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_session', jsonEncode(user.toMap()));
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
