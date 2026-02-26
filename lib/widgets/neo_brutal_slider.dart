import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NeoBrutalSlider extends StatelessWidget {
  final int value;
  final int max;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  const NeoBrutalSlider({
    super.key,
    required this.value,
    required this.max,
    required this.labels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Track with dots
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Background track
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.gray,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                  ),
                  // Filled track
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 6,
                      width: max > 0 ? (value / max) * width : 0,
                      decoration: BoxDecoration(
                        color: AppColors.blue,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                    ),
                  ),
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(max + 1, (i) {
                      final isSelected = i == value;
                      return GestureDetector(
                        onTap: () => onChanged(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: isSelected ? 24 : 16,
                          height: isSelected ? 24 : 16,
                          decoration: BoxDecoration(
                            color: i <= value ? AppColors.blue : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2),
                            boxShadow: isSelected ? AppShadows.pressed : null,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: labels.asMap().entries.map((entry) {
            final isSelected = entry.key == value;
            return Text(
              entry.value,
              style: TextStyle(
                fontFamily: 'Google Sans',
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.textPrimary : AppColors.textTertiary,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
