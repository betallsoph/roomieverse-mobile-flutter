import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/neo_brutal.dart';
import '../../../data/constants.dart';

class SharedPreferencesStep extends StatelessWidget {
  final String? selectedGender;
  final ValueChanged<String?> onGenderChanged;
  final String? selectedStatus;
  final ValueChanged<String?> onStatusChanged;
  final String? selectedSchedule;
  final ValueChanged<String?> onScheduleChanged;
  final String? selectedCleanliness;
  final ValueChanged<String?> onCleanlinessChanged;
  final String? selectedHabits;
  final ValueChanged<String?> onHabitsChanged;
  final String? selectedPets;
  final ValueChanged<String?> onPetsChanged;
  final String? selectedMoveInTime;
  final ValueChanged<String?> onMoveInTimeChanged;
  final TextEditingController otherController;
  final Widget bottomActions;

  const SharedPreferencesStep({
    super.key,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.selectedSchedule,
    required this.onScheduleChanged,
    required this.selectedCleanliness,
    required this.onCleanlinessChanged,
    required this.selectedHabits,
    required this.onHabitsChanged,
    required this.selectedPets,
    required this.onPetsChanged,
    required this.selectedMoveInTime,
    required this.onMoveInTimeChanged,
    required this.otherController,
    required this.bottomActions,
  });

  void _toggle(String value, String? current, ValueChanged<String?> onChanged) {
    onChanged(current == value ? null : value);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Yêu cầu bạn ở',
            style: TextStyle(fontFamily: 'Google Sans', fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Mô tả bạn cùng phòng lý tưởng',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          _sectionTitle('Giới tính *'),
          _buildSingleSelect(genderOptions, selectedGender, onGenderChanged, AppColors.blue),
          const SizedBox(height: 20),

          _sectionTitle('Tình trạng *'),
          _buildSingleSelect(statusOptions, selectedStatus, onStatusChanged, AppColors.purple),
          const SizedBox(height: 20),

          _sectionTitle('Lịch trình *'),
          _buildSingleSelect(scheduleOptions, selectedSchedule, onScheduleChanged, AppColors.orange),
          const SizedBox(height: 20),

          _sectionTitle('Mức độ sạch sẽ *'),
          _buildSingleSelect(cleanlinessOptions, selectedCleanliness, onCleanlinessChanged, AppColors.emerald),
          const SizedBox(height: 20),

          _sectionTitle('Thói quen *'),
          _buildSingleSelect(habitOptions, selectedHabits, onHabitsChanged, AppColors.pink),
          const SizedBox(height: 20),

          _sectionTitle('Thú cưng *'),
          _buildSingleSelect(petOptions, selectedPets, onPetsChanged, AppColors.yellow),
          const SizedBox(height: 20),

          _sectionTitle('Thời gian dọn vào *'),
          _buildSingleSelect(moveInTimeOptions, selectedMoveInTime, onMoveInTimeChanged, AppColors.blueLight),
          const SizedBox(height: 20),

          NeoBrutalTextField(
            label: 'Yêu cầu khác',
            hint: 'Thêm yêu cầu đặc biệt nếu có...',
            controller: otherController,
            maxLines: 3,
          ),

          const SizedBox(height: 24),
          bottomActions,
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSingleSelect(
    List<(String, String)> options,
    String? selected,
    ValueChanged<String?> onChanged,
    Color color,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        return NeoBrutalChip(
          label: opt.$2,
          selected: selected == opt.$1,
          selectedColor: color,
          onTap: () => _toggle(opt.$1, selected, onChanged),
        );
      }).toList(),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Google Sans',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
