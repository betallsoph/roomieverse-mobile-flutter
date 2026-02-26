import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/favorite_service.dart';
import 'auth_provider.dart';

final favoriteServiceProvider = Provider((ref) => FavoriteService());

final favoritesProvider = FutureProvider<List<String>>((ref) async {
  final authState = ref.watch(authStateProvider);
  final user = authState.valueOrNull;
  if (user == null) return [];
  return ref.watch(favoriteServiceProvider).getUserFavorites(user.uid);
});

class FavoritesNotifier extends StateNotifier<Set<String>> {
  final FavoriteService _service;
  final String? _userId;

  FavoritesNotifier(this._service, this._userId) : super({}) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    if (_userId == null) return;
    final ids = await _service.getUserFavorites(_userId);
    state = ids.toSet();
  }

  Future<void> toggle(String listingId) async {
    if (_userId == null) return;
    final nowFavorited = await _service.toggleFavorite(_userId, listingId);
    if (nowFavorited) {
      state = {...state, listingId};
    } else {
      state = state.where((id) => id != listingId).toSet();
    }
  }

  bool isFavorited(String listingId) => state.contains(listingId);
}

final favoritesNotifierProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  final service = ref.watch(favoriteServiceProvider);
  final authState = ref.watch(authStateProvider);
  final userId = authState.valueOrNull?.uid;
  return FavoritesNotifier(service, userId);
});
