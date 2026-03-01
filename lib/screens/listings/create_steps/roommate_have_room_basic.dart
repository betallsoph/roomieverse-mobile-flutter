import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/neo_brutal.dart';
import '../../../widgets/neo_brutal_dropdown.dart';
import '../../../data/constants.dart';
import '../../../utils/helpers.dart';

class RoommateHaveRoomBasic extends StatelessWidget {
  final String? roommateType;
  final ValueChanged<String> onRoommateTypeChanged;
  final TextEditingController titleController;
  final TextEditingController introController;
  final TextEditingController addressController;
  final TextEditingController buildingController;
  final TextEditingController priceController;
  final String? selectedCity;
  final String? selectedDistrict;
  final ValueChanged<String?> onCityChanged;
  final ValueChanged<String?> onDistrictChanged;
  final String? selectedPropertyType;
  final ValueChanged<String?> onPropertyTypeChanged;
  final Widget bottomActions;

  const RoommateHaveRoomBasic({
    super.key,
    this.roommateType,
    required this.onRoommateTypeChanged,
    required this.titleController,
    required this.introController,
    required this.addressController,
    required this.buildingController,
    required this.priceController,
    this.selectedCity,
    this.selectedDistrict,
    required this.onCityChanged,
    required this.onDistrictChanged,
    this.selectedPropertyType,
    required this.onPropertyTypeChanged,
    required this.bottomActions,
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
            style: TextStyle(fontFamily: 'Google Sans', fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Bạn có phòng, muốn tìm người ở cùng',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          // Roommate type selector
          _RoommateTypeSelector(
            roommateType: roommateType,
            onChanged: onRoommateTypeChanged,
          ),
          const SizedBox(height: 14),

          NeoBrutalTextField(
            label: 'Tiêu đề *',
            hint: 'VD: Tìm bạn ở ghép quận 7, gần Lotte',
            controller: titleController,
            maxLength: 80,
          ),
          const SizedBox(height: 14),

          NeoBrutalTextField(
            label: 'Giới thiệu bản thân *',
            hint: 'Mình là nữ, 25 tuổi, làm văn phòng...',
            controller: introController,
            maxLines: 4,
          ),
          const SizedBox(height: 14),

          // Property type (single select)
          const Text(
            'Loại hình nhà ở *',
            style: TextStyle(fontFamily: 'Google Sans', fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: propertyTypeOptions.map((opt) {
              return NeoBrutalChip(
                label: opt.$2,
                selected: selectedPropertyType == opt.$1,
                selectedColor: AppColors.blue,
                onTap: () => onPropertyTypeChanged(
                  selectedPropertyType == opt.$1 ? null : opt.$1,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Location
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

          NeoBrutalTextField(
            label: 'Địa chỉ cụ thể',
            hint: 'Số nhà, đường...',
            controller: addressController,
          ),
          const SizedBox(height: 14),

          NeoBrutalTextField(
            label: 'Tên toà nhà / chung cư',
            hint: 'VD: Vinhomes Central Park',
            controller: buildingController,
          ),
          const SizedBox(height: 14),

          // Total monthly cost
          NeoBrutalTextField(
            label: 'Tổng chi phí hàng tháng *',
            hint: 'VD: 5.000.000',
            controller: priceController,
            keyboardType: TextInputType.number,
            inputFormatters: [CurrencyInputFormatter()],
            suffix: 'VNĐ',
          ),

          const SizedBox(height: 24),
          bottomActions,
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _RoommateTypeSelector extends StatelessWidget {
  final String? roommateType;
  final ValueChanged<String> onChanged;

  const _RoommateTypeSelector({this.roommateType, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: roommateTypeOptions.map((opt) {
        final isSelected = roommateType == opt.$1;
        final isHaveRoom = opt.$1 == 'have-room';
        const accentColor = Color(0xFF3B82F6);
        const bgColor = Color(0xFFEFF6FF);

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: isHaveRoom ? 6 : 0,
              left: isHaveRoom ? 0 : 6,
            ),
            child: GestureDetector(
              onTap: () => onChanged(opt.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected ? bgColor : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? accentColor : const Color(0xFFE5E7EB),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? accentColor.withValues(alpha: 0.15)
                            : const Color(0xFFF4F4F5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isHaveRoom ? LucideIcons.home : LucideIcons.search,
                        size: 20,
                        color: isSelected ? accentColor : AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isHaveRoom ? 'Có phòng sẵn' : 'Chưa có phòng',
                      style: TextStyle(
                        fontFamily: 'Google Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? accentColor : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isHaveRoom ? 'Tìm bạn ở cùng' : 'Tìm bạn cùng thuê',
                      style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
