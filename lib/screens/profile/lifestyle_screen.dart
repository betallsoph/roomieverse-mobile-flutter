import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../theme/neo_brutal.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_profile.dart';
import '../../data/constants.dart';

class LifestyleScreen extends ConsumerStatefulWidget {
  const LifestyleScreen({super.key});

  @override
  ConsumerState<LifestyleScreen> createState() => _LifestyleScreenState();
}

class _LifestyleScreenState extends ConsumerState<LifestyleScreen> {
  List<String> _schedule = [];
  String? _cleanliness;
  List<String> _habits = [];
  List<String> _pets = [];
  final _otherController = TextEditingController();
  bool _isLoading = false;
  bool _loaded = false;

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  void _loadFromProfile() {
    if (_loaded) return;
    final profile = ref.read(currentUserProfileProvider).valueOrNull;
    if (profile?.lifestyle != null) {
      final ls = profile!.lifestyle!;
      _schedule = List<String>.from(ls.schedule ?? []);
      _habits = List<String>.from(ls.habits ?? []);
      _otherController.text = ls.otherHabits ?? '';
      if (ls.cleanliness != null && ls.cleanliness!.isNotEmpty) {
        _cleanliness = ls.cleanliness!.first;
      }
    }
    _loaded = true;
  }

  void _toggleInList(List<String> list, String value) {
    setState(() {
      list.contains(value) ? list.remove(value) : list.add(value);
    });
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);

    try {
      final profile = ref.read(currentUserProfileProvider).valueOrNull;
      if (profile == null) return;

      final lifestyle = LifestylePreferences(
        schedule: _schedule.isNotEmpty ? _schedule : null,
        cleanliness: _cleanliness != null ? [_cleanliness!] : null,
        habits: _habits.isNotEmpty ? _habits : null,
        otherHabits: _otherController.text.trim().isNotEmpty ? _otherController.text.trim() : null,
      );

      final updated = profile.copyWith(lifestyle: lifestyle);
      await ref.read(userServiceProvider).saveProfile(updated);
      ref.invalidate(currentUserProfileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã lưu lối sống'), backgroundColor: Colors.black),
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
        title: const Text('Hồ sơ lối sống'),
      ),
      body: profileAsync.when(
        data: (profile) {
          _loadFromProfile();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chia sẻ thói quen và sở thích để tìm roommate phù hợp',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 24),

                // Schedule
                _sectionTitle('Lịch trình'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: scheduleOptions.map((opt) {
                    return NeoBrutalChip(
                      label: opt.$2,
                      selected: _schedule.contains(opt.$1),
                      selectedColor: AppColors.orange,
                      onTap: () => _toggleInList(_schedule, opt.$1),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Cleanliness
                _sectionTitle('Mức độ sạch sẽ'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: cleanlinessOptions.map((opt) {
                    return NeoBrutalChip(
                      label: opt.$2,
                      selected: _cleanliness == opt.$1,
                      selectedColor: AppColors.blue,
                      onTap: () => setState(() {
                        _cleanliness = _cleanliness == opt.$1 ? null : opt.$1;
                      }),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Habits
                _sectionTitle('Thói quen'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: habitOptions.map((opt) {
                    return NeoBrutalChip(
                      label: opt.$2,
                      selected: _habits.contains(opt.$1),
                      selectedColor: AppColors.pink,
                      onTap: () => _toggleInList(_habits, opt.$1),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Pets
                _sectionTitle('Thú cưng'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: petOptions.map((opt) {
                    return NeoBrutalChip(
                      label: opt.$2,
                      selected: _pets.contains(opt.$1),
                      selectedColor: AppColors.emerald,
                      onTap: () => _toggleInList(_pets, opt.$1),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Other
                NeoBrutalTextField(
                  label: 'Khác',
                  hint: 'Thói quen hoặc sở thích khác...',
                  controller: _otherController,
                  maxLines: 3,
                ),
                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: NeoBrutalButton(
                        label: 'Để sau',
                        backgroundColor: Colors.white,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: NeoBrutalButton(
                        label: 'Lưu thay đổi',
                        backgroundColor: AppColors.blue,
                        expanded: true,
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _save,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Google Sans',
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
