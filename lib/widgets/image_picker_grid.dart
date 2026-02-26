import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';

class ImagePickerGrid extends StatelessWidget {
  final List<String> imagePaths; // local file paths or URLs
  final int maxImages;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const ImagePickerGrid({
    super.key,
    required this.imagePaths,
    this.maxImages = 5,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final canAdd = imagePaths.length < maxImages;
    final itemCount = imagePaths.length + (canAdd ? 1 : 0);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == imagePaths.length && canAdd) {
          // Add button
          return GestureDetector(
            onTap: onAdd,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundSky,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: Colors.black, width: 2, style: BorderStyle.solid),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.plus, size: 24, color: AppColors.textTertiary),
                  const SizedBox(height: 4),
                  Text(
                    '${imagePaths.length}/$maxImages',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Image tile
        final path = imagePaths[index];
        final isUrl = path.startsWith('http');

        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: Colors.black, width: 2),
              ),
              clipBehavior: Clip.antiAlias,
              child: isUrl
                  ? Image.network(path, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                  : Image.file(File(path), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => onRemove(index),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: const Icon(LucideIcons.x, size: 14, color: Colors.black),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
