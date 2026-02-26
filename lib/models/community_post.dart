String? _toStringOrNull(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value.runtimeType.toString() == 'Timestamp') {
    return (value as dynamic).toDate().toIso8601String();
  }
  return value.toString();
}

class CommunityPost {
  final String? id;
  final String authorId;
  final String authorName;
  final String? authorPhoto;
  final String category;
  final String title;
  final String content;
  final String preview;
  final int likes;
  final int comments;
  final int views;
  final bool? hot;
  final String? location;
  final int? rating;
  final String? price;
  final List<String>? images;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  CommunityPost({
    this.id,
    required this.authorId,
    required this.authorName,
    this.authorPhoto,
    required this.category,
    required this.title,
    required this.content,
    required this.preview,
    this.likes = 0,
    this.comments = 0,
    this.views = 0,
    this.hot,
    this.location,
    this.rating,
    this.price,
    this.images,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json, String docId) {
    return CommunityPost(
      id: docId,
      authorId: json['authorId'] as String? ?? '',
      authorName: json['authorName'] as String? ?? '',
      authorPhoto: json['authorPhoto'] as String?,
      category: json['category'] as String? ?? 'tips',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      preview: json['preview'] as String? ?? '',
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      views: json['views'] as int? ?? 0,
      hot: json['hot'] as bool?,
      location: json['location'] as String?,
      rating: json['rating'] as int?,
      price: json['price'] as String?,
      images: (json['images'] as List?)?.cast<String>(),
      status: json['status'] as String? ?? 'active',
      createdAt: _toStringOrNull(json['createdAt']),
      updatedAt: _toStringOrNull(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'authorId': authorId,
        'authorName': authorName,
        if (authorPhoto != null) 'authorPhoto': authorPhoto,
        'category': category,
        'title': title,
        'content': content,
        'preview': preview,
        'likes': likes,
        'comments': comments,
        'views': views,
        if (hot != null) 'hot': hot,
        if (location != null) 'location': location,
        if (rating != null) 'rating': rating,
        if (price != null) 'price': price,
        if (images != null) 'images': images,
        'status': status,
      };
}
