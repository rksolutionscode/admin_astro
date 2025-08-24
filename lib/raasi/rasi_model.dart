class RasiModel {
  final int postId;
  final int raasiId;
  final String? content;
  final String type; // now required, 5 types

  RasiModel({
    required this.postId,
    required this.raasiId,
    this.content,
    required this.type,
  });

  factory RasiModel.fromJson(Map<String, dynamic> json) {
    return RasiModel(
      postId: json['postId'] ?? 0,
      raasiId: json['raasiId'] ?? 0,
      content: json['content']?.toString(),
      type: json['type']?.toString() ?? 'All', // default to All
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'raasiId': raasiId,
      'content': content,
      'type': type,
    };
  }
}
