class LaknamPost {
  final int postId;
  final int laknamId;
  final String type;
  final String content;
  final int adminId;
  final DateTime createdAt;
  final DateTime updatedAt;

  LaknamPost({
    required this.postId,
    required this.laknamId,
    required this.type,
    required this.content,
    required this.adminId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LaknamPost.fromJson(Map<String, dynamic> json) {
    return LaknamPost(
      postId: json['postId'] ?? 0,
      laknamId: json['LaknamId'] ?? 0,
      type: _parseType(json['type']), // Use helper function
      content: json['content'] ?? '',
      adminId: json['adminId'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toString()),
    );
  }

  // Helper function to handle type parsing
  static String _parseType(dynamic typeValue) {
    if (typeValue == null || typeValue.toString().isEmpty) {
      return 'Positive'; // Default value
    }

    final String typeStr = typeValue.toString();

    // Validate against allowed types
    const allowedTypes = ['Strong', 'Weak', 'Positive', 'Negative'];
    if (allowedTypes.contains(typeStr)) {
      return typeStr;
    }

    return 'Positive'; // Fallback to default
  }
}
