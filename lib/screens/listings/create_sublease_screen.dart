import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../theme/neo_brutal.dart';
import '../../widgets/neo_brutal_dropdown.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listing_provider.dart';
import '../../data/constants.dart';
import '../../utils/helpers.dart';

class CreateSubleaseScreen extends ConsumerStatefulWidget {
  const CreateSubleaseScreen({super.key});

  @override
  ConsumerState<CreateSubleaseScreen> createState() => _CreateSubleaseScreenState();
}

class _CreateSubleaseScreenState extends ConsumerState<CreateSubleaseScreen> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _addressController = TextEditingController();
  final _moveInController = TextEditingController();
  final _contractController = TextEditingController();
  final _reasonController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _zaloController = TextEditingController();
  String? _selectedCity;
  String? _selectedDistrict;
  List<String> _selectedAmenities = [];
  bool _sameAsPhone = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    _moveInController.dispose();
    _contractController.dispose();
    _reasonController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _zaloController.dispose();
    super.dispose();
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

  bool _validate() {
    if (_titleController.text.trim().length < 5) {
      _showError('Tiêu đề cần ít nhất 5 ký tự');
      return false;
    }
    if (_priceController.text.trim().isEmpty) {
      _showError('Vui lòng nhập giá thuê');
      return false;
    }
    if (_selectedCity == null || _selectedDistrict == null) {
      _showError('Vui lòng chọn khu vực');
      return false;
    }
    if (_descriptionController.text.trim().length < 20) {
      _showError('Mô tả cần ít nhất 20 ký tự');
      return false;
    }
    if (_phoneController.text.trim().isEmpty) {
      _showError('Vui lòng nhập số điện thoại');
      return false;
    }
    return true;
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final user = ref.read(authStateProvider).valueOrNull;
      if (user == null) return;

      final location = [
        getDistrictLabel(_selectedCity, _selectedDistrict),
        getCityLabel(_selectedCity),
      ].where((s) => s != null && s.isNotEmpty).join(', ');

      // Prepend reason to description if provided
      final reason = _reasonController.text.trim();
      final desc = _descriptionController.text.trim();
      final fullDescription = reason.isNotEmpty
          ? 'Lý do sang lại: $reason\n\n$desc'
          : desc;

      final data = <String, dynamic>{
        'category': 'sublease',
        'title': _titleController.text.trim(),
        'price': stripCurrencyDots(_priceController.text.trim()),
        'location': location,
        'city': _selectedCity,
        'district': _selectedDistrict,
        if (_addressController.text.trim().isNotEmpty)
          'specificAddress': _addressController.text.trim(),
        'moveInDate': _moveInController.text.trim().isNotEmpty
            ? _moveInController.text.trim()
            : 'Linh hoạt',
        if (_contractController.text.trim().isNotEmpty)
          'minContractDuration': _contractController.text.trim(),
        'description': fullDescription,
        'introduction': fullDescription,
        'phone': _phoneController.text.trim(),
        if (_sameAsPhone)
          'zalo': _phoneController.text.trim()
        else if (_zaloController.text.trim().isNotEmpty)
          'zalo': _zaloController.text.trim(),
        if (_selectedAmenities.isNotEmpty) 'amenities': _selectedAmenities,
        'author': user.displayName ?? 'Ẩn danh',
        'authorName': user.displayName ?? 'Ẩn danh',
        'userId': user.uid,
        'postedDate': '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
      };

      await ref.read(listingServiceProvider).createListing(data);
      ref.invalidate(listingsProvider);

      if (mounted) _showSuccessDialog();
    } catch (e) {
      _showError('Có lỗi xảy ra: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.emerald,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: const Icon(LucideIcons.check, size: 28),
              ),
              const SizedBox(height: 16),
              const Text(
                'Đăng tin thành công!',
                style: TextStyle(fontFamily: 'Google Sans', fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tin đăng sẽ được duyệt trước khi hiển thị.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              NeoBrutalButton(
                label: 'Về trang chủ',
                backgroundColor: AppColors.orange,
                expanded: true,
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Đăng tin sang lại'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NeoBrutalTextField(
              label: 'Tiêu đề *',
              hint: 'VD: Sang lại phòng studio Q.Bình Thạnh - còn 6 tháng HĐ',
              controller: _titleController,
              maxLength: 150,
            ),
            const SizedBox(height: 14),

            NeoBrutalTextField(
              label: 'Giá thuê hàng tháng *',
              hint: 'VD: 3.500.000',
              controller: _priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyInputFormatter()],
              suffix: 'VNĐ',
            ),
            const SizedBox(height: 14),

            NeoBrutalDropdown<String>(
              label: 'Thành phố *',
              hint: 'Chọn thành phố',
              value: _selectedCity,
              items: cities.map((c) => (c.value, c.label)).toList(),
              onChanged: (val) => setState(() {
                _selectedCity = val;
                _selectedDistrict = null;
              }),
            ),
            const SizedBox(height: 14),

            NeoBrutalDropdown<String>(
              label: 'Quận / Huyện *',
              hint: 'Chọn quận / huyện',
              value: _selectedDistrict,
              items: _selectedCity != null
                  ? getDistrictsByCity(_selectedCity!).map((d) => (d.value, d.label)).toList()
                  : [],
              onChanged: (val) => setState(() => _selectedDistrict = val),
            ),
            const SizedBox(height: 14),

            NeoBrutalTextField(
              label: 'Địa chỉ cụ thể',
              hint: 'Số nhà, đường... (không bắt buộc)',
              controller: _addressController,
            ),
            const SizedBox(height: 14),

            NeoBrutalTextField(
              label: 'Ngày có thể dọn vào',
              hint: 'VD: Từ 01/03/2026 hoặc Linh hoạt',
              controller: _moveInController,
            ),
            const SizedBox(height: 14),

            NeoBrutalTextField(
              label: 'Thời gian hợp đồng còn lại',
              hint: 'VD: Còn 6 tháng (đến 09/2026)',
              controller: _contractController,
            ),
            const SizedBox(height: 14),

            NeoBrutalTextField(
              label: 'Lý do sang lại',
              hint: 'VD: Chuyển công tác, về quê...',
              controller: _reasonController,
            ),
            const SizedBox(height: 14),

            NeoBrutalTextField(
              label: 'Mô tả *',
              hint: 'Mô tả phòng, diện tích, tầng, tiện nghi, tình trạng phòng...',
              controller: _descriptionController,
              maxLines: 6,
            ),
            const SizedBox(height: 20),

            // Amenities toggle
            const Text(
              'Tiện nghi',
              style: TextStyle(fontFamily: 'Google Sans', fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: simpleAmenityOptions.map((opt) {
                final isSelected = _selectedAmenities.contains(opt.$1);
                return NeoBrutalChip(
                  label: opt.$2,
                  selected: isSelected,
                  selectedColor: AppColors.orange,
                  onTap: () {
                    setState(() {
                      final newList = List<String>.from(_selectedAmenities);
                      isSelected ? newList.remove(opt.$1) : newList.add(opt.$1);
                      _selectedAmenities = newList;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            NeoBrutalTextField(
              label: 'Số điện thoại *',
              hint: '0901234567',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),

            // Zalo
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Text(
                    'Zalo',
                    style: TextStyle(fontFamily: 'Google Sans', fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() {
                    _sameAsPhone = !_sameAsPhone;
                    if (_sameAsPhone) _zaloController.text = _phoneController.text;
                  }),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _sameAsPhone ? AppColors.blue : Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: _sameAsPhone ? const Icon(Icons.check, size: 12) : null,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Giống số điện thoại',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (!_sameAsPhone)
                  NeoBrutalTextField(
                    hint: 'Số Zalo (không bắt buộc)',
                    controller: _zaloController,
                    keyboardType: TextInputType.phone,
                  ),
              ],
            ),

            const SizedBox(height: 32),
            NeoBrutalButton(
              label: 'Đăng tin',
              backgroundColor: AppColors.orange,
              expanded: true,
              isLoading: _isSubmitting,
              onPressed: _isSubmitting ? null : _submit,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
