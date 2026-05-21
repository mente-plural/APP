import 'dart:convert';
import 'package:http/http.dart' as http;
import '../network/api_base_client.dart';

class RoutineClient extends ApiBaseClient {

  Future<List<Map<String, dynamic>>> fetchRoutineTasks() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v1/routines'),
        headers: await getHeaders(),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        final List<dynamic> data = decoded['data'] ?? decoded['tasks'] ?? [];
        return data.cast<Map<String, dynamic>>();
      }
      handleErrorResponse(response);
      return [];
    } catch (e) { rethrow; }
  }

  Future<Map<String, dynamic>> createTask(Map<String, dynamic> taskData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/v1/routines'),
        headers: await getHeaders(),
        body: jsonEncode(taskData),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      handleErrorResponse(response);
      return {};
    } catch (e) { rethrow; }
  }

  Future<Map<String, dynamic>> updateTask(String taskId, Map<String, dynamic> taskData) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/v1/routines/$taskId'),
        headers: await getHeaders(),
        body: jsonEncode(taskData),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return response.body.isNotEmpty ? jsonDecode(response.body) : {};
      }
      handleErrorResponse(response);
      return {};
    } catch (e) { rethrow; }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/v1/routines/$taskId'),
        headers: await getHeaders(),
        body: jsonEncode({}),
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        handleErrorResponse(response);
      }
    } catch (e) { rethrow; }
  }
}
