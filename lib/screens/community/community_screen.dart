import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../theme/neo_brutal.dart';
import '../../models/community_post.dart';
import '../../services/community_service.dart';
import '../../utils/helpers.dart';
import '../../widgets/shimmer_loading.dart';

final communityServiceProvider = Provider((ref) => CommunityService());

final communityPostsProvider =
    FutureProvider.family<List<CommunityPost>, String?>((ref, category) async {
  return ref.watch(communityServiceProvider).getPosts(category: category);
});

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  String? _selectedCategory;

  static const _categories = [
    (null, 'Tất cả'),
    ('tips', 'Tips'),
    ('drama', 'Drama'),
    ('review', 'Review'),
    ('pass-do', 'Pass đồ'),
    ('blog', 'Blog'),
  ];

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(communityPostsProvider(_selectedCategory));

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/community/create'),
        backgroundColor: AppColors.purpleLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
        child: const Icon(LucideIcons.plus, color: Colors.black),
      ),
      body: SafeArea(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: const Text(
              'Cộng đồng',
              style: TextStyle(
                fontFamily: 'Google Sans',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Category filter
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return NeoBrutalChip(
                  label: cat.$2,
                  selected: _selectedCategory == cat.$1,
                  selectedColor: AppColors.purpleLight,
                  onTap: () => setState(() => _selectedCategory = cat.$1),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Posts list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(communityPostsProvider(_selectedCategory));
              },
              child: postsAsync.when(
                data: (posts) {
                  if (posts.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 120),
                        Center(child: Text('Chưa có bài viết nào')),
                      ],
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: posts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _PostCard(
                        post: posts[index],
                        onTap: () => context.push('/community/${posts[index].id}'),
                      );
                    },
                  );
                },
                loading: () => const ShimmerPostList(),
                error: (e, _) => Center(child: Text('Lỗi: $e')),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback? onTap;

  const _PostCard({required this.post, this.onTap});

  Color get _categoryColor {
    switch (post.category) {
      case 'tips': return AppColors.backgroundBlue; // blue-100
      case 'drama': return AppColors.pinkLight; // pink-100
      case 'review': return AppColors.yellowLight; // yellow-100
      case 'pass-do': return AppColors.emeraldLight; // green-100
      case 'blog': return AppColors.purpleLight; // purple-100
      default: return AppColors.backgroundBlue;
    }
  }

  Color get _categoryTextColor {
    switch (post.category) {
      case 'tips': return const Color(0xFF1D4ED8); // blue-700
      case 'drama': return const Color(0xFFBE185D); // pink-700
      case 'review': return const Color(0xFF92400E); // amber-800
      case 'pass-do': return const Color(0xFF047857); // emerald-700
      case 'blog': return const Color(0xFF7C3AED); // violet-600
      default: return const Color(0xFF1D4ED8);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NeoBrutalCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: category + author
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _categoryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  communityCategoryLabel(post.category),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _categoryTextColor),
                ),
              ),
              const SizedBox(width: 8),
              if (post.hot == true)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: const Text('HOT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                ),
              const Spacer(),
              Text(
                timeAgo(post.createdAt),
                style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Title
          Text(
            post.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Google Sans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),

          // Preview
          Text(
            post.preview,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),

          // Footer: author + stats
          Row(
            children: [
              Text(
                post.authorName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              _stat(LucideIcons.heart, post.likes),
              const SizedBox(width: 12),
              _stat(LucideIcons.messageCircle, post.comments),
              const SizedBox(width: 12),
              _stat(LucideIcons.eye, post.views),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 3),
        Text(
          '$count',
          style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
        ),
      ],
    );
  }
}
