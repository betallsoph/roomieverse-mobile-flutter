import 'package:flutter/material.dart';
import '../models/listing.dart';
import '../theme/app_theme.dart';
import '../data/constants.dart';

/// Displays roommate preferences as labeled rows with value chips.
class PreferencesCard extends StatelessWidget {
  final RoommatePreferences preferences;
  final Color accentColor;

  const PreferencesCard({
    super.key,
    required this.preferences,
    this.accentColor = AppColors.blue,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <_PrefRow>[];

    void addRow(String label, String? value, List<(String, String)> options) {
      final displayLabel = getOptionLabel(options, value);
      if (displayLabel != null) {
        rows.add(_PrefRow(label: label, value: displayLabel));
      }
    }

    addRow('Giới tính', preferences.gender, genderOptions);
    addRow('Nghề nghiệp', preferences.status, statusOptions);
    addRow('Lịch trình', preferences.schedule, scheduleOptions);
    addRow('Sạch sẽ', preferences.cleanliness, cleanlinessOptions);
    addRow('Thói quen', preferences.habits, habitOptions);
    addRow('Thú cưng', preferences.pets, petOptions);
    addRow('Thời gian vào', preferences.moveInTime, moveInTimeOptions);

    if (preferences.other != null && preferences.other!.isNotEmpty) {
      rows.add(_PrefRow(label: 'Khác', value: preferences.other!));
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Yêu cầu roommate',
          style: TextStyle(
            fontFamily: 'Google Sans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Column(
            children: rows.asMap().entries.map((entry) {
              final row = entry.value;
              final isLast = entry.key == rows.length - 1;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Text(
                          row.label,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            row.value,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    const Divider(height: 0, thickness: 1, color: Color(0xFFE5E7EB)),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _PrefRow {
  final String label;
  final String value;
  const _PrefRow({required this.label, required this.value});
}
