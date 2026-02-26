import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../theme/neo_brutal.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Cài đặt'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App info
            NeoBrutalCard(
              backgroundColor: AppColors.backgroundSky,
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.blue,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset('assets/images/logo1.png', fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'roomieVerse',
                        style: TextStyle(
                          fontFamily: 'Google Sans',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Phiên bản 1.0.0',
                        style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Chung',
              style: TextStyle(
                fontFamily: 'Google Sans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            _SettingItem(
              icon: LucideIcons.globe,
              label: 'Ngôn ngữ',
              trailing: 'Tiếng Việt',
            ),

            const SizedBox(height: 24),
            const Text(
              'Hỗ trợ',
              style: TextStyle(
                fontFamily: 'Google Sans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            _SettingItem(
              icon: LucideIcons.mail,
              label: 'Liên hệ',
              trailing: 'roomieversebyantt@gmail.com',
              onTap: () => _launchUrl('mailto:roomieversebyantt@gmail.com'),
            ),
            _SettingItem(
              icon: LucideIcons.externalLink,
              label: 'Website',
              trailing: 'roomieverse.blog',
              onTap: () => _launchUrl('https://roomieverse.blog'),
            ),
            _SettingItem(
              icon: LucideIcons.fileText,
              label: 'Điều khoản sử dụng',
              onTap: () => _launchUrl('https://roomieverse.blog/about'),
            ),
            _SettingItem(
              icon: LucideIcons.shield,
              label: 'Chính sách bảo mật',
              onTap: () => _launchUrl('https://roomieverse.blog/about'),
            ),

            const SizedBox(height: 24),

            // Credits
            Center(
              child: Text(
                'Made with love by antt',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback? onTap;

  const _SettingItem({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black12)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (trailing != null)
              Text(
                trailing!,
                style: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
              ),
            if (onTap != null)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textTertiary),
              ),
          ],
        ),
      ),
    );
  }
}
