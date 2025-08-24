class StarPost {
  final int postId;
  final int starId;
  final String description;
  final String type;
  final int adminId;
  final DateTime createdAt;
  final DateTime updatedAt;

  StarPost({
    required this.postId,
    required this.starId,
    required this.description,
    required this.type,
    required this.adminId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StarPost.fromJson(Map<String, dynamic> json) {
    return StarPost(
      postId: json['postId'],
      starId: json['starId'],
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      adminId: json['adminId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'postId': postId,
    'starId': starId,
    'description': description,
    'type': type,
    'adminId': adminId,
  };
}
