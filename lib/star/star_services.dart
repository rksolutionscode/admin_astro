import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:testadm/sugggestion/PrefsHelper.dart';
import 'star_model.dart';

class StarService {
  final String baseUrl = 'https://astro-j7b4.onrender.com/api';

  /// Get headers including latest token
  Future<Map<String, String>> _getHeaders() async {
    final token = await PrefsHelper.getToken();
    print('StarService: Retrieved token: $token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Fetch all star posts
  Future<List<StarPost>> fetchAllPosts() async {
    print('StarService: Fetching all star posts from $baseUrl/admins/star');
    final response = await http.get(Uri.parse('$baseUrl/admins/star'));
    print('StarService: Response [${response.statusCode}]: ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      print('StarService: Successfully fetched ${data.length} posts');
      return data.map((json) => StarPost.fromJson(json)).toList();
    } else {
      print(
        'StarService: Failed to fetch posts, status: ${response.statusCode}',
      );
      throw Exception('Failed to fetch posts: ${response.body}');
    }
  }

  /// Fetch post by Post ID
  Future<StarPost?> fetchPostById(int postId) async {
    print('StarService: Fetching post by ID: $postId');
    final response = await http.get(
      Uri.parse('$baseUrl/admins/star/post/$postId'),
    );
    print('StarService: Response [${response.statusCode}]: ${response.body}');
    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      print('StarService: Successfully fetched post ID: $postId');
      return StarPost.fromJson(data);
    } else if (data['message'] != null && data['message'] == 'Post not found') {
      print('StarService: Post ID $postId not found');
      return null;
    } else {
      print(
        'StarService: Failed to fetch post, status: ${response.statusCode}',
      );
      throw Exception('Failed to fetch post by ID: ${response.body}');
    }
  }

  /// Fetch posts by Star ID
  Future<List<StarPost>> fetchPostsByStarId(int starId) async {
    print('StarService: Fetching posts for starId: $starId');
    final response = await http.get(
      Uri.parse('$baseUrl/admins/star/star/$starId'),
    );
    print('StarService: Response [${response.statusCode}]: ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      print(
        'StarService: Successfully fetched ${data.length} posts for starId: $starId',
      );
      return data.map((json) => StarPost.fromJson(json)).toList();
    } else {
      print(
        'StarService: Failed to fetch posts, status: ${response.statusCode}',
      );
      throw Exception('Failed to fetch posts by Star ID: ${response.body}');
    }
  }

  /// Fetch posts by Admin ID
  Future<List<StarPost>> fetchPostsByAdminId(int adminId) async {
    final headers = await _getHeaders();
    print('StarService: Fetching posts for adminId: $adminId');
    final response = await http.get(
      Uri.parse('$baseUrl/admins/star/admin/$adminId'),
      headers: headers,
    );
    print('StarService: Response [${response.statusCode}]: ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      print(
        'StarService: Successfully fetched ${data.length} posts for adminId: $adminId',
      );
      return data.map((json) => StarPost.fromJson(json)).toList();
    } else {
      print(
        'StarService: Failed to fetch posts, status: ${response.statusCode}',
      );
      throw Exception('Failed to fetch posts by Admin ID: ${response.body}');
    }
  }

  /// Create a new star post
  Future<StarPost> createPost(
    int starId,
    String description,
    String type,
  ) async {
    final headers = await _getHeaders();
    final body = json.encode({
      'starId': starId,
      'description': description,
      'type': type,
    });
    print('StarService: Creating post with body: $body');
    final response = await http.post(
      Uri.parse('$baseUrl/admins/star'),
      headers: headers,
      body: body,
    );
    print('StarService: Response [${response.statusCode}]: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('StarService: Successfully created post');
      return StarPost.fromJson(json.decode(response.body));
    } else {
      final msg = json.decode(response.body)['message'] ?? response.body;
      print(
        'StarService: Failed to create post, status: ${response.statusCode}, message: $msg',
      );
      throw Exception('Failed to create Star post: $msg');
    }
  }

  /// Update a star post
  Future<void> updatePost(int postId, String content, int starId) async {
    final headers = await _getHeaders();
    final body = json.encode({'content': content, 'starId': starId});
    print('StarService: Updating postId: $postId with body: $body');
    final response = await http.put(
      Uri.parse('$baseUrl/admins/star/$postId'),
      headers: headers,
      body: body,
    );
    print('StarService: Response [${response.statusCode}]: ${response.body}');

    if (response.statusCode != 200) {
      final msg = json.decode(response.body)['message'] ?? response.body;
      print(
        'StarService: Failed to update post, status: ${response.statusCode}, message: $msg',
      );
      throw Exception('Failed to update post: $msg');
    }
    print('StarService: Successfully updated postId: $postId');
  }

  /// Delete a star post
  Future<void> deletePost(int postId) async {
    final headers = await _getHeaders();
    print('StarService: Deleting postId: $postId');
    final response = await http.delete(
      Uri.parse('$baseUrl/admins/star/$postId'),
      headers: headers,
    );
    print('StarService: Response [${response.statusCode}]: ${response.body}');

    if (response.statusCode != 200) {
      final msg = json.decode(response.body)['message'] ?? response.body;
      print(
        'StarService: Failed to delete post, status: ${response.statusCode}, message: $msg',
      );
      throw Exception('Failed to delete post: $msg');
    }
    print('StarService: Successfully deleted postId: $postId');
  }

  /// Fetch all access/permissions by AdminID
  Future<List<Map<String, dynamic>>> fetchAdminAccess(int adminId) async {
    final headers = await _getHeaders();
    print('StarService: Fetching admin access for adminId: $adminId');
    final response = await http.get(
      Uri.parse('$baseUrl/admins/access/$adminId'),
      headers: headers,
    );
    print('StarService: Response [${response.statusCode}]: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(
        'StarService: Successfully fetched permissions for adminId: $adminId',
      );
      return List<Map<String, dynamic>>.from(data['permissions']);
    } else {
      final msg = json.decode(response.body)['message'] ?? response.body;
      print(
        'StarService: Failed to fetch admin access, status: ${response.statusCode}, message: $msg',
      );
      throw Exception('Failed to fetch admin access: $msg');
    }
  }
}
