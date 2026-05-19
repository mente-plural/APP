import 'dart:convert';
import 'package:http/http.dart' as http;
import '../network/api_base_client.dart';

class AuthClient extends ApiBaseClient {
  Future<Map<String, dynamic>> firebaseAuth(String idToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/v1/auth/firebase'),
        headers: { 'Content-Type': 'application/json' },
        body: jsonEncode({ 'idToken': idToken }),
      );

      if (response.statusCode == 200) {
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
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone
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
          'password': password.toString(),
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        handleErrorResponse(response);
        return {};
      }
    } catch (e) {
      rethrow;
    }
  }
}
