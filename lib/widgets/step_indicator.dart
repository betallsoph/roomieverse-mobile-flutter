import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String>? labels;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(totalSteps * 2 - 1, (i) {
            if (i.isOdd) {
              // Connector line
              final stepIndex = i ~/ 2;
              return Expanded(
                child: Container(
                  height: 3,
                  color: stepIndex < currentStep ? AppColors.blueDark : AppColors.gray,
                ),
              );
            }
            // Step dot
            final stepIndex = i ~/ 2;
            final isCompleted = stepIndex < currentStep;
            final isCurrent = stepIndex == currentStep;
            return Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.blueDark
                    : isCurrent
                        ? AppColors.blue
                        : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
                boxShadow: isCurrent ? AppShadows.pressed : null,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : Text(
                        '${stepIndex + 1}',
                        style: TextStyle(
                          fontFamily: 'Google Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isCurrent ? Colors.black : AppColors.textTertiary,
                        ),
                      ),
              ),
            );
          }),
        ),
        if (labels != null) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels!.asMap().entries.map((entry) {
              final isCurrent = entry.key == currentStep;
              return SizedBox(
                width: 70,
                child: Text(
                  entry.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    fontSize: 10,
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                    color: isCurrent ? AppColors.textPrimary : AppColors.textTertiary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
