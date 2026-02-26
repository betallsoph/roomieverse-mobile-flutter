import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../theme/neo_brutal.dart';
import '../../models/community_post.dart';
import '../../models/community_comment.dart';
import '../../providers/auth_provider.dart';
import '../../utils/helpers.dart';
import 'community_screen.dart';

final postDetailProvider =
    FutureProvider.family<CommunityPost?, String>((ref, id) async {
  return ref.watch(communityServiceProvider).getPostById(id);
});

final commentsProvider =
    FutureProvider.family<List<CommunityComment>, String>((ref, postId) async {
  return ref.watch(communityServiceProvider).getComments(postId);
});

class PostDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const PostDetailScreen({super.key, required this.id});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _commentController = TextEditingController();
  bool _isLiked = false;
  int _likeCount = 0;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postAsync = ref.watch(postDetailProvider(widget.id));
    final commentsAsync = ref.watch(commentsProvider(widget.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bài viết'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: postAsync.when(
        data: (post) {
          if (post == null) {
            return const Center(child: Text('Không tìm thấy bài viết'));
          }

          if (_likeCount == 0) _likeCount = post.likes;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category + date
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _categoryColor(post.category),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.black, width: 1.5),
                            ),
                            child: Text(
                              communityCategoryLabel(post.category),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            timeAgo(post.createdAt),
                            style: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Title
                      Text(
                        post.title,
                        style: const TextStyle(
                          fontFamily: 'Google Sans',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Author
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.blue,
                            child: Text(
                              post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '?',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            post.authorName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Content
                      Text(
                        post.content,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Like + stats row
                      Row(
                        children: [
                          NeoBrutalButton(
                            label: '$_likeCount',
                            icon: _isLiked ? LucideIcons.heartOff : LucideIcons.heart,
                            backgroundColor: _isLiked ? AppColors.pink : Colors.white,
                            onPressed: () async {
                              final user = ref.read(authStateProvider).valueOrNull;
                              if (user == null) return;
                              final service = ref.read(communityServiceProvider);
                              final liked = await service.togglePostLike(widget.id, user.uid);
                              setState(() {
                                _isLiked = liked;
                                _likeCount += liked ? 1 : -1;
                              });
                            },
                          ),
                          const SizedBox(width: 12),
                          Icon(LucideIcons.messageCircle, size: 16, color: AppColors.textTertiary),
                          const SizedBox(width: 4),
                          Text('${post.comments}', style: const TextStyle(color: AppColors.textTertiary)),
                          const SizedBox(width: 12),
                          Icon(LucideIcons.eye, size: 16, color: AppColors.textTertiary),
                          const SizedBox(width: 4),
                          Text('${post.views}', style: const TextStyle(color: AppColors.textTertiary)),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Divider(thickness: 2, color: Colors.black12),
                      const SizedBox(height: 16),

                      // Comments
                      Text(
                        'Bình luận (${post.comments})',
                        style: const TextStyle(
                          fontFamily: 'Google Sans',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      commentsAsync.when(
                        data: (comments) {
                          if (comments.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: Text('Chưa có bình luận nào', style: TextStyle(color: AppColors.textTertiary)),
                              ),
                            );
                          }
                          return Column(
                            children: comments.map((c) => _CommentItem(comment: c)).toList(),
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Text('Lỗi: $e'),
                      ),
                    ],
                  ),
                ),
              ),

              // Comment input
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.black, width: 2)),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: TextField(
                            controller: _commentController,
                            decoration: const InputDecoration(
                              hintText: 'Viết bình luận...',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () async {
                          final text = _commentController.text.trim();
                          if (text.isEmpty) return;
                          final user = ref.read(authStateProvider).valueOrNull;
                          if (user == null) return;
                          final service = ref.read(communityServiceProvider);
                          await service.createComment({
                            'postId': widget.id,
                            'authorId': user.uid,
                            'authorName': user.displayName ?? 'Ẩn danh',
                            'authorPhoto': user.photoURL,
                            'content': text,
                          });
                          _commentController.clear();
                          ref.invalidate(commentsProvider(widget.id));
                          ref.invalidate(postDetailProvider(widget.id));
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.blue,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: const Icon(LucideIcons.send, size: 18),
                        ),
                      ),
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

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'tips': return AppColors.blue;
      case 'drama': return AppColors.pink;
      case 'review': return AppColors.yellow;
      case 'pass-do': return AppColors.emerald;
      case 'blog': return AppColors.purple;
      default: return AppColors.blue;
    }
  }
}

class _CommentItem extends StatelessWidget {
  final CommunityComment comment;
  const _CommentItem({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.pink,
            child: Text(
              comment.authorName.isNotEmpty ? comment.authorName[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.authorName,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeAgo(comment.createdAt),
                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  comment.content,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
