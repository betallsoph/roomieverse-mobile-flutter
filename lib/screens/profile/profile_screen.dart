import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listing_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../models/user_profile.dart';
import '../profile/my_listings_screen.dart' show userListingsProvider;
import '../../widgets/listing_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;

    if (user == null) {
      return _AuthPrompt();
    }

    final profileAsync = ref.watch(userProfileProvider(user.uid));
    final favoriteIds = ref.watch(favoritesNotifierProvider);
    final allListingsAsync = ref.watch(listingsProvider);
    final userListingsAsync = ref.watch(userListingsProvider);

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                'Hồ sơ',
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            
            const SizedBox(height: 24),

            // Profile Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : null,
                    child: user.photoURL == null
                        ? Text(
                            (user.displayName ?? user.email ?? '?')[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName ?? 'Người dùng',
                          style: const TextStyle(
                            fontFamily: 'Google Sans',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Profile details
            profileAsync.when(
              data: (profile) {
                if (profile == null) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hoàn thành hồ sơ',
                                  style: TextStyle(
                                    fontFamily: 'Google Sans',
                                    fontSize: 16, 
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.blueDark,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Để tìm roommate phù hợp hơn với bạn',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          FilledButton(
                            onPressed: () => context.push('/profile/edit'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.blueDark,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            child: const Text('Cập nhật', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return _ProfileDetails(profile: profile);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 24),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 16),

            // Favorites preview
            allListingsAsync.when(
              data: (all) {
                final favListings =
                    all.where((l) => favoriteIds.contains(l.id)).toList();
                if (favListings.isEmpty) return const SizedBox.shrink();
                final preview = favListings.take(3).toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tin yêu thích',
                            style: TextStyle(
                              fontFamily: 'Google Sans',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push('/favorites'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.blueDark,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Xem tất cả',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: preview.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final listing = preview[index];
                          return SizedBox(
                            width: 280,
                            child: ListingCard(
                              listing: listing,
                              onTap: () => context.push('/listing/${listing.id}'),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
                    const SizedBox(height: 16),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // User listings preview
            userListingsAsync.when(
              data: (listings) {
                if (listings.isEmpty) return const SizedBox.shrink();
                final preview = listings.take(3).toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tin đã đăng',
                            style: TextStyle(
                              fontFamily: 'Google Sans',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push('/profile/listings'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.blueDark,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Xem tất cả',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: preview.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final listing = preview[index];
                          return SizedBox(
                            width: 280,
                            child: ListingCard(
                              listing: listing,
                              showStatus: true,
                              onTap: () => context.push('/listing/${listing.id}'),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
                    const SizedBox(height: 8),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // Menu items
            _MenuItem(
              icon: LucideIcons.user,
              label: 'Cập nhật hồ sơ',
              onTap: () => context.push('/profile/edit'),
            ),
            _MenuItem(
              icon: LucideIcons.coffee,
              label: 'Hồ sơ lối sống',
              onTap: () => context.push('/profile/lifestyle'),
            ),
            _MenuItem(
              icon: LucideIcons.heart,
              label: 'Yêu thích',
              onTap: () => context.push('/favorites'),
            ),
            _MenuItem(
              icon: LucideIcons.list,
              label: 'Tin đã đăng',
              onTap: () => context.push('/profile/listings'),
            ),
            _MenuItem(
              icon: LucideIcons.settings,
              label: 'Cài đặt',
              onTap: () => context.push('/settings'),
            ),

            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton(
                onPressed: () async {
                  await ref.read(authServiceProvider).signOut();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red[600],
                  side: BorderSide(color: Colors.red[200]!, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(double.infinity, 52),
                ),
                child: const Text(
                  'Đăng xuất',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _AuthPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo1.png', height: 80),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () => context.push('/auth'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.blueDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 52),
              ),
              child: const Text(
                'Đăng nhập / Đăng ký',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileDetails extends StatelessWidget {
  final UserProfile profile;
  const _ProfileDetails({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (profile.gender != null || profile.birthYear != null || profile.occupation != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thông tin cá nhân',
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    if (profile.gender != null) _infoRow('Giới tính', profile.gender!),
                    if (profile.gender != null && (profile.birthYear != null || profile.occupation != null)) const Divider(height: 24, color: Color(0xFFE5E7EB)),
                    if (profile.birthYear != null) _infoRow('Năm sinh', profile.birthYear!),
                    if (profile.birthYear != null && profile.occupation != null) const Divider(height: 24, color: Color(0xFFE5E7EB)),
                    if (profile.occupation != null) _infoRow('Nghề nghiệp', profile.occupation!),
                  ],
                ),
              ],
            ),
          ),
        
        if (profile.lifestyle != null && 
           ((profile.lifestyle!.schedule?.isNotEmpty ?? false) || 
            (profile.lifestyle!.cleanliness?.isNotEmpty ?? false) || 
            (profile.lifestyle!.habits?.isNotEmpty ?? false))) ...[
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lối sống',
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (profile.lifestyle!.schedule != null && profile.lifestyle!.schedule!.isNotEmpty)
                      _chipRow('Lịch trình', profile.lifestyle!.schedule!),
                    
                    if (profile.lifestyle!.schedule != null && profile.lifestyle!.schedule!.isNotEmpty && 
                       ((profile.lifestyle!.cleanliness?.isNotEmpty ?? false) || (profile.lifestyle!.habits?.isNotEmpty ?? false)))
                      const SizedBox(height: 20),

                    if (profile.lifestyle!.cleanliness != null && profile.lifestyle!.cleanliness!.isNotEmpty)
                      _chipRow('Sạch sẽ', profile.lifestyle!.cleanliness!),
                    
                    if (profile.lifestyle!.cleanliness != null && profile.lifestyle!.cleanliness!.isNotEmpty && 
                       (profile.lifestyle!.habits?.isNotEmpty ?? false))
                      const SizedBox(height: 20),

                    if (profile.lifestyle!.habits != null && profile.lifestyle!.habits!.isNotEmpty)
                      _chipRow('Thói quen', profile.lifestyle!.habits!),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textTertiary)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _chipRow(String label, List<String> values) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textTertiary)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values.map((v) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              v,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          children: [
            Icon(icon, size: 24, color: AppColors.textSecondary),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            const Icon(LucideIcons.chevronRight, size: 20, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
