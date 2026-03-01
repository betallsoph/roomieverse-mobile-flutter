import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/neo_brutal.dart';
import '../../../widgets/neo_brutal_dropdown.dart';
import '../../../data/constants.dart';
import '../../../utils/helpers.dart';

class RoomshareBasic extends StatelessWidget {
  final String? selectedPropertyType;
  final ValueChanged<String?> onPropertyTypeChanged;
  final TextEditingController titleController;
  final TextEditingController introController;
  final TextEditingController othersIntroController;
  final TextEditingController addressController;
  final TextEditingController buildingController;
  final String? selectedCity;
  final String? selectedDistrict;
  final ValueChanged<String?> onCityChanged;
  final ValueChanged<String?> onDistrictChanged;
  final TextEditingController totalRoomsController;
  final TextEditingController roomSizeController;
  final TextEditingController occupantsController;
  final TextEditingController rentController;
  final TextEditingController depositController;
  final TextEditingController minLeaseController;
  final Widget bottomActions;

  const RoomshareBasic({
    super.key,
    this.selectedPropertyType,
    required this.onPropertyTypeChanged,
    required this.titleController,
    required this.introController,
    required this.othersIntroController,
    required this.addressController,
    required this.buildingController,
    this.selectedCity,
    this.selectedDistrict,
    required this.onCityChanged,
    required this.onDistrictChanged,
    required this.totalRoomsController,
    required this.roomSizeController,
    required this.occupantsController,
    required this.rentController,
    required this.depositController,
    required this.minLeaseController,
    required this.bottomActions,
  });

  @override
  Widget build(BuildContext context) {
    final isApartment = selectedPropertyType == 'apartment';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin phòng',
            style: TextStyle(fontFamily: 'Google Sans', fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Mô tả phòng share của bạn',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          // Property type toggle
          const Text(
            'Loại hình *',
            style: TextStyle(fontFamily: 'Google Sans', fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Row(
            children: roomsharePropertyTypes.map((opt) {
              final isSelected = selectedPropertyType == opt.$1;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: opt.$1 == 'apartment' ? 4 : 0,
                    left: opt.$1 == 'apartment' ? 0 : 4,
                  ),
                  child: GestureDetector(
                    onTap: () => onPropertyTypeChanged(opt.$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.pinkLight : Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: isSelected ? AppColors.border : const Color(0xFFD4D4D8),
                          width: isSelected ? 2 : 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          opt.$2,
                          style: TextStyle(
                            fontFamily: 'Google Sans',
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppColors.textPrimary : AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          NeoBrutalTextField(
            label: 'Tiêu đề *',
            hint: 'VD: Share phòng dư căn hộ 2PN Vinhomes Q9',
            controller: titleController,
            maxLength: 80,
          ),
          const SizedBox(height: 14),

          NeoBrutalTextField(
            label: 'Giới thiệu bản thân *',
            hint: 'Tuổi, nghề nghiệp, thói quen sinh hoạt...',
            controller: introController,
            maxLines: 3,
            maxLength: 500,
          ),
          const SizedBox(height: 14),

          NeoBrutalTextField(
            label: 'Giới thiệu người ở cùng',
            hint: 'VD: Hiện tại có 2 bạn nữ, 1 bạn sinh viên...',
            controller: othersIntroController,
            maxLines: 3,
            maxLength: 500,
          ),
          const SizedBox(height: 14),

          // Address
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

          if (isApartment) ...[
            NeoBrutalTextField(
              label: 'Tên toà nhà',
              hint: 'VD: Vinhomes Central Park',
              controller: buildingController,
            ),
            const SizedBox(height: 14),
          ],

          // Room details
          Row(
            children: [
              Expanded(
                child: NeoBrutalTextField(
                  label: 'Tổng số phòng *',
                  hint: 'VD: 3',
                  controller: totalRoomsController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NeoBrutalTextField(
                  label: 'Diện tích (m²) *',
                  hint: 'VD: 25',
                  controller: roomSizeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  suffix: 'm²',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          NeoBrutalTextField(
            label: 'Số người hiện tại *',
            hint: 'VD: 2',
            controller: occupantsController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 14),

          NeoBrutalTextField(
            label: 'Giá thuê hàng tháng *',
            hint: 'VD: 3.500.000',
            controller: rentController,
            keyboardType: TextInputType.number,
            inputFormatters: [CurrencyInputFormatter()],
            suffix: 'VNĐ',
          ),
          const SizedBox(height: 14),

          NeoBrutalTextField(
            label: 'Tiền cọc *',
            hint: 'VD: 3.500.000',
            controller: depositController,
            keyboardType: TextInputType.number,
            inputFormatters: [CurrencyInputFormatter()],
            suffix: 'VNĐ',
          ),
          const SizedBox(height: 14),

          NeoBrutalTextField(
            label: 'Hợp đồng tối thiểu *',
            hint: 'VD: 6 tháng',
            controller: minLeaseController,
          ),

          const SizedBox(height: 24),
          bottomActions,
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
