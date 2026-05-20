import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/user_model.dart';
import '../network/api_base_client.dart';

class UserClient extends ApiBaseClient {
  Future<Map<String, dynamic>> fetchUser(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v1/users/$userId'),
        headers: await getHeaders(),
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

  Future<Map<String, dynamic>> syncProfile(UserModel user, {String? firebaseToken}) async {
    try {
      final body = {
        'firebaseUid': user.firebaseUid,
        'email': user.email,
        'name': user.name ?? 'Usuário',
        'phone': user.phone,
        'photoUrl': user.photoUrl, // Backend usa camelCase
        'preferences': user.preferences.toMap(),
      };

      final headers = await getHeaders();
      if (firebaseToken != null) {
        headers['X-Firebase-Token'] = firebaseToken;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/v1/users'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        handleErrorResponse(response, silent: true);
        return {};
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/v1/users/$userId'),
        headers: await getHeaders(),
        body: jsonEncode(data),
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

  Future<Map<String, dynamic>> uploadProfilePhoto(String userId, String filePath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/v1/users/$userId/photo'),
      );
      
      final headers = await getHeaders();
      headers.remove('Content-Type'); // O MultipartRequest define o Content-Type correto com o boundary
      request.headers.addAll(headers);
      
      request.files.add(await http.MultipartFile.fromPath('photo', filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        handleErrorResponse(response);
        return {};
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchLearnContent({String? query, String? category}) async {
    try {
      final uri = Uri.parse('$baseUrl/v1/content/learn').replace(
        queryParameters: {
          if (query != null && query.isNotEmpty) 'search': query,
          if (category != null) 'category': category,
        },
      );
      
      final response = await http.get(
        uri,
        headers: await getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        handleErrorResponse(response);
        return [];
      }
    } catch (e) {
      rethrow;
    }
  }
}
