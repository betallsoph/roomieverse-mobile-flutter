import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/neo_brutal.dart';
import '../../../widgets/image_picker_grid.dart';
import '../../../data/constants.dart';

class RoommateHaveRoomDetails extends StatelessWidget {
  final List<String> imagePaths;
  final VoidCallback onAddImages;
  final ValueChanged<int> onRemoveImage;
  final TextEditingController roomSizeController;
  final TextEditingController occupantsController;
  final TextEditingController contractController;
  final TextEditingController amenitiesOtherController;
  final List<String> selectedAmenities;
  final ValueChanged<List<String>> onAmenitiesChanged;
  final Widget bottomActions;

  const RoommateHaveRoomDetails({
    super.key,
    required this.imagePaths,
    required this.onAddImages,
    required this.onRemoveImage,
    required this.roomSizeController,
    required this.occupantsController,
    required this.contractController,
    required this.amenitiesOtherController,
    required this.selectedAmenities,
    required this.onAmenitiesChanged,
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
            'Hình ảnh & Tiện ích',
            style: TextStyle(fontFamily: 'Google Sans', fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Thêm hình ảnh và thông tin chi tiết về phòng',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          const Text(
            'Hình ảnh * (tối đa 5)',
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

          NeoBrutalTextField(
            label: 'Diện tích phòng (m²)',
            hint: 'VD: 25',
            controller: roomSizeController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            suffix: 'm²',
          ),
          const SizedBox(height: 14),

          NeoBrutalTextField(
            label: 'Số người đang ở',
            hint: 'VD: 2',
            controller: occupantsController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 14),

          NeoBrutalTextField(
            label: 'Hợp đồng tối thiểu',
            hint: 'VD: 6 tháng',
            controller: contractController,
          ),
          const SizedBox(height: 20),

          const Text(
            'Tiện ích *',
            style: TextStyle(fontFamily: 'Google Sans', fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: roommateAmenityOptions.map((amenity) {
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

          const SizedBox(height: 24),
          bottomActions,
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
