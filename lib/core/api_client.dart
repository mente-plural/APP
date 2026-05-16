import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../api_config.dart';
import '../models/user_model.dart';
import 'token_manager.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final String _baseUrl = ApiConfig.baseUrl;
  final TokenManager _tokenManager = TokenManager();


  VoidCallback? onUnauthorized;

  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

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
        headers: await _getHeaders(),
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
        headers: await _getHeaders(),
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
        headers: await _getHeaders(),
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

  Future<Map<String, dynamic>> firebaseAuth(String idToken) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/auth/firebase'),
        headers: { 'Content-Type': 'application/json' },
        body: jsonEncode({ 'idToken': idToken }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // Se der 401 aqui, o ID Token do Google expirou durante o processo
        _handleErrorResponse(response);
        return {};
      }
    } catch (e) {
      rethrow;
    }
  }

  void _handleErrorResponse(http.Response response, {bool silent = false}) {
    debugPrint("API Error Response (${response.statusCode}): ${response.body} (silent: $silent)");
    if (response.statusCode == 401) {
      if (!silent) {
        _tokenManager.deleteToken();
        debugPrint("Sessão expirada (401). O usuário será deslogado.");
        onUnauthorized?.call();
      } else {
        debugPrint("Erro 401 capturado em modo silencioso. Mantendo sessão para tentativa de recuperação.");
      }
      throw 'Unauthorized'; 
    }

    try {
      final data = jsonDecode(response.body);
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
        headers: await _getHeaders(),
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
        headers: await _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          await _tokenManager.saveToken(data['token']);
        }
        return data;
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
        headers: await _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      debugPrint(response.statusCode as String?);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          await _tokenManager.saveToken(data['token']);
          debugPrint("Token salvo: ${data['token']} !!!!!!!!!!!!!!!!!!!!!!!!");
        }
        return data;
      } else {
        _handleErrorResponse(response);
        return {};
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> syncProfile(UserModel user,
      {String? firebaseToken}) async {
    try {
      final profileType = user.preferences.profileType;
      final body = {
        'firebaseUid': user.firebaseUid,
        'email': user.email,
        'name': user.name ?? 'Usuário',
        'phone': user.phone,
        if (user.photoUrl != null && user.photoUrl!.isNotEmpty) 'photo_url': user.photoUrl,
        'preferences': user.preferences.copyWith(profileType: profileType).toMap(),
      };

      debugPrint("API Sync Request: POST /v1/users");

      final headers = await _getHeaders();
      if (firebaseToken != null) {
        headers['X-Firebase-Token'] = firebaseToken;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/v1/users'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          await _tokenManager.saveToken(data['token']);
          debugPrint("Backend Token salvo após sync: ${data['token']}");
        }
        return data;
      } else {
        debugPrint("API Sync Error (${response.statusCode}): ${response.body}");
        _handleErrorResponse(response, silent: true);
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
        headers: await _getHeaders(),
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
