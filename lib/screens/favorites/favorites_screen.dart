import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../theme/neo_brutal.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/listing_provider.dart';

import '../../widgets/listing_card.dart';
import '../../widgets/shimmer_loading.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: const Text('Yêu thích')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite_border, size: 64, color: AppColors.textTertiary),
              const SizedBox(height: 16),
              const Text(
                'Đăng nhập để lưu yêu thích',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              NeoBrutalButton(
                label: 'Đăng nhập',
                backgroundColor: AppColors.blueLight,
                onPressed: () => context.push('/auth'),
              ),
            ],
          ),
        ),
      );
    }

    final favoriteIds = ref.watch(favoritesNotifierProvider);
    final listingsAsync = ref.watch(listingsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Yêu thích')),
      body: listingsAsync.when(
        data: (allListings) {
          final favListings = allListings
              .where((l) => favoriteIds.contains(l.id))
              .toList();
          if (favListings.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 48, color: AppColors.textTertiary),
                  SizedBox(height: 12),
                  Text(
                    'Chưa có tin yêu thích',
                    style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: favListings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return ListingCard(
                listing: favListings[index],
                onTap: () => context.push('/listing/${favListings[index].id}'),
              );
            },
          );
        },
        loading: () => const ShimmerListingList(),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
      ),
    );
  }
}
