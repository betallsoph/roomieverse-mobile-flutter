import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../theme/neo_brutal.dart';
import '../../models/listing.dart';
import '../../providers/listing_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/preferences_card.dart';
import '../../data/constants.dart';
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

          return CustomScrollView(
            slivers: [
              _buildImageAppBar(images, isFav),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (listing.status != null && listing.status != 'active')
                        _buildStatusBanner(listing.status!),
                      _buildHeader(listing),
                      const SizedBox(height: 20),
                      const Divider(thickness: 2, color: Colors.black12),
                      const SizedBox(height: 16),
                      _buildCategoryBody(listing),
                      const SizedBox(height: 24),
                      _buildContactSection(listing),
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

  // ── Image carousel ────────────────────────────────────────

  Widget _buildImageAppBar(List<String> images, bool isFav) {
    return SliverAppBar(
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
                              color: i == _currentImageIndex ? Colors.white : Colors.white54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              )
            : Container(
                color: _placeholderColor(null),
                child: const Center(
                  child: Icon(LucideIcons.home, size: 64, color: Colors.black26),
                ),
              ),
      ),
    );
  }

  Color _placeholderColor(String? category) {
    switch (category) {
      case 'roomshare': return AppColors.pinkLight;
      case 'short-term': return AppColors.emeraldLight;
      case 'sublease': return AppColors.orangeLight;
      default: return AppColors.backgroundBlue;
    }
  }

  // ── Status banner ────────────────────────────────────────

  Widget _buildStatusBanner(String status) {
    final Color bgColor;
    final IconData icon;
    final String message;

    switch (status) {
      case 'pending':
        bgColor = AppColors.yellow;
        icon = LucideIcons.clock;
        message = 'Tin đăng đang chờ duyệt';
      case 'rejected':
        bgColor = const Color(0xFFFEE2E2);
        icon = LucideIcons.xCircle;
        message = 'Tin đăng đã bị từ chối';
      case 'hidden':
        bgColor = const Color(0xFFF4F4F5);
        icon = LucideIcons.eyeOff;
        message = 'Tin đăng đã bị ẩn';
      default:
        bgColor = const Color(0xFFF4F4F5);
        icon = LucideIcons.info;
        message = 'Trạng thái: $status';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black87),
          const SizedBox(width: 10),
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'Google Sans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ── Header (shared) ───────────────────────────────────────

  Widget _buildHeader(RoomListing listing) {
    final location = listing.location.isNotEmpty
        ? listing.location
        : [listing.specificAddress, listing.district, listing.city]
            .where((s) => s != null && s.isNotEmpty)
            .join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category badge + price
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
        if (location.isNotEmpty) _iconRow(LucideIcons.mapPin, location),

        // Move-in date
        if (listing.moveInDate.isNotEmpty)
          _iconRow(LucideIcons.calendar, 'Ngày vào: ${listing.moveInDate}'),

        // Author + date + views
        const SizedBox(height: 2),
        Row(
          children: [
            const Icon(LucideIcons.user, size: 16, color: AppColors.textTertiary),
            const SizedBox(width: 6),
            Text(
              '${listing.author} • ${listing.postedDate}',
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const Spacer(),
            if (listing.viewCount != null && listing.viewCount! > 0) ...[
              const Icon(LucideIcons.eye, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(
                '${listing.viewCount}',
                style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _iconRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textTertiary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  // ── Category-specific body ────────────────────────────────

  Widget _buildCategoryBody(RoomListing listing) {
    switch (listing.category) {
      case 'roommate':
        return listing.roommateType == 'find-partner'
            ? _buildFindPartnerBody(listing)
            : _buildHaveRoomBody(listing);
      case 'roomshare':
        return _buildRoomshareBody(listing);
      case 'sublease':
        return _buildSubleaseBody(listing);
      case 'short-term':
        return _buildShortTermBody(listing);
      default:
        return _buildGenericBody(listing);
    }
  }

  // ── Roommate: have-room ───────────────────────────────────

  Widget _buildHaveRoomBody(RoomListing listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Room info
        _buildRoomInfoSection(listing),

        // Introduction
        if (listing.introduction != null && listing.introduction!.isNotEmpty) ...[
          const SizedBox(height: 20),
          _sectionTitle('Giới thiệu'),
          const SizedBox(height: 8),
          Text(
            listing.introduction!,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
          ),
        ],

        // Description (if different from introduction)
        if (listing.description.isNotEmpty &&
            listing.description != listing.introduction) ...[
          const SizedBox(height: 20),
          _sectionTitle('Mô tả'),
          const SizedBox(height: 8),
          Text(
            listing.description,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
          ),
        ],

        // Amenities
        _buildAmenities(listing),

        // Preferences
        if (listing.preferences != null) ...[
          const SizedBox(height: 20),
          PreferencesCard(
            preferences: listing.preferences!,
            accentColor: AppColors.blue,
          ),
        ],
      ],
    );
  }

  // ── Roommate: find-partner ────────────────────────────────

  Widget _buildFindPartnerBody(RoomListing listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Self introduction
        if (listing.introduction != null && listing.introduction!.isNotEmpty) ...[
          _sectionTitle('Về bản thân'),
          const SizedBox(height: 8),
          Text(
            listing.introduction!,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
          ),
          const SizedBox(height: 20),
        ],

        // Looking for
        _sectionTitle('Đang tìm'),
        const SizedBox(height: 8),
        _buildInfoTable([
          if (listing.price.isNotEmpty) ('Ngân sách', formatPrice(listing.price)),
          if (listing.location.isNotEmpty) ('Khu vực', listing.location),
          if (listing.propertyTypes != null && listing.propertyTypes!.isNotEmpty)
            ('Loại hình', listing.propertyTypes!.map((t) => getPropertyTypeLabel(t) ?? t).join(', ')),
          if (listing.moveInDate.isNotEmpty) ('Thời gian vào', listing.moveInDate),
        ]),

        // Preferences
        if (listing.preferences != null) ...[
          const SizedBox(height: 20),
          PreferencesCard(
            preferences: listing.preferences!,
            accentColor: AppColors.blue,
          ),
        ],
      ],
    );
  }

  // ── Roomshare ─────────────────────────────────────────────

  Widget _buildRoomshareBody(RoomListing listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Self intro
        if (listing.introduction != null && listing.introduction!.isNotEmpty) ...[
          _sectionTitle('Về người đăng'),
          const SizedBox(height: 8),
          Text(
            listing.introduction!,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
          ),
          const SizedBox(height: 16),
        ],

        // Others intro
        if (listing.othersIntro != null && listing.othersIntro!.isNotEmpty) ...[
          _sectionTitle('Về người ở cùng'),
          const SizedBox(height: 8),
          Text(
            listing.othersIntro!,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
          ),
          const SizedBox(height: 20),
        ],

        // Room info
        _buildRoomInfoSection(listing),

        // Costs
        if (listing.costs != null) ...[
          const SizedBox(height: 20),
          _sectionTitle('Chi phí'),
          const SizedBox(height: 8),
          _CostsTable(costs: listing.costs!),
        ],

        // Amenities
        _buildAmenities(listing),

        // Preferences
        if (listing.preferences != null) ...[
          const SizedBox(height: 20),
          PreferencesCard(
            preferences: listing.preferences!,
            accentColor: AppColors.pink,
          ),
        ],
      ],
    );
  }

  // ── Sublease ──────────────────────────────────────────────

  Widget _buildSubleaseBody(RoomListing listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Room info
        _sectionTitle('Thông tin phòng sang lại'),
        const SizedBox(height: 8),
        _buildInfoTable([
          if (listing.location.isNotEmpty) ('Khu vực', listing.location),
          if (listing.specificAddress != null && listing.specificAddress!.isNotEmpty)
            ('Địa chỉ', listing.specificAddress!),
          if (listing.moveInDate.isNotEmpty) ('Ngày vào', listing.moveInDate),
          if (listing.minContractDuration != null && listing.minContractDuration!.isNotEmpty)
            ('HĐ còn lại', listing.minContractDuration!),
        ]),

        // Description
        if (listing.description.isNotEmpty) ...[
          const SizedBox(height: 20),
          _sectionTitle('Mô tả'),
          const SizedBox(height: 8),
          Text(
            listing.description,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
          ),
        ],

        // Amenities
        _buildAmenities(listing),
      ],
    );
  }

  // ── Short-term ────────────────────────────────────────────

  Widget _buildShortTermBody(RoomListing listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Room info
        _sectionTitle('Thông tin phòng'),
        const SizedBox(height: 8),
        _buildInfoTable([
          if (listing.location.isNotEmpty) ('Khu vực', listing.location),
          if (listing.specificAddress != null && listing.specificAddress!.isNotEmpty)
            ('Địa chỉ', listing.specificAddress!),
        ]),

        // Description
        if (listing.description.isNotEmpty) ...[
          const SizedBox(height: 20),
          _sectionTitle('Mô tả'),
          const SizedBox(height: 8),
          Text(
            listing.description,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
          ),
        ],

        // Amenities
        _buildAmenities(listing),
      ],
    );
  }

  // ── Generic fallback ──────────────────────────────────────

  Widget _buildGenericBody(RoomListing listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Mô tả'),
        const SizedBox(height: 8),
        Text(
          listing.description,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
        ),
        _buildAmenities(listing),
      ],
    );
  }

  // ── Shared building blocks ────────────────────────────────

  Widget _buildRoomInfoSection(RoomListing listing) {
    final rows = <(String, String)>[];
    if (listing.propertyTypes != null && listing.propertyTypes!.isNotEmpty) {
      rows.add(('Loại hình', listing.propertyTypes!.map((t) => getPropertyTypeLabel(t) ?? t).join(', ')));
    }
    if (listing.roomSize != null && listing.roomSize!.isNotEmpty) {
      rows.add(('Diện tích', listing.roomSize!));
    }
    if (listing.currentOccupants != null && listing.currentOccupants!.isNotEmpty) {
      rows.add(('Số người ở', listing.currentOccupants!));
    }
    if (listing.totalRooms != null && listing.totalRooms!.isNotEmpty) {
      rows.add(('Số phòng', listing.totalRooms!));
    }
    if (listing.minContractDuration != null && listing.minContractDuration!.isNotEmpty) {
      rows.add(('Hợp đồng tối thiểu', listing.minContractDuration!));
    }
    if (listing.buildingName != null && listing.buildingName!.isNotEmpty) {
      rows.add(('Tòa nhà', listing.buildingName!));
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Thông tin phòng'),
        const SizedBox(height: 8),
        _buildInfoTable(rows),
      ],
    );
  }

  Widget _buildInfoTable(List<(String, String)> rows) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: rows.asMap().entries.map((entry) {
          final row = entry.value;
          final isLast = entry.key == rows.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.$1,
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        row.$2,
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(height: 0, thickness: 1, color: Color(0xFFE5E7EB)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAmenities(RoomListing listing) {
    if (listing.amenities == null || listing.amenities!.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        _sectionTitle('Tiện ích'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: listing.amenities!.map((a) => NeoBrutalChip(label: a)).toList(),
        ),
      ],
    );
  }

  // ── Contact ───────────────────────────────────────────────

  Widget _buildContactSection(RoomListing listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Liên hệ'),
        const SizedBox(height: 12),
        if (listing.phone.isNotEmpty)
          NeoBrutalButton(
            label: listing.phone,
            icon: LucideIcons.phone,
            expanded: true,
            onPressed: () => _launchUrl('tel:${listing.phone}'),
          ),
        if (listing.zalo != null && listing.zalo!.isNotEmpty) ...[
          const SizedBox(height: 8),
          NeoBrutalButton(
            label: 'Zalo: ${listing.zalo}',
            expanded: true,
            onPressed: () => _launchUrl('https://zalo.me/${listing.zalo}'),
          ),
        ],
        if (listing.facebook != null && listing.facebook!.isNotEmpty) ...[
          const SizedBox(height: 8),
          NeoBrutalButton(
            label: 'Facebook: ${listing.facebook}',
            expanded: true,
            onPressed: () => _launchUrl('https://facebook.com/${listing.facebook}'),
          ),
        ],
        if (listing.instagram != null && listing.instagram!.isNotEmpty) ...[
          const SizedBox(height: 8),
          NeoBrutalButton(
            label: 'Instagram: ${listing.instagram}',
            expanded: true,
            onPressed: () => _launchUrl('https://instagram.com/${listing.instagram}'),
          ),
        ],
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Google Sans',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
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
      case 'roommate': return AppColors.backgroundBlue;
      case 'roomshare': return AppColors.pinkLight;
      case 'short-term': return AppColors.emeraldLight;
      case 'sublease': return AppColors.orangeLight;
      default: return AppColors.backgroundBlue;
    }
  }

  Color _categoryTextColor(String cat) {
    switch (cat) {
      case 'roommate': return const Color(0xFF1D4ED8);
      case 'roomshare': return const Color(0xFFBE185D);
      case 'short-term': return const Color(0xFF047857);
      case 'sublease': return const Color(0xFFC2410C);
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
  final RoomCosts costs;
  const _CostsTable({required this.costs});

  @override
  Widget build(BuildContext context) {
    final items = <MapEntry<String, String>>[];
    if (costs.rent != null && costs.rent!.isNotEmpty) items.add(MapEntry('Tiền phòng', costs.rent!));
    if (costs.deposit != null && costs.deposit!.isNotEmpty) items.add(MapEntry('Tiền cọc', costs.deposit!));
    if (costs.electricity != null && costs.electricity!.isNotEmpty) items.add(MapEntry('Điện', costs.electricity!));
    if (costs.water != null && costs.water!.isNotEmpty) items.add(MapEntry('Nước', costs.water!));
    if (costs.internet != null && costs.internet!.isNotEmpty) items.add(MapEntry('Internet', costs.internet!));
    if (costs.service != null && costs.service!.isNotEmpty) items.add(MapEntry('Dịch vụ', costs.service!));
    if (costs.management != null && costs.management!.isNotEmpty) items.add(MapEntry('Quản lý', costs.management!));
    if (costs.parking != null && costs.parking!.isNotEmpty) items.add(MapEntry('Gửi xe', costs.parking!));
    if (costs.other != null && costs.other!.isNotEmpty) items.add(MapEntry('Khác', costs.other!));

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: items.asMap().entries.map((entry) {
        final e = entry.value;
        final isLast = entry.key == items.length - 1;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.key, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  Text(e.value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            if (!isLast)
              const Divider(height: 0, thickness: 1, color: Color(0xFFE5E7EB)),
          ],
        );
      }).toList(),
    );
  }
}
