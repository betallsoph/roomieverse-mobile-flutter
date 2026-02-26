import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../theme/neo_brutal.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_profile.dart';

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

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hồ sơ',
              style: TextStyle(
                fontFamily: 'Google Sans',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // Profile card
            NeoBrutalCard(
              backgroundColor: AppColors.backgroundBlue,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.backgroundBlue,
                    backgroundImage: user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : null,
                    child: user.photoURL == null
                        ? Text(
                            (user.displayName ?? user.email ?? '?')[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
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
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.email ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Profile details
            profileAsync.when(
              data: (profile) {
                if (profile == null) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: NeoBrutalCard(
                      backgroundColor: AppColors.yellowLight,
                      child: Column(
                        children: [
                          const Text(
                            'Hoàn thành hồ sơ để tìm roommate phù hợp hơn!',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          NeoBrutalButton(
                            label: 'Cập nhật hồ sơ',
                            backgroundColor: AppColors.blueLight,
                            onPressed: () => context.push('/profile/edit'),
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

            const SizedBox(height: 20),

            // Menu items
            _MenuItem(
              label: 'Cập nhật hồ sơ',
              onTap: () => context.push('/profile/edit'),
            ),
            _MenuItem(
              label: 'Hồ sơ lối sống',
              onTap: () => context.push('/profile/lifestyle'),
            ),
            _MenuItem(
              label: 'Yêu thích',
              onTap: () => context.push('/favorites'),
            ),
            _MenuItem(
              label: 'Tin đã đăng',
              onTap: () => context.push('/profile/listings'),
            ),
            _MenuItem(
              label: 'Cài đặt',
              onTap: () => context.push('/settings'),
            ),

            const SizedBox(height: 24),

            NeoBrutalButton(
              label: 'Đăng xuất',
              backgroundColor: AppColors.red,
              expanded: true,
              onPressed: () async {
                await ref.read(authServiceProvider).signOut();
              },
            ),
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
            NeoBrutalButton(
              label: 'Đăng nhập / Đăng ký',
              backgroundColor: AppColors.blueLight,
              expanded: true,
              fontSize: 16,
              onPressed: () => context.push('/auth'),
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
          NeoBrutalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thông tin cá nhân',
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                if (profile.gender != null) _infoRow('Giới tính', profile.gender!),
                if (profile.birthYear != null) _infoRow('Năm sinh', profile.birthYear!),
                if (profile.occupation != null) _infoRow('Nghề nghiệp', profile.occupation!),
              ],
            ),
          ),
        if (profile.lifestyle != null) ...[
          const SizedBox(height: 12),
          NeoBrutalCard(
            backgroundColor: AppColors.pinkLight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lối sống',
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                if (profile.lifestyle!.schedule != null && profile.lifestyle!.schedule!.isNotEmpty)
                  _chipRow('Lịch trình', profile.lifestyle!.schedule!),
                if (profile.lifestyle!.cleanliness != null && profile.lifestyle!.cleanliness!.isNotEmpty)
                  _chipRow('Sạch sẽ', profile.lifestyle!.cleanliness!),
                if (profile.lifestyle!.habits != null && profile.lifestyle!.habits!.isNotEmpty)
                  _chipRow('Thói quen', profile.lifestyle!.habits!),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textTertiary)),
          const SizedBox(width: 12),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _chipRow(String label, List<String> values) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textTertiary)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: values.map((v) => NeoBrutalChip(label: v, selected: true, selectedColor: AppColors.pinkLight)).toList(),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black12)),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
