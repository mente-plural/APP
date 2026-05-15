import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../api_config.dart';
import '../models/user_model.dart';

class ApiClient {
  final String _baseUrl = ApiConfig.baseUrl;

  Future<List<Map<String, dynamic>>> fetchLearnContent({String? query, String? category}) async {
    try {
      final uri = Uri.parse('$_baseUrl/v1/content/learn').replace(
        queryParameters: {
          if (query != null && query.isNotEmpty) 'search': query,
          if (category != null) 'category': category,
        },
      );
      
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        _handleErrorResponse(response);
        return [];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchRoutineTasks(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/v1/users/$userId/routine'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        _handleErrorResponse(response);
        return [];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateTaskStatus(String userId, String taskId, bool completed) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/v1/users/$userId/routine/$taskId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'isCompleted': completed}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        _handleErrorResponse(response);
        return {};
      }
    } catch (e) {
      rethrow;
    }
  }

  void _handleErrorResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      // Se houver detalhamento de erros (ex: AJV), tenta capturar para o log
      if (data['errors'] != null) {
        debugPrint("Detalhes do erro API: ${jsonEncode(data['errors'])}");
      }
      throw data['message'] ?? 'Erro desconhecido no servidor';
    } catch (e) {
      if (e is String) rethrow;
      debugPrint("Corpo da resposta de erro: ${response.body}");
      throw 'Falha na comunicação com o servidor (${response.statusCode})';
    }
  }

  Future<Map<String, dynamic>> fetchUser(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/v1/users/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        _handleErrorResponse(response);
        return {};
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    String? name,
    String? phone,
    String? profile,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
          if (profile != null) 'profile_type': profile,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        _handleErrorResponse(response);
        return {};
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
    String? profile,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          if (profile != null) 'profile_type': profile,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        _handleErrorResponse(response);
        return {};
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> syncProfile(UserModel user,
      {String? profile}) async {
    try {
      final profileType = profile ?? user.preferences.profileType;

      final body = {
        'firebase_uid': user.firebaseUid,
        'email': user.email,
        'name': user.name ?? 'Usuário',
        if (user.photoUrl != null && user.photoUrl!.isNotEmpty) 'photo_url': user.photoUrl,
        if (profileType != null) 'profile_type': profileType,
        'preferences': user.preferences.copyWith(profileType: profileType).toMap(),
        // Backend requer estes campos na raiz para criação do perfil
        'preferred_color': user.preferences.preferredColor ?? 'Tema Escuro',
        'neurodivergencies': user.preferences.neurodivergencies,
      };

      debugPrint("API Sync Request: POST /v1/users - Body: ${jsonEncode(body)}");

      final response = await http.post(
        Uri.parse('$_baseUrl/v1/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        debugPrint("API Sync Error (${response.statusCode}): ${response.body}");
        _handleErrorResponse(response);
        return {};
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/v1/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        _handleErrorResponse(response);
        return {};
      }
    } catch (e) {
      rethrow;
    }
  }
}
