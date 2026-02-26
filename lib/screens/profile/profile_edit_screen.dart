import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../theme/neo_brutal.dart';
import '../../providers/auth_provider.dart';
import '../../data/constants.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  String? _gender;
  final _birthYearController = TextEditingController();
  final _occupationController = TextEditingController();
  bool _isLoading = false;
  bool _loaded = false;

  @override
  void dispose() {
    _birthYearController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  void _loadProfile() {
    if (_loaded) return;
    final profile = ref.read(currentUserProfileProvider).valueOrNull;
    if (profile != null) {
      _gender = profile.gender;
      _birthYearController.text = profile.birthYear ?? '';
      _occupationController.text = profile.occupation ?? '';
      _loaded = true;
    }
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);

    try {
      final profile = ref.read(currentUserProfileProvider).valueOrNull;
      if (profile == null) return;

      final updated = profile.copyWith(
        gender: _gender,
        birthYear: _birthYearController.text.trim().isNotEmpty ? _birthYearController.text.trim() : null,
        occupation: _occupationController.text.trim().isNotEmpty ? _occupationController.text.trim() : null,
      );

      await ref.read(userServiceProvider).saveProfile(updated);
      ref.invalidate(currentUserProfileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã lưu thay đổi'), backgroundColor: Colors.black),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.black),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Chỉnh sửa hồ sơ'),
      ),
      body: profileAsync.when(
        data: (profile) {
          _loadProfile();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gender
                const Text(
                  'Giới tính',
                  style: TextStyle(fontFamily: 'Google Sans', fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Row(
                  children: genderOptions.where((g) => g.$1 != 'any').map((opt) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: NeoBrutalChip(
                        label: opt.$2,
                        selected: _gender == opt.$2,
                        selectedColor: AppColors.blue,
                        onTap: () => setState(() => _gender = opt.$2),
                      ),
                    );
                  }).toList()
                  ..add(
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: NeoBrutalChip(
                        label: 'Khác',
                        selected: _gender == 'Khác',
                        selectedColor: AppColors.blue,
                        onTap: () => setState(() => _gender = 'Khác'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Birth year
                NeoBrutalTextField(
                  label: 'Năm sinh',
                  hint: 'VD: 2000',
                  controller: _birthYearController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),

                // Occupation
                NeoBrutalTextField(
                  label: 'Nghề nghiệp',
                  hint: 'VD: Sinh viên, Kỹ sư, Designer...',
                  controller: _occupationController,
                ),
                const SizedBox(height: 32),

                NeoBrutalButton(
                  label: 'Lưu thay đổi',
                  backgroundColor: AppColors.blue,
                  expanded: true,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _save,
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
      ),
    );
  }
}
