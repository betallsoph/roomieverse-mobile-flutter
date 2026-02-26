import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/community_post.dart';
import '../models/community_comment.dart';

class CommunityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const _postsCollection = 'community_posts';
  static const _commentsCollection = 'community_comments';
  static const _likesCollection = 'community_likes';

  String _timestampToString(dynamic ts) {
    if (ts == null) return DateTime.now().toIso8601String();
    if (ts is Timestamp) return ts.toDate().toIso8601String();
    if (ts is String) return ts;
    return DateTime.now().toIso8601String();
  }

  CommunityPost _docToPost(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    data['createdAt'] = _timestampToString(data['createdAt']);
    data['updatedAt'] = _timestampToString(data['updatedAt']);
    return CommunityPost.fromJson(data, doc.id);
  }

  CommunityComment _docToComment(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    data['createdAt'] = _timestampToString(data['createdAt']);
    return CommunityComment.fromJson(data, doc.id);
  }

  /// Get community posts
  Future<List<CommunityPost>> getPosts({String? category, int limit = 50}) async {
    Query q = _db
        .collection(_postsCollection)
        .where('status', isEqualTo: 'active');

    if (category != null) {
      q = q.where('category', isEqualTo: category);
    }

    q = q.orderBy('createdAt', descending: true).limit(limit);
    final snap = await q.get();
    return snap.docs.map((d) => _docToPost(d as DocumentSnapshot)).toList();
  }

  /// Get post by ID
  Future<CommunityPost?> getPostById(String id) async {
    final doc = await _db.collection(_postsCollection).doc(id).get();
    if (!doc.exists) return null;
    return _docToPost(doc);
  }

  /// Create a post
  Future<String> createPost(Map<String, dynamic> data) async {
    final postId = 'cp-${DateTime.now().millisecondsSinceEpoch}';
    final content = data['content'] as String? ?? '';
    final preview = content.length > 150
        ? '${content.substring(0, 150)}...'
        : content;

    await _db.collection(_postsCollection).doc(postId).set({
      ...data,
      'preview': preview,
      'likes': 0,
      'comments': 0,
      'views': 0,
      'hot': false,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return postId;
  }

  /// Delete post (soft)
  Future<void> deletePost(String id) async {
    await _db.collection(_postsCollection).doc(id).update({
      'status': 'deleted',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Increment view count
  Future<void> incrementViewCount(String postId) async {
    try {
      await _db.collection(_postsCollection).doc(postId).update({
        'views': FieldValue.increment(1),
      });
    } catch (_) {}
  }

  /// Toggle post like
  Future<bool> togglePostLike(String postId, String userId) async {
    final likeId = '${userId}_post_$postId';
    final likeRef = _db.collection(_likesCollection).doc(likeId);
    final snap = await likeRef.get();

    if (snap.exists) {
      await likeRef.delete();
      await _db.collection(_postsCollection).doc(postId).update({
        'likes': FieldValue.increment(-1),
      });
      return false;
    } else {
      await likeRef.set({
        'userId': userId,
        'targetId': postId,
        'type': 'post',
        'createdAt': FieldValue.serverTimestamp(),
      });
      await _db.collection(_postsCollection).doc(postId).update({
        'likes': FieldValue.increment(1),
      });
      return true;
    }
  }

  /// Check if post is liked
  Future<bool> isPostLiked(String postId, String userId) async {
    final likeRef = _db.collection(_likesCollection).doc('${userId}_post_$postId');
    final snap = await likeRef.get();
    return snap.exists;
  }

  /// Get comments for a post
  Future<List<CommunityComment>> getComments(String postId) async {
    final snap = await _db
        .collection(_commentsCollection)
        .where('postId', isEqualTo: postId)
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt')
        .get();
    return snap.docs.map((d) => _docToComment(d as DocumentSnapshot)).toList();
  }

  /// Create a comment
  Future<String> createComment(Map<String, dynamic> data) async {
    final commentId = 'cc-${DateTime.now().millisecondsSinceEpoch}';
    await _db.collection(_commentsCollection).doc(commentId).set({
      ...data,
      'likes': 0,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Increment comment count on post
    try {
      await _db.collection(_postsCollection).doc(data['postId']).update({
        'comments': FieldValue.increment(1),
      });
    } catch (_) {}

    return commentId;
  }

  /// Delete comment (soft)
  Future<void> deleteComment(String commentId, String postId) async {
    await _db.collection(_commentsCollection).doc(commentId).update({
      'status': 'deleted',
    });
    try {
      await _db.collection(_postsCollection).doc(postId).update({
        'comments': FieldValue.increment(-1),
      });
    } catch (_) {}
  }
}
