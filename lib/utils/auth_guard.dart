import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

/// Returns true if user is authenticated. If not, pushes to auth screen.
bool requireAuth(BuildContext context, WidgetRef ref) {
  final user = ref.read(authStateProvider).valueOrNull;
  if (user == null) {
    context.push('/auth');
    return false;
  }
  return true;
}
