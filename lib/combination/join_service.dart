import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../sugggestion/PrefsHelper.dart';
import 'join_model.dart';

class JoinService {
  static const String _baseUrl =
      "https://astro-j7b4.onrender.com/api/admins/join";

  // -------------------------
  // Helpers
  // -------------------------
  Future<Map<String, String>> _getHeaders() async {
    final token = await PrefsHelper.getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    print('[JoinService] Headers: $headers');
    return headers;
  }

  Future<dynamic> _getRequest(String endpoint) async {
    final uri = Uri.parse("$_baseUrl/$endpoint");
    final headers = await _getHeaders();
    print('[JoinService] GET $uri');

    final response = await http.get(uri, headers: headers);
    print('[JoinService] Response (${response.statusCode}): ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw HttpException(
        'HTTP ${response.statusCode}: GET failed',
        response.statusCode,
        response.body,
      );
    }
  }

  Future<void> _sendRequest({
    required String endpoint,
    required String method,
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse("$_baseUrl/$endpoint");
    final headers = await _getHeaders();
    print('[JoinService] $method $uri');
    print('[JoinService] Body: $body');

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

    print('[JoinService] Response (${response.statusCode}): ${response.body}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'HTTP ${response.statusCode}: $method failed',
        response.statusCode,
        response.body,
      );
    }
  }

  // -------------------------
  // CRUD Endpoints
  // -------------------------

  /// Create a new Join post
  Future<void> createPost(
    int joinId,
    String description,
    String postId,
    String type,
  ) async {
    await _sendRequest(
      endpoint: "",
      method: 'POST',
      body: {
        "JoinId": joinId,
        "description": description,
        "postId": postId,
        "type": type,
      },
    );
  }

  /// Update a Join post
  Future<void> updatePost(String joinPostId, String description) async {
    await _sendRequest(
      endpoint: joinPostId,
      method: 'PUT',
      body: {"description": description},
    );
  }

  /// Delete a Join post
  Future<void> deletePost(String joinPostId) async {
    await _sendRequest(endpoint: joinPostId, method: 'DELETE', body: {});
  }

  /// Get all Join posts
  Future<List<JoinModel>> fetchAllPosts() async {
    final data = await _getRequest("");
    return (data as List).map((e) => JoinModel.fromJson(e)).toList();
  }

  /// Get a Join post by PostId
  Future<JoinModel> fetchByPostId(String postId) async {
    final data = await _getRequest("post/$postId");
    return JoinModel.fromJson(data);
  }

  /// Get Join posts by JoinId
  Future<List<JoinModel>> fetchByJoinId(String joinId) async {
    final data = await _getRequest("join/$joinId");
    return (data as List).map((e) => JoinModel.fromJson(e)).toList();
  }

  /// Get Join posts created by a specific Admin
  Future<List<JoinModel>> fetchByAdminId(String adminId) async {
    final data = await _getRequest("admin/$adminId");
    return (data as List).map((e) => JoinModel.fromJson(e)).toList();
  }

  // -------------------------
  // Bulk Upload
  // -------------------------
  Future<void> bulkUploadJoinFile(dynamic file, int joinId) async {
    final uri = Uri.parse("$_baseUrl/bulk-upload");
    final token = await PrefsHelper.getToken();

    if (token == null) throw Exception("Token missing or expired");

    final request =
        http.MultipartRequest('POST', uri)
          ..headers['Authorization'] = 'Bearer $token'
          ..fields['JoinId'] = joinId.toString();

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
          contentType: MediaType.parse(contentType),
        ),
      );
    } else {
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print("[JoinService.bulkUpload] Status: ${response.statusCode}");
    print("[JoinService.bulkUpload] Body: ${response.body}");

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        "Bulk upload failed",
        response.statusCode,
        response.body,
      );
    }
  }
}

/// Custom Exception
class HttpException implements Exception {
  final String message;
  final int statusCode;
  final String responseBody;

  HttpException(this.message, this.statusCode, this.responseBody);

  @override
  String toString() => '$message (Status: $statusCode)\n$responseBody';
}
