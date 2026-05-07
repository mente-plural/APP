import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class UserRepository {
  final String _baseUrl = "http://10.0.2.2:3000/v1";

  Future<void> createUser(UserModel user) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'firebaseUid': user.firebaseUid,
          'email': user.email,
          'name': user.name,
          'photoUrl': user.photoUrl,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Erro ao sincronizar com a API: ${response.body}');
      }
    } catch (e) {
      throw Exception('Falha na conexão com o servidor: $e');
    }
  }
}