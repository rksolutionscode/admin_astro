import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'giraham_model.dart';
import 'package:http_parser/http_parser.dart';

class GirahamService {
  // ✅ Single base URL for all Giraham/Admin endpoints
  static const String baseUrl = 'https://astro-j7b4.onrender.com/api';

  /// Fetch all Girahams
  static Future<List<GirahamModel>> fetchAllGiraham(String token) async {
    print("➡️ Fetching all Girahams...");
    final response = await http.get(
      Uri.parse('$baseUrl/girahams'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    print("⬅️ Response [${response.statusCode}]: ${response.body}");

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => GirahamModel.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to fetch Girahams: ${response.statusCode} - ${response.body}',
      );
    }
  }

  /// Fetch Giraham by ID
  static Future<GirahamModel> fetchGirahamById(String token, int id) async {
    print("➡️ Fetching Giraham by ID: $id");
    final response = await http.get(
      Uri.parse('$baseUrl/girahams/$id'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    print("⬅️ Response [${response.statusCode}]: ${response.body}");

    if (response.statusCode == 200) {
      return GirahamModel.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to fetch Giraham: ${response.statusCode} - ${response.body}',
      );
    }
  }

  /// Create Giraham
  static Future<GirahamModel> createGiraham(
    String token,
    int girahamId,
    String description,
    String type,
  ) async {
    final body = json.encode({
      'girahamId': girahamId,
      'description': description,
      'type': type,
    });

    print("➡️ Creating Giraham: $body");
    final response = await http.post(
      Uri.parse('$baseUrl/girahams/giraham'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );
    print("⬅️ Response [${response.statusCode}]: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return GirahamModel.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to create Giraham: ${response.statusCode} - ${response.body}',
      );
    }
  }

  /// Update Giraham
  static Future<GirahamModel> updateGiraham(
    String token,
    int id,
    String description,
    String type,
  ) async {
    final body = json.encode({'description': description, 'type': type});

    print("➡️ Updating Giraham ID: $id | $body");
    final response = await http.put(
      Uri.parse('$baseUrl/girahams/$id'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );
    print("⬅️ Response [${response.statusCode}]: ${response.body}");

    if (response.statusCode == 200) {
      return GirahamModel.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to update Giraham: ${response.statusCode} - ${response.body}',
      );
    }
  }

  /// Delete Giraham
  static Future<void> deleteGiraham(String token, int id) async {
    print("➡️ Deleting Giraham ID: $id");
    final response = await http.delete(
      Uri.parse('$baseUrl/girahams/$id'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    print("⬅️ Response [${response.statusCode}]: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to delete Giraham: ${response.statusCode} - ${response.body}',
      );
    }
  }

  /// Fetch all access/permissions by AdminID
  static Future<List<Map<String, dynamic>>> fetchAdminAccess(
    String token,
    int adminId,
  ) async {
    print("➡️ Fetching Admin Access for AdminID: $adminId");
    final response = await http.get(
      Uri.parse('$baseUrl/admins/access/$adminId'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    print("⬅️ Response [${response.statusCode}]: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['permissions']);
    } else {
      throw Exception(
        'Failed to fetch admin access: ${response.statusCode} - ${response.body}',
      );
    }
  }

  /// Bulk upload Giraham file
  static Future<void> bulkUploadGirahamFile(String token, dynamic file) async {
    final uri = Uri.parse("$baseUrl/girahams/bulk-upload-giraham");

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token';

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
      request.files.add(await http.MultipartFile.fromPath('excel', file.path));
      print("[bulkUploadGirahamFile] File path: ${file.path}");
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print("[bulkUploadGirahamFile] Response status: ${response.statusCode}");
    print("[bulkUploadGirahamFile] Response body: ${response.body}");

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpsException(
        'Bulk upload failed',
        response.statusCode,
        response.body,
      );
    }

    print("[bulkUploadGirahamFile] Upload completed successfully ✅");
  }
}

/// Custom exception for better error handling
class HttpsException implements Exception {
  final String message;
  final int statusCode;
  final String responseBody;

  HttpsException(this.message, this.statusCode, this.responseBody);

  @override
  String toString() =>
      '$message (Status: $statusCode)\nResponse: $responseBody';
}
