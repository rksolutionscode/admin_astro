import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:testadm/sugggestion/PrefsHelper.dart';
import 'rasi_model.dart';
import 'package:http_parser/http_parser.dart'; // <-- add this


class RasiService {
  /// ✅ Single base URL
  static const String baseUrl = 'https://astro-j7b4.onrender.com/api/admins';

  static const String _raasiEndpoint = 'raasi';
  static const String _loginEndpoint = 'login';

  /// Generate headers with optional token
  static Map<String, String> _getHeaders([String? token]) {
    return {
      'Content-Type': 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };
  }

  /// Generic GET request
  static Future<dynamic> _get(String url, [String? token]) async {
    final response = await http.get(
      Uri.parse(url),
      headers: _getHeaders(token),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception('GET request failed: ${response.body}');
    }
  }

  /// Generic POST request
  static Future<void> _post(
    String url,
    Map<String, dynamic> body, [
    String? token,
  ]) async {
    final response = await http.post(
      Uri.parse(url),
      headers: _getHeaders(token),
      body: json.encode(body),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('POST request failed: ${response.body}');
    }
  }

  /// Generic PUT request
  static Future<void> _put(
    String url,
    Map<String, dynamic> body, [
    String? token,
  ]) async {
    final response = await http.put(
      Uri.parse(url),
      headers: _getHeaders(token),
      body: json.encode(body),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('PUT request failed: ${response.body}');
    }
  }

  /// Generic DELETE request
  static Future<void> _delete(String url, [String? token]) async {
    final response = await http.delete(
      Uri.parse(url),
      headers: _getHeaders(token),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('DELETE request failed: ${response.body}');
    }
  }

  /// Admin Login → returns {token, adminId}
  static Future<Map<String, dynamic>> loginAdmin(
    String email,
    String password,
  ) async {
    final url = '$baseUrl/$_loginEndpoint';
    final body = {'email': email, 'password': password};
    final response = await http.post(
      Uri.parse(url),
      headers: _getHeaders(),
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {'token': data['token'], 'adminId': data['adminId']};
    } else {
      throw Exception('Admin login failed: ${response.body}');
    }
  }

  /// Fetch Rasi posts by admin
  static Future<List<RasiModel>> fetchRasiPostsByAdmin(String token) async {
    final url = '$baseUrl/$_raasiEndpoint/admin/adminId';

    final response = await http.get(
      Uri.parse(url),
      headers: _getHeaders(token),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => RasiModel.fromJson(e)).toList();
    } else {
      throw Exception('GET request failed: ${response.body}');
    }
  }

  /// Add new Rasi post
  static Future<void> addRasiPost(
    String token,
    int raasiId,
    String content,
    int adminId, {
    String type = 'Negative',
  }) async {
    final url = '$baseUrl/$_raasiEndpoint';
    await _post(url, {
      'raasiId': raasiId,
      'content': content,
      'adminId': adminId,
      'type': type,
    }, token);
  }

  /// Update Rasi post
  static Future<void> updateRasiPost(
    String token,
    int postId,
    String content,
    int raasiId, {
    String? type,
  }) async {
    final url = '$baseUrl/$_raasiEndpoint/$postId';
    final body = {
      'content': content,
      'raasiId': raasiId,
      if (type != null) 'type': type,
    };
    await _put(url, body, token);
  }

  /// Delete Rasi post
  static Future<void> deleteRasiPost(String token, int postId) async {
    final url = '$baseUrl/$_raasiEndpoint/$postId';
    await _delete(url, token);
  }

  /// Fetch admin permissions for Rasi module
  static Future<List<int>> fetchAdminPermissions(
    int adminId,
    String token,
  ) async {
    final url = '$baseUrl/access/$adminId';
    final data = await _get(url, token) as Map<String, dynamic>;
    final permissions = data['permissions'] as List;

    return permissions
        .where((p) => p['moduleName'] == 'Raasi')
        .map<int>((p) => p['moduleId'] as int)
        .toList();
  }

  static Future<void> bulkUploadRaasiFile(dynamic file, int raasiId) async {
    final uri = Uri.parse("$baseUrl/$_raasiEndpoint/bulk-upload");
    final token = await PrefsHelper.getToken();

    if (token == null) {
      print("[bulkUploadRaasiFile] ❌ Token is missing or expired");
      throw Exception("Token is missing or expired");
    }

    print("[bulkUploadRaasiFile] ✅ Token found: $token");
    print("[bulkUploadRaasiFile] Preparing upload for RaasiId: $raasiId");
    print("[bulkUploadRaasiFile] Upload URL: $uri");

    final request =
        http.MultipartRequest('POST', uri)
          ..headers['Authorization'] = 'Bearer $token'
          ..fields['raasiId'] = raasiId.toString();

    if (kIsWeb) {
      print("[bulkUploadRaasiFile] Running on Web platform");

      if (file.bytes == null) {
        print(
          "[bulkUploadRaasiFile] ❌ No file bytes found (Web upload failed)",
        );
        throw Exception("No file bytes found (Web upload failed).");
      }

      String contentType = 'application/octet-stream';
      if (file.name.endsWith('.xlsx')) {
        contentType =
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      } else if (file.name.endsWith('.xls')) {
        contentType = 'application/vnd.ms-excel';
      } else if (file.name.endsWith('.csv')) {
        contentType = 'text/csv';
      }

      print("[bulkUploadRaasiFile] File selected: ${file.name}");
      print("[bulkUploadRaasiFile] File size: ${file.bytes!.length} bytes");
      print("[bulkUploadRaasiFile] Detected contentType: $contentType");

      request.files.add(
        http.MultipartFile.fromBytes(
          'excel',
          file.bytes!,
          filename: file.name,
          contentType: MediaType.parse(contentType),
        ),
      );
    } else {
      // Mobile/Desktop
      print("[bulkUploadRaasiFile] Running on Mobile/Desktop platform");
      print("[bulkUploadRaasiFile] File path: ${file.path}");

      request.files.add(await http.MultipartFile.fromPath('file', file.path));
    }

    print("[bulkUploadRaasiFile] Sending request to server...");
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print("[bulkUploadRaasiFile] 🔄 Response status: ${response.statusCode}");
    print("[bulkUploadRaasiFile] 🔄 Response body: ${response.body}");

    if (response.statusCode < 200 || response.statusCode >= 300) {
      print(
        "[bulkUploadRaasiFile] ❌ Upload failed with status: ${response.statusCode}",
      );
      throw ApiHttpException(
        'Bulk upload failed',
        response.statusCode,
        response.body,
      );
    }

    print("[bulkUploadRaasiFile] ✅ Upload completed successfully!");
  }

}
// api_http_exception.dart
class ApiHttpException implements Exception {
  final String message;
  final int statusCode;
  final String responseBody;

  ApiHttpException(this.message, this.statusCode, this.responseBody);

  @override
  String toString() =>
      '$message (Status: $statusCode)\nResponse: $responseBody';
}

