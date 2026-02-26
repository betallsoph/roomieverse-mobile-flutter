import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const _collection = 'users';

  /// Get user profile
  Future<UserProfile?> getProfile(String uid) async {
    final doc = await _db.collection(_collection).doc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data() ?? {};
    data['uid'] = uid;
    return UserProfile.fromJson(data);
  }

  /// Create or update user profile
  Future<void> saveProfile(UserProfile profile) async {
    await _db.collection(_collection).doc(profile.uid).set(
      {
        ...profile.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Create profile on first sign-in
  Future<void> createProfileIfNotExists({
    required String uid,
    required String email,
    required String displayName,
    String? photoURL,
  }) async {
    final doc = await _db.collection(_collection).doc(uid).get();
    if (!doc.exists) {
      await _db.collection(_collection).doc(uid).set({
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'photoURL': photoURL,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
