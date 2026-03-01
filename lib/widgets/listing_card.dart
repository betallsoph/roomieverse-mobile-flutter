import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/listing.dart';
import '../theme/app_theme.dart';
import '../utils/helpers.dart';

class ListingCard extends StatelessWidget {
  final RoomListing listing;
  final VoidCallback? onTap;
  final bool compact;
  final bool showCategory;
  final bool showStatus;

  const ListingCard({
    super.key,
    required this.listing,
    this.onTap,
    this.compact = false,
    this.showCategory = true,
    this.showStatus = false,
  });

  Color get _categoryColor {
    switch (listing.category) {
      case 'roommate':
        return AppColors.backgroundBlue;
      case 'roomshare':
        return AppColors.pinkLight;
      case 'short-term':
        return AppColors.emeraldLight;
      case 'sublease':
        return AppColors.orangeLight;
      default:
        return AppColors.backgroundBlue;
    }
  }

  Color get _categoryTextColor {
    switch (listing.category) {
      case 'roommate':
        return const Color(0xFF1D4ED8);
      case 'roomshare':
        return const Color(0xFFBE185D);
      case 'short-term':
        return const Color(0xFF047857);
      case 'sublease':
        return const Color(0xFFC2410C);
      default:
        return const Color(0xFF1D4ED8);
    }
  }

  String? get _imageUrl {
    if (listing.images != null && listing.images!.isNotEmpty) {
      return listing.images![0];
    }
    return listing.image;
  }

  @override
  Widget build(BuildContext context) {
    final imageHeight = compact ? 100.0 : 120.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: _imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: _imageUrl!,
                          height: imageHeight,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            height: imageHeight,
                            color: const Color(0xFFF4F4F5),
                            child: const Center(
                              child: Icon(LucideIcons.image, color: Colors.black12),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            height: imageHeight,
                            color: const Color(0xFFF4F4F5),
                            child: const Center(
                              child: Icon(LucideIcons.imageOff, color: Colors.black12),
                            ),
                          ),
                        )
                      : Container(
                          height: imageHeight,
                          width: double.infinity,
                          color: const Color(0xFFF4F4F5),
                          child: Center(
                            child: Icon(
                              listing.category == 'roommate'
                                  ? LucideIcons.users
                                  : LucideIcons.home,
                              size: 32,
                              color: Colors.black12,
                            ),
                          ),
                        ),
                ),
                if (showStatus && listing.status != null && listing.status != 'active')
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _StatusBadge(status: listing.status!),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if (showCategory) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _categoryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          categoryLabel(listing.category),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _categoryTextColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Expanded(
                      child: Text(
                        listing.title,
                        maxLines: showCategory ? 2 : 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Google Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ),
                    Text(
                      formatPrice(listing.price),
                      style: TextStyle(
                        fontFamily: 'Google Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _categoryTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(LucideIcons.mapPin, size: 11, color: AppColors.textTertiary),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            listing.location.isNotEmpty
                                ? listing.location
                                : [listing.district, listing.city]
                                    .where((s) => s != null && s.isNotEmpty)
                                    .join(', '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  (Color, String) get _data {
    switch (status) {
      case 'pending':
        return (AppColors.yellow, 'Chờ duyệt');
      case 'rejected':
        return (const Color(0xFFEF4444), 'Bị từ chối');
      case 'hidden':
        return (AppColors.gray, 'Đã ẩn');
      case 'deleted':
        return (AppColors.gray, 'Đã xoá');
      default:
        return (AppColors.gray, status);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (color, label) = _data;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Google Sans',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    );
  }
}
