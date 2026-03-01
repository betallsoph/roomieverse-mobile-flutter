import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/neo_brutal.dart';
import '../../../data/constants.dart';
import '../../../utils/helpers.dart';

class RoomshareCosts extends StatelessWidget {
  final bool isApartment;
  final Map<String, TextEditingController> costControllers;
  final Widget bottomActions;

  const RoomshareCosts({
    super.key,
    required this.isApartment,
    required this.costControllers,
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
            'Chi phí chi tiết',
            style: TextStyle(fontFamily: 'Google Sans', fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Bỏ trống nếu không áp dụng',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          ...roomshareCostFields.map((field) {
            // Hide apartment-only fields for houses
            if (!isApartment && (field.$1 == 'service' || field.$1 == 'management')) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: NeoBrutalTextField(
                label: field.$2,
                hint: 'VNĐ',
                controller: costControllers[field.$1],
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                suffix: 'VNĐ',
              ),
            );
          }),

          const SizedBox(height: 10),
          bottomActions,
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
