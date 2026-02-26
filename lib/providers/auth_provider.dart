import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_profile.dart';

final authServiceProvider = Provider((ref) => AuthService());
final userServiceProvider = Provider((ref) => UserService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final userProfileProvider = FutureProvider.family<UserProfile?, String>((ref, uid) async {
  return ref.watch(userServiceProvider).getProfile(uid);
});

final currentUserProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final user = authState.valueOrNull;
  if (user == null) return null;
  return ref.watch(userServiceProvider).getProfile(user.uid);
});
