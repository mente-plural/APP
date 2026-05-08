import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';
import '../models/user_model.dart';

class UserRepository {
  final String _baseUrl = ApiConfig.baseUrl;

  void _handleErrorResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      throw data['message'] ?? 'Erro desconhecido no servidor';
    } catch (e) {
      if (e is String) rethrow;
      throw 'Falha na comunicação com o servidor (${response.statusCode})';
    }
  }

  Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
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

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
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
  Future<void> createUser(UserModel user) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firebaseUid': user.firebaseUid,
          'email': user.email,
          'name': user.name,
          'photoUrl': user.photoUrl,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        _handleErrorResponse(response);
      }
    } catch (e) {
      rethrow;
    }
  }
}