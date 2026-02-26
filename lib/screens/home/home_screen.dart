import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../providers/listing_provider.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/shimmer_loading.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(listingsProvider);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(listingsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Logo bar ──
              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Image.asset(
                    'assets/images/logo1.png',
                    height: 64,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Tin mới nhất ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tin mới nhất',
                      style: TextStyle(
                        fontFamily: 'Google Sans',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/browse'),
                      child: const Row(
                        children: [
                          Text(
                            'Xem tất cả',
                            style: TextStyle(
                              fontFamily: 'Google Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.blueDark,
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(LucideIcons.arrowRight, size: 16, color: AppColors.blueDark),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              listingsAsync.when(
                data: (listings) {
                  if (listings.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black.withValues(alpha: 0.1), width: 1),
                        ),
                        child: const Column(
                          children: [
                            Icon(LucideIcons.inbox, size: 36, color: AppColors.textTertiary),
                            SizedBox(height: 8),
                            Text(
                              'Chưa có tin đăng nào',
                              style: TextStyle(
                                fontFamily: 'Google Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  final featured = listings.take(8).toList();
                  return SizedBox(
                    height: 230,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: featured.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) => SizedBox(
                        width: 260,
                        child: ListingCard(
                          listing: featured[index],
                          compact: true,
                          onTap: () => context.push('/listing/${featured[index].id}'),
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const ShimmerHorizontalList(),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(child: Text('Lỗi: $e')),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
