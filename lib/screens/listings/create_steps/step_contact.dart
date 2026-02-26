import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/neo_brutal.dart';

class StepContact extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController zaloController;
  final TextEditingController facebookController;
  final TextEditingController instagramController;
  final bool sameAsPhone;
  final ValueChanged<bool> onSameAsPhoneChanged;

  const StepContact({
    super.key,
    required this.phoneController,
    required this.zaloController,
    required this.facebookController,
    required this.instagramController,
    required this.sameAsPhone,
    required this.onSameAsPhoneChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin liên hệ',
            style: TextStyle(fontFamily: 'Google Sans', fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Người quan tâm sẽ liên hệ bạn qua các kênh này',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          // Phone
          NeoBrutalTextField(
            label: 'Số điện thoại *',
            hint: '0901234567',
            controller: phoneController,
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
                onTap: () {
                  final newVal = !sameAsPhone;
                  onSameAsPhoneChanged(newVal);
                  if (newVal) {
                    zaloController.text = phoneController.text;
                  }
                },
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: sameAsPhone ? AppColors.blue : Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: sameAsPhone ? const Icon(Icons.check, size: 12) : null,
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
              if (!sameAsPhone)
                NeoBrutalTextField(
                  hint: 'Số Zalo (nếu khác)',
                  controller: zaloController,
                  keyboardType: TextInputType.phone,
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Facebook
          NeoBrutalTextField(
            label: 'Facebook',
            hint: 'Link Facebook (tuỳ chọn)',
            controller: facebookController,
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 14),

          // Instagram
          NeoBrutalTextField(
            label: 'Instagram',
            hint: '@username (tuỳ chọn)',
            controller: instagramController,
          ),

          const SizedBox(height: 32),

          // Info box
          NeoBrutalCard(
            backgroundColor: AppColors.backgroundSky,
            padding: const EdgeInsets.all(14),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lưu ý',
                  style: TextStyle(fontFamily: 'Google Sans', fontSize: 14, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 6),
                Text(
                  'Tin đăng sẽ được duyệt trước khi hiển thị. Quá trình duyệt thường mất 1-2 giờ.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
