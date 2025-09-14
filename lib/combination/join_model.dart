class JoinModel {
  final int id; // DB id
  final int joinId; // JoinId from API
  final String? postId; // Post identifier
  final int? adminId; // Admin who created it
  final String description; // Description/note
  final String type; // Positive/Negative
  final DateTime? createdAt;
  final DateTime? updatedAt;

  JoinModel({
    required this.id,
    required this.joinId,
    this.postId,
    this.adminId,
    required this.description,
    required this.type,
    this.createdAt,
    this.updatedAt,
  });

  JoinModel copyWith({String? description, String? type}) {
    return JoinModel(
      id: id,
      joinId: joinId,
      postId: postId,
      adminId: adminId,
      description: description ?? this.description,
      type: type ?? this.type,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory JoinModel.fromJson(Map<String, dynamic> json) {
    return JoinModel(
      id: json['id'] as int,
      joinId: json['JoinId'] as int,
      postId: json['postId']?.toString(),
      adminId: json['adminId'] as int?,
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "JoinId": joinId,
      "postId": postId,
      "adminId": adminId,
      "description": description,
      "type": type,
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
    };
  }
}
