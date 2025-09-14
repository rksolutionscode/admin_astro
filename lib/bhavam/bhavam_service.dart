import 'dart:convert';
import 'package:http/http.dart' as http;
import 'bhavam_model.dart';

class BhavamService {
  static const String baseUrl = "https://astro-j7b4.onrender.com/api/admins";

  /// Fetch all sins
  static Future<List<BhavamModel>> fetchAllSins(String token) async {
    print('Fetching all sins with token: $token');
    final response = await http.get(
      Uri.parse('$baseUrl/sin'),
      headers: {'Authorization': 'Bearer $token'},
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => BhavamModel.fromJson(e)).toList();
    } else if (response.statusCode == 403) {
      throw Exception('Token expired or invalid');
    } else {
      throw Exception('Failed to fetch sins');
    }
  }

  /// Fetch sins by sinId with optional type filter
  static Future<List<BhavamModel>> fetchSinsBySinId(
    String token,
    int sinId, [
    String? type,
  ]) async {
    print('Fetching sins by sinId: $sinId, type: $type');
    final uri = Uri.parse(
      '$baseUrl/sin/sin/$sinId',
    ).replace(queryParameters: type != null ? {'type': type} : null);

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => BhavamModel.fromJson(e)).toList();
    } else if (response.statusCode == 403) {
      throw Exception('Token expired or invalid');
    } else {
      throw Exception('Failed to fetch sins by sinId');
    }
  }

  /// Create a new sin post
  static Future<BhavamModel> createSin(
    String token,
    int postId,
    int sinId,
    String description,
    String type,
  ) async {
    final body = json.encode({
      'postId': postId,
      'sinId': sinId,
      'description': description,
      'type': type,
    });
    print('Creating sin: $body');

    final response = await http.post(
      Uri.parse('$baseUrl/sin'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return BhavamModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 403) {
      throw Exception('Token expired or invalid');
    } else {
      final errorMsg =
          json.decode(response.body)['error'] ?? 'Failed to create sin';
      throw Exception(errorMsg);
    }
  }

  /// Update an existing sin post
  static Future<void> updateSin(
    String token,
    int postId,
    String description,
    String type,
  ) async {
    final body = json.encode({'description': description, 'type': type});
    print('Updating sin $postId: $body');

    final response = await http.put(
      Uri.parse('$baseUrl/sin/$postId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode != 200) {
      if (response.statusCode == 403)
        throw Exception('Token expired or invalid');
      final errorMsg =
          json.decode(response.body)['error'] ?? 'Failed to update sin';
      throw Exception(errorMsg);
    }
  }

  /// Delete a sin post
  static Future<void> deleteSin(String token, int postId) async {
    print('Deleting sin $postId');

    final response = await http.delete(
      Uri.parse('$baseUrl/sin/$postId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode != 200) {
      if (response.statusCode == 403)
        throw Exception('Token expired or invalid');
      throw Exception('Failed to delete sin');
    }
  }

  /// Fetch posts by adminId
  static Future<List<BhavamModel>> fetchSinsByAdminId(
    String token,
    int adminId,
  ) async {
    print('Fetching sins by adminId: $adminId');

    final response = await http.get(
      Uri.parse('$baseUrl/sin/admin/$adminId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => BhavamModel.fromJson(e)).toList();
    } else if (response.statusCode == 403) {
      throw Exception('Token expired or invalid');
    } else {
      throw Exception('Failed to fetch sins by adminId');
    }
  }

  /// Fetch admin access permissions
  static Future<List<Map<String, dynamic>>> fetchAdminAccess(
    String token,
    int adminId,
  ) async {
    print('Fetching admin access for adminId: $adminId');

    final response = await http.get(
      Uri.parse('$baseUrl/access/$adminId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['permissions']);
    } else if (response.statusCode == 403) {
      throw Exception('Token expired or invalid');
    } else {
      throw Exception('Failed to fetch admin access');
    }
  }

  /// Bulk upload sins for a specific sinId
  static Future<void> bulkUploadSins(
    String token,
    int sinId,
    List<Map<String, String>> sins,
  ) async {
    final body = json.encode({'sinId': sinId, 'sins': sins});
    print('Bulk uploading sins: $body');

    final response = await http.post(
      Uri.parse('$baseUrl/sin/bulk-upload'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      if (response.statusCode == 403)
        throw Exception('Token expired or invalid');
      final errorMsg = json.decode(response.body)['error'] ?? 'Unknown error';
      throw Exception('Bulk upload failed: $errorMsg');
    }
  }
}
