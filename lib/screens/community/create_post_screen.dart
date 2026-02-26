import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../theme/neo_brutal.dart';
import '../../providers/auth_provider.dart';
import '../../data/constants.dart';
import 'community_screen.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  final String? initialCategory;
  const CreatePostScreen({super.key, this.initialCategory});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  String? _selectedCategory;
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  int _rating = 0;
  bool _isSubmitting = false;

  static const _categoryIcons = {
    'tips': LucideIcons.lightbulb,
    'drama': LucideIcons.flame,
    'review': LucideIcons.star,
    'pass-do': LucideIcons.shoppingBag,
    'blog': LucideIcons.bookOpen,
  };

  static const _categoryColors = {
    'tips': AppColors.blue,
    'drama': AppColors.pink,
    'review': AppColors.yellow,
    'pass-do': AppColors.emerald,
    'blog': AppColors.purple,
  };

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  bool get _showLocation => _selectedCategory == 'review' || _selectedCategory == 'pass-do';
  bool get _showPrice => _selectedCategory == 'pass-do';
  bool get _showRating => _selectedCategory == 'review';

  Future<void> _submit() async {
    if (_selectedCategory == null) {
      _showError('Vui lòng chọn thể loại');
      return;
    }
    if (_titleController.text.trim().length < 5) {
      _showError('Tiêu đề cần tối thiểu 5 ký tự');
      return;
    }
    if (_contentController.text.trim().length < 20) {
      _showError('Nội dung cần tối thiểu 20 ký tự');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = ref.read(authStateProvider).valueOrNull;
      if (user == null) return;

      final data = <String, dynamic>{
        'authorId': user.uid,
        'authorName': user.displayName ?? '',
        'authorPhoto': user.photoURL,
        'category': _selectedCategory,
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        if (_showLocation && _locationController.text.trim().isNotEmpty)
          'location': _locationController.text.trim(),
        if (_showPrice && _priceController.text.trim().isNotEmpty)
          'price': _priceController.text.trim(),
        if (_showRating && _rating > 0)
          'rating': _rating,
      };

      await ref.read(communityServiceProvider).createPost(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng bài thành công!'),
            backgroundColor: Colors.black,
          ),
        );
        context.pop();
      }
    } catch (e) {
      _showError('Có lỗi xảy ra: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Viết bài mới'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category selection
            const Text(
              'Thể loại *',
              style: TextStyle(fontFamily: 'Google Sans', fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.2,
              children: communityCategories.map((cat) {
                final isSelected = _selectedCategory == cat.$1;
                return NeoBrutalCard(
                  backgroundColor: isSelected
                      ? (_categoryColors[cat.$1] ?? AppColors.blue).withValues(alpha: 0.4)
                      : Colors.white,
                  onTap: () => setState(() => _selectedCategory = cat.$1),
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Icon(
                        _categoryIcons[cat.$1] ?? LucideIcons.fileText,
                        size: 18,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          cat.$2,
                          style: TextStyle(
                            fontFamily: 'Google Sans',
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Title
            NeoBrutalTextField(
              label: 'Tiêu đề *',
              hint: 'Tiêu đề bài viết (tối thiểu 5 ký tự)',
              controller: _titleController,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${_titleController.text.length}/150 ký tự',
                style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
              ),
            ),
            const SizedBox(height: 14),

            // Content
            NeoBrutalTextField(
              label: 'Nội dung *',
              hint: 'Viết nội dung bài viết (tối thiểu 20 ký tự)...',
              controller: _contentController,
              maxLines: 8,
            ),
            const SizedBox(height: 14),

            // Conditional: Location
            if (_showLocation) ...[
              NeoBrutalTextField(
                label: 'Vị trí',
                hint: 'Quận, thành phố...',
                controller: _locationController,
              ),
              const SizedBox(height: 14),
            ],

            // Conditional: Price
            if (_showPrice) ...[
              NeoBrutalTextField(
                label: 'Giá',
                hint: 'VD: 500.000 VNĐ',
                controller: _priceController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),
            ],

            // Conditional: Rating
            if (_showRating) ...[
              const Text(
                'Đánh giá',
                style: TextStyle(fontFamily: 'Google Sans', fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (i) {
                  return GestureDetector(
                    onTap: () => setState(() => _rating = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(
                        i < _rating ? LucideIcons.star : LucideIcons.star,
                        size: 28,
                        color: i < _rating ? AppColors.yellow : AppColors.gray,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 14),
            ],

            const SizedBox(height: 20),

            // Submit
            NeoBrutalButton(
              label: 'Đăng bài',
              backgroundColor: AppColors.emerald,
              expanded: true,
              isLoading: _isSubmitting,
              onPressed: _isSubmitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
