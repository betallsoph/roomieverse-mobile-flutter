import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../theme/neo_brutal.dart';
import '../../providers/listing_provider.dart';

import '../../providers/favorites_provider.dart';
import '../../utils/helpers.dart';

class ListingDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const ListingDetailScreen({super.key, required this.id});

  @override
  ConsumerState<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final listingAsync = ref.watch(listingDetailProvider(widget.id));
    final favorites = ref.watch(favoritesNotifierProvider);
    final isFav = favorites.contains(widget.id);

    return Scaffold(
      body: listingAsync.when(
        data: (listing) {
          if (listing == null) {
            return const Center(child: Text('Không tìm thấy bài đăng'));
          }

          final images = listing.images ?? (listing.image != null ? [listing.image!] : <String>[]);
          final location = listing.location.isNotEmpty
              ? listing.location
              : [listing.specificAddress, listing.district, listing.city]
                  .where((s) => s != null && s.isNotEmpty)
                  .join(', ');

          return CustomScrollView(
            slivers: [
              // Image carousel as app bar
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: Colors.white,
                leading: _circleButton(
                  icon: LucideIcons.arrowLeft,
                  onTap: () => Navigator.pop(context),
                ),
                actions: [
                  _circleButton(
                    icon: isFav ? LucideIcons.heartOff : LucideIcons.heart,
                    onTap: () {
                      ref.read(favoritesNotifierProvider.notifier).toggle(widget.id);
                    },
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: images.isNotEmpty
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            PageView.builder(
                              itemCount: images.length,
                              onPageChanged: (i) => setState(() => _currentImageIndex = i),
                              itemBuilder: (_, i) => CachedNetworkImage(
                                imageUrl: images[i],
                                fit: BoxFit.cover,
                              ),
                            ),
                            if (images.length > 1)
                              Positioned(
                                bottom: 12,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    images.length,
                                    (i) => Container(
                                      width: i == _currentImageIndex ? 20 : 8,
                                      height: 8,
                                      margin: const EdgeInsets.symmetric(horizontal: 3),
                                      decoration: BoxDecoration(
                                        color: i == _currentImageIndex
                                            ? Colors.white
                                            : Colors.white54,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        )
                      : Container(
                          color: AppColors.backgroundBlue,
                          child: const Center(
                            child: Icon(LucideIcons.home, size: 64, color: Colors.black26),
                          ),
                        ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category + Price
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _categoryColor(listing.category),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              categoryLabel(listing.category),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _categoryTextColor(listing.category),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            formatPrice(listing.price),
                            style: const TextStyle(
                              fontFamily: 'Google Sans',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Title
                      Text(
                        listing.title,
                        style: const TextStyle(
                          fontFamily: 'Google Sans',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Location
                      if (location.isNotEmpty)
                        Row(
                          children: [
                            const Icon(LucideIcons.mapPin, size: 16, color: AppColors.textTertiary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                location,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 6),

                      // Move-in date
                      Row(
                        children: [
                          const Icon(LucideIcons.calendar, size: 16, color: AppColors.textTertiary),
                          const SizedBox(width: 6),
                          Text(
                            'Ngày vào: ${listing.moveInDate}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Author + date
                      Row(
                        children: [
                          const Icon(LucideIcons.user, size: 16, color: AppColors.textTertiary),
                          const SizedBox(width: 6),
                          Text(
                            '${listing.author} • ${listing.postedDate}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          if (listing.viewCount != null && listing.viewCount! > 0)
                            Row(
                              children: [
                                const Icon(LucideIcons.eye, size: 14, color: AppColors.textTertiary),
                                const SizedBox(width: 4),
                                Text(
                                  '${listing.viewCount}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Divider(thickness: 2, color: Colors.black12),
                      const SizedBox(height: 16),

                      // Description
                      const Text(
                        'Mô tả',
                        style: TextStyle(
                          fontFamily: 'Google Sans',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        listing.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),

                      // Introduction (if available)
                      if (listing.introduction != null && listing.introduction!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Giới thiệu bản thân',
                          style: TextStyle(
                            fontFamily: 'Google Sans',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          listing.introduction!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ],

                      // Amenities
                      if (listing.amenities != null && listing.amenities!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Tiện ích',
                          style: TextStyle(
                            fontFamily: 'Google Sans',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: listing.amenities!
                              .map((a) => NeoBrutalChip(label: a, selected: true, selectedColor: AppColors.emeraldLight))
                              .toList(),
                        ),
                      ],

                      // Costs breakdown
                      if (listing.costs != null) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Chi phí',
                          style: TextStyle(
                            fontFamily: 'Google Sans',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _CostsTable(costs: listing.costs!),
                      ],

                      const SizedBox(height: 24),

                      // Contact buttons
                      const Text(
                        'Liên hệ',
                        style: TextStyle(
                          fontFamily: 'Google Sans',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (listing.phone.isNotEmpty)
                        NeoBrutalButton(
                          label: listing.phone,
                          backgroundColor: AppColors.emeraldLight,
                          expanded: true,
                          onPressed: () => _launchUrl('tel:${listing.phone}'),
                        ),
                      if (listing.zalo != null && listing.zalo!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        NeoBrutalButton(
                          label: 'Zalo: ${listing.zalo}',
                          backgroundColor: AppColors.blueLight,
                          expanded: true,
                          onPressed: () => _launchUrl('https://zalo.me/${listing.zalo}'),
                        ),
                      ],

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
      ),
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 0, spreadRadius: -1),
          ],
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'roommate': return AppColors.backgroundBlue; // blue-100
      case 'roomshare': return AppColors.pinkLight; // pink-100
      case 'short-term': return AppColors.emeraldLight; // green-100
      case 'sublease': return AppColors.orangeLight; // orange-200
      default: return AppColors.backgroundBlue;
    }
  }

  Color _categoryTextColor(String cat) {
    switch (cat) {
      case 'roommate': return const Color(0xFF1D4ED8); // blue-700
      case 'roomshare': return const Color(0xFFBE185D); // pink-700
      case 'short-term': return const Color(0xFF047857); // emerald-700
      case 'sublease': return const Color(0xFFC2410C); // orange-700
      default: return const Color(0xFF1D4ED8);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _CostsTable extends StatelessWidget {
  final dynamic costs;
  const _CostsTable({required this.costs});

  @override
  Widget build(BuildContext context) {
    final items = <MapEntry<String, String>>[];
    final c = costs;
    if (c.rent != null && c.rent!.isNotEmpty) items.add(MapEntry('Tiền phòng', c.rent!));
    if (c.deposit != null && c.deposit!.isNotEmpty) items.add(MapEntry('Tiền cọc', c.deposit!));
    if (c.electricity != null && c.electricity!.isNotEmpty) items.add(MapEntry('Điện', c.electricity!));
    if (c.water != null && c.water!.isNotEmpty) items.add(MapEntry('Nước', c.water!));
    if (c.internet != null && c.internet!.isNotEmpty) items.add(MapEntry('Internet', c.internet!));
    if (c.service != null && c.service!.isNotEmpty) items.add(MapEntry('Dịch vụ', c.service!));
    if (c.parking != null && c.parking!.isNotEmpty) items.add(MapEntry('Xe', c.parking!));

    return NeoBrutalCard(
      backgroundColor: AppColors.yellowLight,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: items
            .map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    Text(e.value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
