import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/neo_brutal.dart';
import '../../../widgets/neo_brutal_dropdown.dart';
import '../../../data/constants.dart';

class StepBasicInfo extends StatelessWidget {
  final String category;
  final String? roommateType;
  final ValueChanged<String> onRoommateTypeChanged;
  final TextEditingController titleController;
  final TextEditingController introController;
  final TextEditingController addressController;
  final TextEditingController buildingController;
  final TextEditingController priceController;
  final TextEditingController moveInController;
  final String? selectedCity;
  final String? selectedDistrict;
  final ValueChanged<String?> onCityChanged;
  final ValueChanged<String?> onDistrictChanged;
  final List<String> selectedPropertyTypes;
  final ValueChanged<List<String>> onPropertyTypesChanged;
  final bool locationNegotiable;
  final ValueChanged<bool> onLocationNegotiableChanged;
  final bool timeNegotiable;
  final ValueChanged<bool> onTimeNegotiableChanged;

  const StepBasicInfo({
    super.key,
    required this.category,
    this.roommateType,
    required this.onRoommateTypeChanged,
    required this.titleController,
    required this.introController,
    required this.addressController,
    required this.buildingController,
    required this.priceController,
    required this.moveInController,
    this.selectedCity,
    this.selectedDistrict,
    required this.onCityChanged,
    required this.onDistrictChanged,
    required this.selectedPropertyTypes,
    required this.onPropertyTypesChanged,
    required this.locationNegotiable,
    required this.onLocationNegotiableChanged,
    required this.timeNegotiable,
    required this.onTimeNegotiableChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin cơ bản',
            style: TextStyle(
              fontFamily: 'Google Sans',
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Điền thông tin cơ bản về tin đăng của bạn',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          // Roommate type selector (only for roommate category)
          if (category == 'roommate') ...[
            const Text(
              'Bạn muốn gì? *',
              style: TextStyle(fontFamily: 'Google Sans', fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...roommateTypeOptions.map((opt) {
              final isSelected = roommateType == opt.$1;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: NeoBrutalCard(
                  backgroundColor: isSelected ? AppColors.blue.withValues(alpha: 0.3) : Colors.white,
                  onTap: () => onRoommateTypeChanged(opt.$1),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Icon(
                        opt.$1 == 'have-room' ? LucideIcons.home : LucideIcons.search,
                        size: 20,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          opt.$2,
                          style: TextStyle(
                            fontFamily: 'Google Sans',
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isSelected) const Icon(LucideIcons.check, size: 18, color: AppColors.blueDark),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
          ],

          // Title
          NeoBrutalTextField(
            label: 'Tiêu đề *',
            hint: 'VD: Tìm bạn ở ghép quận 7, gần Lotte',
            controller: titleController,
          ),
          const SizedBox(height: 14),

          // Introduction
          NeoBrutalTextField(
            label: 'Giới thiệu',
            hint: 'Viết mô tả ngắn về bản thân hoặc phòng...',
            controller: introController,
            maxLines: 4,
          ),
          const SizedBox(height: 14),

          // Property types
          const Text(
            'Loại hình',
            style: TextStyle(fontFamily: 'Google Sans', fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: propertyTypeOptions.map((opt) {
              final isSelected = selectedPropertyTypes.contains(opt.$1);
              return NeoBrutalChip(
                label: opt.$2,
                selected: isSelected,
                selectedColor: AppColors.blue,
                onTap: () {
                  final newList = List<String>.from(selectedPropertyTypes);
                  isSelected ? newList.remove(opt.$1) : newList.add(opt.$1);
                  onPropertyTypesChanged(newList);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // City
          NeoBrutalDropdown<String>(
            label: 'Thành phố *',
            hint: 'Chọn thành phố',
            value: selectedCity,
            items: cities.map((c) => (c.value, c.label)).toList(),
            onChanged: (val) {
              onCityChanged(val);
              onDistrictChanged(null);
            },
          ),
          const SizedBox(height: 14),

          // District
          NeoBrutalDropdown<String>(
            label: 'Quận / Huyện *',
            hint: 'Chọn quận / huyện',
            value: selectedDistrict,
            items: selectedCity != null
                ? getDistrictsByCity(selectedCity!).map((d) => (d.value, d.label)).toList()
                : [],
            onChanged: onDistrictChanged,
          ),
          const SizedBox(height: 14),

          // Address
          NeoBrutalTextField(
            label: 'Địa chỉ cụ thể',
            hint: 'Số nhà, đường...',
            controller: addressController,
          ),
          const SizedBox(height: 14),

          // Building name
          NeoBrutalTextField(
            label: 'Tên toà nhà / chung cư',
            hint: 'VD: Vinhomes Central Park',
            controller: buildingController,
          ),
          const SizedBox(height: 8),

          // Location negotiable
          _CheckRow(
            label: 'Vị trí có thể thương lượng',
            value: locationNegotiable,
            onChanged: onLocationNegotiableChanged,
          ),
          const SizedBox(height: 14),

          // Price/Budget
          NeoBrutalTextField(
            label: category == 'roommate' && roommateType == 'find-partner'
                ? 'Ngân sách *'
                : 'Giá phòng *',
            hint: 'VD: 5000000',
            controller: priceController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 14),

          // Move-in date
          NeoBrutalTextField(
            label: 'Ngày dọn vào',
            hint: 'VD: Đầu tháng 3/2026',
            controller: moveInController,
          ),
          const SizedBox(height: 8),

          // Time negotiable
          _CheckRow(
            label: 'Thời gian có thể thương lượng',
            value: timeNegotiable,
            onChanged: onTimeNegotiableChanged,
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CheckRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: value ? AppColors.blue : Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: value ? const Icon(Icons.check, size: 14, color: Colors.black) : null,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Google Sans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
