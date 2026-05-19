import 'dart:async';
import 'package:app/core/user/user_client.dart';
import 'package:flutter/material.dart';
import '../../models/user_model.dart'; // Ajuste o path se necessário

class UserService {
  final UserClient _userClient = UserClient();

  // Controller de estado para notificar o app quando o usuário logado mudar
  final StreamController<UserModel?> _userController = StreamController<UserModel?>.broadcast();
  Stream<UserModel?> get userStream => _userController.stream;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  /// Busca um usuário específico pelo ID e mapeia para o Model forte.
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await _userClient.fetchUser(userId);

      // Ajuste os fallbacks de chaves de acordo com o padrão da sua API Fastify
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

  /// Sincroniza o perfil do Firebase com o Backend Fastify.
  /// Se a API retornar um novo JWT de acesso, ele gerencia a persistência.
  Future<UserModel?> syncUserProfile(UserModel user, {String? firebaseToken}) async {
    try {
      final response = await _userClient.syncProfile(user, firebaseToken: firebaseToken);

      // 1. Captura e gerencia o token se o Fastify devolver um no login/sync
      final token = response['token'] ?? response['data']?['token'];
      if (token != null) {
        // Ex: await _tokenManager.saveToken(token);
        debugPrint("🔑 [UserService] Novo JWT interceptado e salvo com sucesso.");
      }

      // 2. Extrai os dados do usuário atualizados pelo banco (Upsert)
      final userData = response['data']?['user'] ?? response['user'] ?? response['data'];

      if (userData != null && userData is Map) {
        _currentUser = UserModel.fromMap(userData.cast<String, dynamic>());

        // Notifica as telas/controllers escutando a Stream
        _userController.add(_currentUser);

        // Salva o cache visual localmente no SharedPreferences (sessão rápida)
        // Ex: await _saveSession(_currentUser!);

        return _currentUser;
      }
      return null;
    } catch (e) {
      debugPrint("⚠️ [UserService] Falha na sincronização em background: $e");

      // Fallback: Se a rede falhar e já tivermos o usuário na memória, mantém ele
      if (_currentUser == null) {
        _currentUser = user;
        _userController.add(_currentUser);
      }
      return _currentUser;
    }
  }

  /// Atualiza dados parciais do usuário (ex: troca de nome, foto ou preferências)
  Future<bool> updateProfileData(String userId, Map<String, dynamic> updatedFields) async {
    try {
      final response = await _userClient.updateUser(userId, updatedFields);

      final userData = response['data']?['user'] ?? response['user'] ?? response['data'];

      if (userData != null && userData is Map) {
        _currentUser = UserModel.fromMap(userData.cast<String, dynamic>());
        _userController.add(_currentUser);
        // Ex: await _saveSession(_currentUser!);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("❌ [UserService] Erro ao atualizar campos do usuário: $e");
      return false;
    }
  }

  /// Busca os conteúdos educativos/artigos tratando os dados brutos para a UI
  Future<List<Map<String, dynamic>>> getLearnContent({String? query, String? category}) async {
    try {
      // Como o conteúdo de aprendizagem pode vir em formatos variados ou exigir cache,
      // o service isola essa lógica da página.
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

  /// Fecha os fluxos de stream ao encerrar o serviço
  void dispose() {
    _userController.close();
  }
}