import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:testadm/services/auth_controller.dart';
import 'star_model.dart';

class StarService {
  final String baseUrl = "http://astro-j7b4.onrender.com/api/admins/star";

  /// Get latest token from AuthController
  String get _token => authController.token.value;

  /// Build headers
  Map<String, String> get _headers => {
    'Authorization': 'Bearer $_token',
    'Content-Type': 'application/json',
  };

  // Fetch all star posts
  Future<List<StarPost>> fetchAllPosts() async {
    final response = await http.get(Uri.parse(baseUrl), headers: _headers);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      return data.map((json) => StarPost.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch posts: ${response.body}');
    }
  }

  // Fetch post by ID
  Future<StarPost> fetchPostById(int postId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/post/$postId"),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return StarPost.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch post: ${response.body}');
    }
  }

  // Fetch posts by star ID
  Future<List<StarPost>> fetchPostsByStarId(int starId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/star/$starId"),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      return data.map((json) => StarPost.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch posts by starId: ${response.body}');
    }
  }

  // Fetch posts by admin ID
  Future<List<StarPost>> fetchPostsByAdminId(int adminId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/admin/$adminId"),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      return data.map((json) => StarPost.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch posts by adminId: ${response.body}');
    }
  }

  // Create a new star post
Future<void> createPost(int starId, String description, String type) async {
    final body = json.encode({
      'starId': starId,
      'description': description,
      'type': type,
    });

    print("Creating Star post with body: $body");

    final response = await http.post(
      Uri.parse('https://astro-j7b4.onrender.com/api/admins/star/'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    print("Star post status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create Star post: ${response.body}');
    }
  }




  // Update a star post
  Future<void> updatePost(int postId, String description, int starId) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$postId"),
      headers: _headers,
      body: json.encode({"content": description, "starId": starId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update post: ${response.body}');
    }
  }

  // Delete a star post
  Future<void> deletePost(int postId) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/$postId"),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete post: ${response.body}');
    }
  }
}
