import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../theme/neo_brutal.dart';
import '../../providers/listing_provider.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/shimmer_loading.dart';

class BrowseScreen extends ConsumerStatefulWidget {
  const BrowseScreen({super.key});

  @override
  ConsumerState<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends ConsumerState<BrowseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  static const _categories = [
    ('roommate', 'Bạn ở ghép', AppColors.blueLight),
    ('roomshare', 'Phòng share', AppColors.pinkLight),
    ('short-term', 'Ngắn ngày', AppColors.emeraldLight),
    ('sublease', 'Sang lại', AppColors.orangeLight),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCategoryPicker(BuildContext context) {
    const categories = [
      ('roommate', 'Tìm bạn ở ghép', LucideIcons.users, Color(0xFF3B82F6)),
      ('roomshare', 'Phòng share', LucideIcons.home, Color(0xFFEC4899)),
      ('short-term', 'Ngắn ngày', LucideIcons.clock, Color(0xFF10B981)),
      ('sublease', 'Sang lại', LucideIcons.repeat, Color(0xFFF97316)),
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chọn loại tin đăng',
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ...categories.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push('/create-listing?category=${c.$1}');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: c.$4.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(c.$3, size: 20, color: c.$4),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          c.$2,
                          style: const TextStyle(
                            fontFamily: 'Google Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textTertiary),
                      ],
                    ),
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Search bar + post button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // TODO: navigate to search
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 11),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border:
                            Border.all(color: AppColors.border, width: 2),
                        boxShadow: AppShadows.secondary,
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.search,
                              size: 18, color: AppColors.textTertiary),
                          const SizedBox(width: 10),
                          Text(
                            'Tìm kiếm...',
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
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _showCategoryPicker(context),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      color: _categories[_selectedIndex].$3,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.border, width: 2),
                    ),
                    child: const Text(
                      'Đăng tin',
                      style: TextStyle(
                        fontFamily: 'Google Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Category chips
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedIndex = index);
                    _tabController.animateTo(index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? cat.$3 : AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: isSelected ? AppColors.border : const Color(0xFFD4D4D8),
                        width: isSelected ? 2 : 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        cat.$2,
                        style: TextStyle(
                          fontFamily: 'Google Sans',
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.textPrimary
                              : AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 2),

          // Listing content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _categories.map((c) {
                return _CategoryListings(category: c.$1);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryListings extends ConsumerWidget {
  final String category;
  const _CategoryListings({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(listingsByCategoryProvider(category));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(listingsByCategoryProvider(category));
      },
      child: listingsAsync.when(
        data: (listings) {
          if (listings.isEmpty) {
            return ListView(
              children: [
                const SizedBox(height: 120),
                const Icon(Icons.inbox_outlined, size: 48, color: AppColors.textTertiary),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'Chưa có tin đăng nào',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: NeoBrutalButton(
                    label: 'Đăng tin ngay',
                    backgroundColor: AppColors.blueLight,
                    onPressed: () => context.push('/create-listing?category=$category'),
                  ),
                ),
              ],
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listings.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) {
              return ListingCard(
                listing: listings[index],
                showCategory: false,
                onTap: () => context.push('/listing/${listings[index].id}'),
              );
            },
          );
        },
        loading: () => const ShimmerListingList(),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
      ),
    );
  }
}
