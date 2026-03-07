import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../../theme/app_theme.dart';
import '../../models/community_post.dart';
import '../../services/community_service.dart';
import '../../utils/helpers.dart';
import '../../widgets/shimmer_loading.dart';

final communityServiceProvider = Provider((ref) => CommunityService());

final communityPostsProvider =
    FutureProvider.family<List<CommunityPost>, String?>((ref, category) async {
  return ref.watch(communityServiceProvider).getPosts(category: category);
});

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  static const _categories = [
    ('pass-do', 'Góc pass đồ'),
    ('review', 'Review'),
    ('drama', 'Drama'),
    ('tips', 'Tips'),
    ('blog', 'Blog'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We fetch all posts (with a reasonable limit from service) then group them locally
    final postsAsync = ref.watch(communityPostsProvider(null));

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/community/create'),
        backgroundColor: AppColors.blueDark,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'Cộng đồng',
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            // Posts by category
            Expanded(
              child: RefreshIndicator(
                color: AppColors.blueDark,
                onRefresh: () async {
                  return ref.refresh(communityPostsProvider(null));
                },
                child: postsAsync.when(
                  data: (posts) {
                    if (posts.isEmpty) {
                      return ListView(
                        children: const [
                          SizedBox(height: 120),
                          Center(
                            child: Text(
                              'Chưa có bài viết nào',
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        List<CommunityPost> catPosts = posts.where((p) => p.category == cat.$1).toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    cat.$2,
                                    style: const TextStyle(
                                      fontFamily: 'Google Sans',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.blueDark,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // TODO: Go to list all screen
                                      context.push('/community/category/${cat.$1}');
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.blueDark,
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Xem tất cả',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 190,
                              child: catPosts.isEmpty
                                  ? ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      itemCount: 3,
                                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                                      itemBuilder: (context, idx) {
                                        return const SizedBox(
                                          width: 250,
                                          child: _EmptyPlaceholderCard(),
                                        );
                                      },
                                    )
                                  : ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      itemCount: catPosts.length > 5 ? 5 : catPosts.length, // Show up to 5 items in preview
                                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                                      itemBuilder: (context, idx) {
                                        final post = catPosts[idx];
                                        return SizedBox(
                                          width: 280,
                                          child: _PostCardCarouselItem(
                                            post: post,
                                            onTap: () => context.push('/community/${post.id}'),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                            const SizedBox(height: 16),
                            if (index < _categories.length - 1)
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
                              ),
                          ],
                        );
                      },
                    );
                  },
                  loading: () => const SingleChildScrollView(child: ShimmerPostList()),
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

// A specialized version of _PostCard that is optimized for horizontal carousel
class _PostCardCarouselItem extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback? onTap;

  const _PostCardCarouselItem({required this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: category + author
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (post.hot == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Text(
                            'HOT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.red[700],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  timeAgo(post.createdAt),
                  style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                ),
              ],
            ),
            const SizedBox(height: 12),

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
                letterSpacing: -0.3,
              ),
            ),
            const Spacer(),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 12),

            // Footer: author + stats
            Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.grey[200],
                  child: Text(
                    post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    post.authorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _stat(LucideIcons.heart, post.likes),
                const SizedBox(width: 12),
                _stat(LucideIcons.messageCircle, post.comments),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _EmptyPlaceholderCard extends StatelessWidget {
  const _EmptyPlaceholderCard();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: Colors.black.withOpacity(0.15),
        radius: 16,
        gap: 6,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.inbox, size: 36, color: AppColors.textTertiary),
            SizedBox(height: 12),
            Text(
              'Chưa có bài viết',
              style: TextStyle(
                fontFamily: 'Google Sans',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Hãy là người đầu tiên\nchia sẻ nhé!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double radius;

  _DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height), 
        Radius.circular(radius)
      ));

    final dashPath = Path();
    double distance = 0.0;
    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
