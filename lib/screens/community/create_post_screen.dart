import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../data/constants.dart';
import '../../services/community_service.dart';
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

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _titleController.addListener(() => setState(() {}));
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

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Google Sans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 15),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.blueDark, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Viết bài mới'),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category selection
            const Text(
              'Chọn thể loại *',
              style: TextStyle(
                fontFamily: 'Google Sans', 
                fontSize: 16, 
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: communityCategories.map((cat) {
                final isSelected = _selectedCategory == cat.$1;
                return InkWell(
                  onTap: () => setState(() => _selectedCategory = cat.$1),
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.blueDark : Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: isSelected ? AppColors.blueDark : Colors.grey[300]!,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _categoryIcons[cat.$1] ?? LucideIcons.fileText,
                          size: 16,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          cat.$2,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Title
            _buildTextField(
              label: 'Tiêu đề *',
              hint: 'Tóm tắt nội dung bài viết...',
              controller: _titleController,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${_titleController.text.length}/150',
                    style: TextStyle(
                      fontSize: 12, 
                      color: _titleController.text.length > 150 ? Colors.red : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Content
            _buildTextField(
              label: 'Nội dung chi tiết *',
              hint: 'Chia sẻ đầy đủ câu chuyện của bạn (tối thiểu 20 ký tự)...',
              controller: _contentController,
              maxLines: 8,
            ),
            const SizedBox(height: 24),

            // Conditional: Location
            if (_showLocation) ...[
              _buildTextField(
                label: 'Khu vực / Khu phố',
                hint: 'VD: Quận 7, Cầu Giấy...',
                controller: _locationController,
              ),
              const SizedBox(height: 24),
            ],

            // Conditional: Price
            if (_showPrice) ...[
              _buildTextField(
                label: 'Mức giá (VNĐ)',
                hint: 'VD: 500.000',
                controller: _priceController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
            ],

            // Conditional: Rating
            if (_showRating) ...[
              const Text(
                'Chấm điểm',
                style: TextStyle(fontFamily: 'Google Sans', fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(5, (i) {
                  return GestureDetector(
                    onTap: () => setState(() => _rating = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        LucideIcons.star,
                        size: 36,
                        color: i < _rating ? Colors.amber : Colors.grey[200],
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
            ],

            const SizedBox(height: 12),

            // Submit
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.blueDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Đăng bài',
                        style: TextStyle(
                          fontFamily: 'Google Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 48), // Bottom padding
          ],
        ),
      ),
    );
  }
}
