import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/neo_brutal.dart';
import '../../../widgets/neo_brutal_slider.dart';
import '../../../data/constants.dart';

class StepPreferences extends StatelessWidget {
  final List<String> selectedGender;
  final ValueChanged<List<String>> onGenderChanged;
  final List<String> selectedStatus;
  final ValueChanged<List<String>> onStatusChanged;
  final List<String> selectedSchedule;
  final ValueChanged<List<String>> onScheduleChanged;
  final int cleanlinessLevel;
  final ValueChanged<int> onCleanlinessChanged;
  final List<String> selectedHabits;
  final ValueChanged<List<String>> onHabitsChanged;
  final List<String> selectedPets;
  final ValueChanged<List<String>> onPetsChanged;
  final List<String> selectedMoveInTime;
  final ValueChanged<List<String>> onMoveInTimeChanged;
  final TextEditingController otherController;

  const StepPreferences({
    super.key,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.selectedSchedule,
    required this.onScheduleChanged,
    required this.cleanlinessLevel,
    required this.onCleanlinessChanged,
    required this.selectedHabits,
    required this.onHabitsChanged,
    required this.selectedPets,
    required this.onPetsChanged,
    required this.selectedMoveInTime,
    required this.onMoveInTimeChanged,
    required this.otherController,
  });

  void _toggleInList(List<String> current, String value, ValueChanged<List<String>> onChanged) {
    final newList = List<String>.from(current);
    newList.contains(value) ? newList.remove(value) : newList.add(value);
    onChanged(newList);
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

          // Gender
          _sectionTitle('Giới tính'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: genderOptions.map((opt) {
              return NeoBrutalChip(
                label: opt.$2,
                selected: selectedGender.contains(opt.$1),
                selectedColor: AppColors.blue,
                onTap: () => _toggleInList(selectedGender, opt.$1, onGenderChanged),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Status
          _sectionTitle('Tình trạng'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: statusOptions.map((opt) {
              return NeoBrutalChip(
                label: opt.$2,
                selected: selectedStatus.contains(opt.$1),
                selectedColor: AppColors.purple,
                onTap: () => _toggleInList(selectedStatus, opt.$1, onStatusChanged),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Schedule
          _sectionTitle('Lịch trình'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: scheduleOptions.map((opt) {
              return NeoBrutalChip(
                label: opt.$2,
                selected: selectedSchedule.contains(opt.$1),
                selectedColor: AppColors.orange,
                onTap: () => _toggleInList(selectedSchedule, opt.$1, onScheduleChanged),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Cleanliness
          _sectionTitle('Mức độ sạch sẽ'),
          const SizedBox(height: 4),
          NeoBrutalSlider(
            value: cleanlinessLevel,
            max: 3,
            labels: cleanlinessLabels,
            onChanged: onCleanlinessChanged,
          ),
          const SizedBox(height: 20),

          // Habits
          _sectionTitle('Thói quen'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: habitOptions.map((opt) {
              return NeoBrutalChip(
                label: opt.$2,
                selected: selectedHabits.contains(opt.$1),
                selectedColor: AppColors.pink,
                onTap: () => _toggleInList(selectedHabits, opt.$1, onHabitsChanged),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Pets
          _sectionTitle('Thú cưng'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: petOptions.map((opt) {
              return NeoBrutalChip(
                label: opt.$2,
                selected: selectedPets.contains(opt.$1),
                selectedColor: AppColors.emerald,
                onTap: () => _toggleInList(selectedPets, opt.$1, onPetsChanged),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Move-in time
          _sectionTitle('Thời gian dọn vào'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: moveInTimeOptions.map((opt) {
              return NeoBrutalChip(
                label: opt.$2,
                selected: selectedMoveInTime.contains(opt.$1),
                selectedColor: AppColors.yellow,
                onTap: () => _toggleInList(selectedMoveInTime, opt.$1, onMoveInTimeChanged),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Other
          NeoBrutalTextField(
            label: 'Yêu cầu khác',
            hint: 'Thêm yêu cầu đặc biệt nếu có...',
            controller: otherController,
            maxLines: 3,
          ),

          const SizedBox(height: 40),
        ],
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
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
