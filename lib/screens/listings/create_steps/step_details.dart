import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/neo_brutal.dart';
import '../../../widgets/image_picker_grid.dart';
import '../../../data/constants.dart';

class StepDetails extends StatelessWidget {
  final List<String> imagePaths;
  final VoidCallback onAddImages;
  final ValueChanged<int> onRemoveImage;
  final TextEditingController roomSizeController;
  final TextEditingController occupantsController;
  final TextEditingController contractController;
  final TextEditingController othersIntroController;
  final TextEditingController amenitiesOtherController;
  final List<String> selectedAmenities;
  final ValueChanged<List<String>> onAmenitiesChanged;
  final Map<String, TextEditingController> costControllers;

  const StepDetails({
    super.key,
    required this.imagePaths,
    required this.onAddImages,
    required this.onRemoveImage,
    required this.roomSizeController,
    required this.occupantsController,
    required this.contractController,
    required this.othersIntroController,
    required this.amenitiesOtherController,
    required this.selectedAmenities,
    required this.onAmenitiesChanged,
    required this.costControllers,
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
            'Chi tiết & Tiện ích',
            style: TextStyle(fontFamily: 'Google Sans', fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Thêm hình ảnh và thông tin chi tiết',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          // Images
          const Text(
            'Hình ảnh (tối đa 5)',
            style: TextStyle(fontFamily: 'Google Sans', fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ImagePickerGrid(
            imagePaths: imagePaths,
            maxImages: 5,
            onAdd: onAddImages,
            onRemove: onRemoveImage,
          ),
          const SizedBox(height: 20),

          // Room size
          NeoBrutalTextField(
            label: 'Diện tích phòng (m²)',
            hint: 'VD: 25',
            controller: roomSizeController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 14),

          // Current occupants
          NeoBrutalTextField(
            label: 'Số người đang ở',
            hint: 'VD: 2',
            controller: occupantsController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 14),

          // Min contract
          NeoBrutalTextField(
            label: 'Hợp đồng tối thiểu',
            hint: 'VD: 6 tháng',
            controller: contractController,
          ),
          const SizedBox(height: 14),

          // Others intro
          NeoBrutalTextField(
            label: 'Giới thiệu người ở cùng',
            hint: 'Mô tả ngắn về bạn cùng phòng hiện tại...',
            controller: othersIntroController,
            maxLines: 3,
          ),
          const SizedBox(height: 20),

          // Amenities
          const Text(
            'Tiện ích',
            style: TextStyle(fontFamily: 'Google Sans', fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: amenityOptions.map((amenity) {
              final isSelected = selectedAmenities.contains(amenity);
              return NeoBrutalChip(
                label: amenity,
                selected: isSelected,
                selectedColor: AppColors.emerald,
                onTap: () {
                  final newList = List<String>.from(selectedAmenities);
                  isSelected ? newList.remove(amenity) : newList.add(amenity);
                  onAmenitiesChanged(newList);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          NeoBrutalTextField(
            hint: 'Tiện ích khác...',
            controller: amenitiesOtherController,
          ),
          const SizedBox(height: 20),

          // Cost breakdown
          const Text(
            'Chi phí',
            style: TextStyle(fontFamily: 'Google Sans', fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Bỏ trống nếu không áp dụng',
            style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 10),
          NeoBrutalCard(
            backgroundColor: AppColors.yellowLight,
            padding: const EdgeInsets.all(14),
            child: Column(
              children: costFields.map((field) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 90,
                        child: Text(
                          field.$2,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(color: Colors.black, width: 1.5),
                          ),
                          child: TextField(
                            controller: costControllers[field.$1],
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            decoration: const InputDecoration(
                              hintText: 'VNĐ',
                              hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
