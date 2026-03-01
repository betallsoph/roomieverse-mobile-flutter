import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listing_provider.dart';
import '../../models/listing.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/empty_state.dart';

final userListingsProvider = FutureProvider<List<RoomListing>>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return [];
  return ref.watch(listingServiceProvider).getListingsByUserId(user.uid);
});

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(userListingsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tin đã đăng'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus, size: 20),
            onPressed: () => context.push('/create-listing'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userListingsProvider);
        },
        child: listingsAsync.when(
          data: (listings) {
            if (listings.isEmpty) {
              return EmptyState(
                icon: LucideIcons.fileText,
                title: 'Chưa có tin đăng nào',
                subtitle: 'Đăng tin ngay để tìm bạn ở ghép hoặc cho thuê phòng',
                actionLabel: 'Đăng tin',
                onAction: () => context.push('/create-listing'),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: listings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final listing = listings[index];
                return SizedBox(
                  height: 230,
                  child: ListingCard(
                    listing: listing,
                    showStatus: true,
                    onTap: () => context.push('/listing/${listing.id}'),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Lỗi: $e')),
        ),
      ),
    );
  }
}
