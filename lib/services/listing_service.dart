import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing.dart';

class ListingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const _collection = 'listings';

  RoomListing _docToListing(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Handle contact sub-object (web stores contact info both ways)
    final contact = data['contact'] as Map<String, dynamic>? ?? {};

    final merged = Map<String, dynamic>.from(data);
    if (contact.isNotEmpty) {
      merged['phone'] = contact['phone'] ?? data['phone'] ?? '';
      merged['zalo'] = contact['zalo'] ?? data['zalo'];
      merged['facebook'] = contact['facebook'] ?? data['facebook'];
      merged['instagram'] = contact['instagram'] ?? data['instagram'];
    }

    // Handle authorName vs author field
    merged['author'] = data['authorName'] ?? data['author'] ?? '';

    // Handle price fallback to costs.rent
    if ((merged['price'] == null || merged['price'] == '') && data['costs'] != null) {
      merged['price'] = (data['costs'] as Map<String, dynamic>)['rent'] ?? '';
    }

    // Handle Timestamp → String for date fields
    merged['createdAt'] = _timestampToString(data['createdAt']);
    merged['updatedAt'] = _timestampToString(data['updatedAt']);
    merged['postedDate'] = data['postedDate'] ?? _formatDate(merged['createdAt']);

    return RoomListing.fromJson(merged, doc.id);
  }

  String _timestampToString(dynamic ts) {
    if (ts == null) return DateTime.now().toIso8601String();
    if (ts is Timestamp) return ts.toDate().toIso8601String();
    if (ts is String) return ts;
    return DateTime.now().toIso8601String();
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  /// Get all active listings
  Future<List<RoomListing>> getListings() async {
    final snap = await _db
        .collection(_collection)
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map(_docToListing).toList();
  }

  /// Get listing by ID
  Future<RoomListing?> getListingById(String id) async {
    final doc = await _db.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return _docToListing(doc);
  }

  /// Get listings by category (active only)
  Future<List<RoomListing>> getListingsByCategory(String category) async {
    final snap = await _db
        .collection(_collection)
        .where('category', isEqualTo: category)
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map(_docToListing).toList();
  }

  /// Get listings by user ID
  Future<List<RoomListing>> getListingsByUserId(String userId, {bool onlyActive = false}) async {
    Query q = _db.collection(_collection).where('userId', isEqualTo: userId);
    if (onlyActive) {
      q = q.where('status', isEqualTo: 'active');
    }
    q = q.orderBy('createdAt', descending: true);
    final snap = await q.get();
    return snap.docs.map((d) => _docToListing(d as DocumentSnapshot)).toList();
  }

  /// Generate a listing ID based on category
  String generateListingId(String category) {
    final prefix = category == 'sublease'
        ? 'sl'
        : category == 'short-term'
            ? 'st'
            : category == 'roomshare'
                ? 'rs'
                : 'rm';
    return '$prefix-${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Create a listing. If [id] is provided, uses it; otherwise auto-generates.
  Future<String> createListing(Map<String, dynamic> data, {String? id}) async {
    final category = data['category'] ?? 'roommate';
    id ??= generateListingId(category);

    await _db.collection(_collection).doc(id).set({
      ...data,
      'id': id,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'viewCount': 0,
      'favoriteCount': 0,
    });

    return id;
  }

  /// Update a listing
  Future<void> updateListing(String id, Map<String, dynamic> data) async {
    await _db.collection(_collection).doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete a listing (soft delete)
  Future<void> deleteListing(String id) async {
    await _db.collection(_collection).doc(id).update({
      'status': 'deleted',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Increment view count
  Future<void> incrementViewCount(String id) async {
    try {
      await _db.collection(_collection).doc(id).update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (_) {}
  }
}
