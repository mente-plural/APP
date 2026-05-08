import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepository = UserRepository();
  Stream<UserModel?> get userStream =>
      _auth.authStateChanges().map(_mapFirebaseUser);

  User? get currentFirebaseUser => _auth.currentUser;


  Future<void> loginWithEmail(String email, String password) async {
    await _userRepository.login(email, password);
  }


  Future<void> registerWithEmail(String email, String password) async {
    await _userRepository.register(
      email,
      password,
    );
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
      debugPrint("Erro Google: $e");
      rethrow;
    }
  }



  Future<void> logout() async {
    await Future.wait([
      _auth.signOut(),
      GoogleSignIn().signOut(),
    ]);
  }


  Future<void> _syncUserWithApi(User? firebaseUser) async {
    if (firebaseUser == null) return;

    final userModel = _mapFirebaseUser(firebaseUser);
    if (userModel != null) {
      try {
        await _userRepository.createUser(userModel);
        debugPrint("Sucesso: Dados sincronizados com o PostgreSQL via Prisma.");
      } catch (e) {
        debugPrint("Aviso: Login no Firebase funcionou, mas a API falhou: $e");
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
