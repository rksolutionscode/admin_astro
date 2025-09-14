import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'laknam_model.dart';
import '../sugggestion/PrefsHelper.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:http_parser/http_parser.dart'; // <-- add this

class LaknamService {
  static const String _baseUrl = "https://astro-j7b4.onrender.com/api/admins";

  // Cache for headers to avoid repeated token retrieval
  Future<Map<String, String>> _getHeaders() async {
    final token = await PrefsHelper.getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    print('Headers: $headers');
    return headers;
  }

  /// Generic HTTP GET request handler with error handling
  Future<dynamic> _getRequest(String endpoint) async {
    final uri = Uri.parse("$_baseUrl/$endpoint");
    final headers = await _getHeaders();
    print('GET Request to: $uri');

    final response = await http.get(uri, headers: headers);
    print('Response (${response.statusCode}): ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw HttpException(
        'HTTP ${response.statusCode}: Failed to fetch data',
        response.statusCode,
        response.body,
      );
    }
  }

  /// Generic HTTP request handler for POST/PUT/DELETE
  Future<void> _sendRequest({
    required String endpoint,
    required String method,
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse("$_baseUrl/$endpoint");
    final headers = await _getHeaders();
    print('$method Request to: $uri');
    print('Body: $body');

    late final http.Response response;

    switch (method) {
      case 'POST':
        response = await http.post(
          uri,
          headers: headers,
          body: json.encode(body),
        );
        break;
      case 'PUT':
        response = await http.put(
          uri,
          headers: headers,
          body: json.encode(body),
        );
        break;
      case 'DELETE':
        response = await http.delete(uri, headers: headers);
        break;
      default:
        throw Exception('Unsupported HTTP method: $method');
    }

    print('Response (${response.statusCode}): ${response.body}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'HTTP ${response.statusCode}: Failed to $method data',
        response.statusCode,
        response.body,
      );
    }
  }

  /// Fetch posts created by the logged-in admin
  Future<List<LaknamPost>> fetchPostsByAdmin() async {
    try {
      final data = await _getRequest("laknam/admin/adminId") as List;
      return data.map((e) => LaknamPost.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch admin posts: $e');
    }
  }

  /// Fetch posts by Laknam ID
  Future<List<LaknamPost>> fetchPostsByLaknam(int laknamId) async {
    try {
      final data = await _getRequest("laknam/$laknamId") as List;
      return data.map((e) => LaknamPost.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch posts for laknam $laknamId: $e');
    }
  }

  /// Create a new post
  Future<void> createPost(int laknamId, String content, String type) async {
    await _sendRequest(
      endpoint: "laknam",
      method: 'POST',
      body: {"LaknamId": laknamId, "content": content, "type": type},
    );
  }

  /// Fetch admin permissions for Laknam module
  Future<List<int>> fetchAdminPermissions(int adminId) async {
    try {
      final data = await _getRequest("access/$adminId") as Map<String, dynamic>;
      final permissions = data['permissions'] as List;

      return permissions
          .where((p) => p['moduleName'] == 'Laknam')
          .map<int>((p) => p['moduleId'] as int)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch admin permissions: $e');
    }
  }

  /// Update an existing post
  Future<void> updatePost(int postId, String content, int laknamId) async {
    await _sendRequest(
      endpoint: "laknam/$postId",
      method: 'PUT',
      body: {"content": content, "LaknamId": laknamId},
    );
  }

  /// Delete a post
  Future<void> deletePost(int postId) async {
    await _sendRequest(
      endpoint: "laknam/$postId",
      method: 'DELETE',
      body: {}, // Empty body for DELETE
    );
  }

  Future<void> bulkUploadLaknamFile(dynamic file, int laknamId) async {
    final uri = Uri.parse("$_baseUrl/laknam/bulk-upload");
    final token = await PrefsHelper.getToken();

    if (token == null) {
      throw Exception("Token is missing or expired");
    }

    print("[bulkUploadLaknamFile] Uploading file for LaknamId: $laknamId");

    final request =
        http.MultipartRequest('POST', uri)
          ..headers['Authorization'] = 'Bearer $token'
          ..fields['LaknamId'] = laknamId.toString();

    if (kIsWeb) {
      if (file.bytes == null)
        throw Exception("No file bytes found (Web upload failed).");

      String contentType = 'application/octet-stream';
      if (file.name.endsWith('.xlsx')) {
        contentType =
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      } else if (file.name.endsWith('.xls')) {
        contentType = 'application/vnd.ms-excel';
      } else if (file.name.endsWith('.csv')) {
        contentType = 'text/csv';
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'excel',
          file.bytes!,
          filename: file.name,
          contentType: MediaType.parse(contentType), // <-- corrected
        ),
      );
    } else {
      // Mobile/Desktop: File
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      print("[bulkUploadLaknamFile] Mobile/Desktop file path: ${file.path}");
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print("[bulkUploadLaknamFile] Response status: ${response.statusCode}");
    print("[bulkUploadLaknamFile] Response body: ${response.body}");

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Bulk upload failed',
        response.statusCode,
        response.body,
      );
    }

    print("[bulkUploadLaknamFile] Upload completed successfully");
  }
}

/// Custom exception class for better error handling
class HttpException implements Exception {
  final String message;
  final int statusCode;
  final String responseBody;

  HttpException(this.message, this.statusCode, this.responseBody);

  @override
  String toString() =>
      '$message (Status: $statusCode)\nResponse: $responseBody';
}
