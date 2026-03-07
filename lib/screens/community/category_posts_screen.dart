import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../models/community_post.dart';
import '../../services/community_service.dart';
import '../../utils/helpers.dart';
import '../../widgets/shimmer_loading.dart';
import 'community_screen.dart'; // to reuse the _PostCardCarouselItem mostly, or we can just redefine a simpler one

class CategoryPostsScreen extends ConsumerStatefulWidget {
  final String categoryId;

  const CategoryPostsScreen({super.key, required this.categoryId});

  @override
  ConsumerState<CategoryPostsScreen> createState() => _CategoryPostsScreenState();
}

class _CategoryPostsScreenState extends ConsumerState<CategoryPostsScreen> {
  
  String get _categoryName {
    switch (widget.categoryId) {
      case 'pass-do': return 'Pass đồ';
      case 'review': return 'Review';
      case 'drama': return 'Drama';
      case 'tips': return 'Tips';
      case 'blog': return 'Blog';
      default: return 'Cộng đồng';
    }
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(communityPostsProvider(widget.categoryId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _categoryName,
          style: const TextStyle(
            fontFamily: 'Google Sans',
            color: AppColors.blueDark,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/community/create?category=${widget.categoryId}'),
        backgroundColor: AppColors.blueDark,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
      body: RefreshIndicator(
        color: AppColors.blueDark,
        onRefresh: () async {
          return ref.refresh(communityPostsProvider(widget.categoryId));
        },
        child: postsAsync.when(
          data: (posts) {
            if (posts.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Column(
                      children: [
                        const Icon(LucideIcons.inbox, size: 48, color: AppColors.textTertiary),
                        const SizedBox(height: 16),
                        const Text(
                          'Chưa có bài viết nào',
                          style: TextStyle(
                            fontFamily: 'Google Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Hãy là người đầu tiên chia sẻ\nvề chủ đề này nhé!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () => context.push('/community/create?category=${widget.categoryId}'),
                          icon: const Icon(LucideIcons.penTool, size: 18),
                          label: const Text('Viết bài ngay', style: TextStyle(fontWeight: FontWeight.w600)),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.blueDark,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: posts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final post = posts[index];
                return _PostCardList(
                  post: post,
                  onTap: () => context.push('/community/${post.id}'),
                );
              },
            );
          },
          loading: () => const SingleChildScrollView(child: ShimmerPostList()),
          error: (e, _) => Center(child: Text('Lỗi: $e')),
        ),
      ),
    );
  }
}

// Full width generic list card
class _PostCardList extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback? onTap;

  const _PostCardList({required this.post, this.onTap});

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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Text(
              post.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Google Sans',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.3,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              post.preview,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 12),
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
                const SizedBox(width: 16),
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
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
