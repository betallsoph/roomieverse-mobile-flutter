String? _toStringOrNull(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value.runtimeType.toString() == 'Timestamp') {
    return (value as dynamic).toDate().toIso8601String();
  }
  return value.toString();
}

class CommunityComment {
  final String? id;
  final String postId;
  final String authorId;
  final String authorName;
  final String? authorPhoto;
  final String content;
  final int likes;
  final String status;
  final String? createdAt;

  CommunityComment({
    this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    this.authorPhoto,
    required this.content,
    this.likes = 0,
    this.status = 'active',
    this.createdAt,
  });

  factory CommunityComment.fromJson(Map<String, dynamic> json, String docId) {
    return CommunityComment(
      id: docId,
      postId: json['postId'] as String? ?? '',
      authorId: json['authorId'] as String? ?? '',
      authorName: json['authorName'] as String? ?? '',
      authorPhoto: json['authorPhoto'] as String?,
      content: json['content'] as String? ?? '',
      likes: json['likes'] as int? ?? 0,
      status: json['status'] as String? ?? 'active',
      createdAt: _toStringOrNull(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'postId': postId,
        'authorId': authorId,
        'authorName': authorName,
        if (authorPhoto != null) 'authorPhoto': authorPhoto,
        'content': content,
        'likes': likes,
        'status': status,
      };
}
