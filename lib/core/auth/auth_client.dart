import 'dart:convert';
import 'package:http/http.dart' as http;
import '../network/api_base_client.dart';

class AuthClient extends ApiBaseClient {
  Future<Map<String, dynamic>> firebaseAuth({
    required String idToken,
    required String email,
    required String photoUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/v1/auth/firebase'),
        headers: await getHeaders(),
        body: jsonEncode({
          'idToken': idToken,
          'email': email,
          'photoUrl': photoUrl,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        handleErrorResponse(response);
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
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/v1/auth/register'),
        headers: await getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'phone': phone
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        handleErrorResponse(response);
        return {};
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/v1/auth/login'),
        headers: await getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        handleErrorResponse(response);
        return {};
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/v1/auth/forgot-password'),
        headers: await getHeaders(),
        body: jsonEncode({'email': email}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return {'message': 'Solicitação enviada'};
        try {
          return jsonDecode(response.body);
        } catch (_) {
          return {'message': response.body};
        }
      } else {
        handleErrorResponse(response);
        return {};
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> resetPassword(String token, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/v1/auth/reset-password'),
        headers: await getHeaders(),
        body: jsonEncode({
          'token': token,
          'newPassword': newPassword,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return {'message': 'Senha alterada com sucesso'};
        try {
          return jsonDecode(response.body);
        } catch (_) {
          return {'message': response.body};
        }
      } else {
        handleErrorResponse(response);
        return {};
      }
    } catch (e) {
      rethrow;
    }
  }
}
