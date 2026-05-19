import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../api_config.dart';
import '../token_manager.dart';

abstract class ApiBaseClient {
  final String baseUrl = ApiConfig.baseUrl;
  final TokenManager tokenManager = TokenManager();
  
  VoidCallback? onUnauthorized;

  Future<Map<String, String>> getHeaders() async {
    final token = await tokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  void handleErrorResponse(http.Response response, {bool silent = false}) {
    debugPrint("API Error Response (${response.statusCode}): ${response.body} (silent: $silent)");
    if (response.statusCode == 401) {
      if (!silent) {
        tokenManager.deleteToken();
        debugPrint("Sessão expirada (401). O usuário será deslogado.");
        onUnauthorized?.call();
      }
      throw 'Unauthorized'; 
    }

    try {
      final data = jsonDecode(response.body);
      throw data['message'] ?? 'Erro desconhecido no servidor';
    } catch (e) {
      if (e is String) rethrow;
      throw 'Falha na comunicação com o servidor (${response.statusCode})';
    }
  }
}
