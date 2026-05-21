import 'dart:async';
import 'package:app/core/user/user_client.dart';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class UserService {
  final UserClient _userClient = UserClient();


  final StreamController<UserModel?> _userController = StreamController<UserModel?>.broadcast();
  Stream<UserModel?> get userStream => _userController.stream;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;


  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await _userClient.fetchUser(userId);


      final userData = response['data']?['user'] ?? response['user'] ?? response['data'];

      if (userData != null && userData is Map) {
        final user = UserModel.fromMap(userData.cast<String, dynamic>());
        return user;
      }
      return null;
    } catch (e) {
      debugPrint("❌ [UserService] Erro ao buscar perfil: $e");
      return null;
    }
  }



  Future<UserModel?> syncUserProfile(UserModel user, {String? firebaseToken}) async {
    try {
      final response = await _userClient.syncProfile(user, firebaseToken: firebaseToken);


      final token = response['token'] ?? response['data']?['token'];
      if (token != null) {

        debugPrint("🔑 [UserService] Novo JWT interceptado e salvo com sucesso.");
      }


      final userData = response['data']?['user'] ?? response['user'] ?? response['data'];

      if (userData != null && userData is Map) {
        _currentUser = UserModel.fromMap(userData.cast<String, dynamic>());


        _userController.add(_currentUser);




        return _currentUser;
      }
      return null;
    } catch (e) {
      debugPrint("⚠️ [UserService] Falha na sincronização em background: $e");


      if (_currentUser == null) {
        _currentUser = user;
        _userController.add(_currentUser);
      }
      return _currentUser;
    }
  }


  Future<bool> updateProfileData(String userId, Map<String, dynamic> updatedFields) async {
    try {
      final response = await _userClient.updateUser(userId, updatedFields);

      final userData = response['data']?['user'] ?? response['user'] ?? response['data'];

      if (userData != null && userData is Map) {
        _currentUser = UserModel.fromMap(userData.cast<String, dynamic>());
        _userController.add(_currentUser);

        return true;
      }
      return false;
    } catch (e) {
      debugPrint("❌ [UserService] Erro ao atualizar campos do usuário: $e");
      return false;
    }
  }


  Future<List<Map<String, dynamic>>> getLearnContent({String? query, String? category}) async {
    try {


      final contents = await _userClient.fetchLearnContent(
        query: query,
        category: category,
      );

      return contents;
    } catch (e) {
      debugPrint("❌ [UserService] Erro ao buscar conteúdos educativos: $e");
      return [];
    }
  }


  void dispose() {
    _userController.close();
  }
}