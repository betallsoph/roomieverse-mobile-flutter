import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../providers/listing_provider.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/shimmer_loading.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(listingsProvider);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(listingsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Logo ──
              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Image.asset(
                    'assets/images/logo1.png',
                    height: 64,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Tin quảng cáo (carousel) ──
              const _SectionHeader(title: 'Tin quảng cáo'),
              const SizedBox(height: 10),
              const _AdsCarousel(
                color: Color(0xFFFEF3C7),
                label: 'Ads',
                count: 5,
                height: 100,
              ),

              const SizedBox(height: 24),

              // ── Tin ưu tiên ──
              const _SectionHeader(title: 'Tin ưu tiên'),
              const SizedBox(height: 10),
              const _PriorityCarousel(count: 4),

              const SizedBox(height: 24),

              // ── Tin tài trợ (carousel) ──
              const _SectionHeader(title: 'Tin tài trợ'),
              const SizedBox(height: 10),
              const _AdsCarousel(
                color: Color(0xFFEDE9FE),
                label: 'Sponsored',
                count: 4,
                height: 140,
              ),

              const SizedBox(height: 24),

              // ── Tin mới nhất ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tin mới nhất',
                      style: TextStyle(
                        fontFamily: 'Google Sans',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/browse'),
                      child: const Row(
                        children: [
                          Text(
                            'Xem tất cả',
                            style: TextStyle(
                              fontFamily: 'Google Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.blueDark,
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(LucideIcons.arrowRight, size: 16, color: AppColors.blueDark),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              listingsAsync.when(
                data: (listings) {
                  if (listings.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black.withValues(alpha: 0.1), width: 1),
                        ),
                        child: const Column(
                          children: [
                            Icon(LucideIcons.inbox, size: 36, color: AppColors.textTertiary),
                            SizedBox(height: 8),
                            Text(
                              'Chưa có tin đăng nào',
                              style: TextStyle(
                                fontFamily: 'Google Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  final featured = listings.take(8).toList();
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: featured.length,
                      itemBuilder: (context, index) => ListingCard(
                        listing: featured[index],
                        compact: true,
                        onTap: () => context.push('/listing/${featured[index].id}'),
                      ),
                    ),
                  );
                },
                loading: () => const ShimmerHorizontalList(),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(child: Text('Lỗi: $e')),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Google Sans',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _AdsCarousel extends StatefulWidget {
  final Color color;
  final String label;
  final int count;
  final double height;

  const _AdsCarousel({
    required this.color,
    required this.label,
    required this.count,
    required this.height,
  });

  @override
  State<_AdsCarousel> createState() => _AdsCarouselState();
}

class _AdsCarouselState extends State<_AdsCarousel> {
  final PageController _controller = PageController(viewportFraction: 0.88);
  int _current = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.count,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Center(
                  child: Text(
                    '${widget.label} ${index + 1}',
                    style: TextStyle(
                      fontFamily: 'Google Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.count, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _current == i ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _current == i ? AppColors.blueDark : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _PriorityCarousel extends StatefulWidget {
  final int count;
  const _PriorityCarousel({required this.count});

  @override
  State<_PriorityCarousel> createState() => _PriorityCarouselState();
}

class _PriorityCarouselState extends State<_PriorityCarousel> {
  late final PageController _controller = PageController(viewportFraction: 0.88);
  int _current = 0;

  static const _sampleData = [
    ('Tìm bạn ở ghép Q7 gần Lotte Mart', '5,000,000', 'Quận 7, TP.HCM'),
    ('Share phòng căn hộ 2PN Vinhomes', '3,500,000', 'Quận 9, TP.HCM'),
    ('Phòng trọ giá rẻ gần ĐH Bách Khoa', '2,800,000', 'Quận 10, TP.HCM'),
    ('Cần bạn ở ghép studio Thủ Đức', '4,200,000', 'Thủ Đức, TP.HCM'),
    ('Phòng đẹp giá tốt Bình Thạnh', '3,000,000', 'Bình Thạnh, TP.HCM'),
    ('Tìm người ở ghép Phú Nhuận', '4,500,000', 'Phú Nhuận, TP.HCM'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _pageCount => (widget.count / 2).ceil();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _controller,
            itemCount: _pageCount,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, pageIndex) {
              final topIdx = pageIndex * 2;
              final bottomIdx = topIdx + 1;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  children: [
                    Expanded(child: _buildRow(_sampleData[topIdx % _sampleData.length])),
                    const SizedBox(height: 8),
                    if (bottomIdx < widget.count)
                      Expanded(child: _buildRow(_sampleData[bottomIdx % _sampleData.length]))
                    else
                      const Expanded(child: SizedBox()),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_pageCount, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _current == i ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _current == i ? Colors.green.shade600 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildRow((String, String, String) d) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(11)),
            child: Container(
              width: 90,
              color: const Color(0xFFDCFCE7),
              child: Center(
                child: Icon(LucideIcons.star, size: 24, color: Colors.green.shade300),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    d.$1,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Google Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${d.$2} VNĐ/tháng',
                    style: TextStyle(
                      fontFamily: 'Google Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(LucideIcons.mapPin, size: 10, color: AppColors.textTertiary),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          d.$3,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
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
    );
  }
}
