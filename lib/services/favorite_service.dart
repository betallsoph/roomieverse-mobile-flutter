import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const _collection = 'favorites';

  String _compositeId(String userId, String listingId) => '${userId}_$listingId';

  /// Get all favorite listing IDs for a user
  Future<List<String>> getUserFavorites(String userId) async {
    final snap = await _db
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => d.data()['listingId'] as String).toList();
  }

  /// Check if favorited
  Future<bool> isFavorited(String userId, String listingId) async {
    final doc = await _db.collection(_collection).doc(_compositeId(userId, listingId)).get();
    return doc.exists;
  }

  /// Toggle favorite — returns new state
  Future<bool> toggleFavorite(String userId, String listingId) async {
    final docId = _compositeId(userId, listingId);
    final docRef = _db.collection(_collection).doc(docId);
    final snap = await docRef.get();

    if (snap.exists) {
      await docRef.delete();
      try {
        await _db.collection('listings').doc(listingId).update({
          'favoriteCount': FieldValue.increment(-1),
        });
      } catch (_) {}
      return false;
    } else {
      await docRef.set({
        'userId': userId,
        'listingId': listingId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      try {
        await _db.collection('listings').doc(listingId).update({
          'favoriteCount': FieldValue.increment(1),
        });
      } catch (_) {}
      return true;
    }
  }
}
