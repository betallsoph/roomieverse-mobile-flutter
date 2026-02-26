import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  int _mode = 0; // 0 = login, 1 = signup, 2 = forgot
  bool _isLoading = false;
  String? _error;
  String? _success;
  bool _obscurePassword = true;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounceAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.08).chain(CurveTween(curve: Curves.easeOut)), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 0.97).chain(CurveTween(curve: Curves.easeInOut)), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.97, end: 1.0).chain(CurveTween(curve: Curves.easeOut)), weight: 30),
    ]).animate(_bounceController);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'wrong-password':
        return 'Mật khẩu không đúng.';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng.';
      case 'weak-password':
        return 'Mật khẩu quá yếu (tối thiểu 6 ký tự).';
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'too-many-requests':
        return 'Quá nhiều lần thử. Vui lòng đợi một lúc.';
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không đúng.';
      default:
        return 'Có lỗi xảy ra. Vui lòng thử lại.';
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final authService = ref.read(authServiceProvider);
      final userService = ref.read(userServiceProvider);
      final user = await authService.signInWithGoogle();
      if (user != null) {
        await userService.createProfileIfNotExists(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? '',
          photoURL: user.photoURL,
        );
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _error = 'Đăng nhập Google thất bại.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEmailAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || (_mode != 2 && password.isEmpty)) {
      setState(() => _error = 'Vui lòng điền đầy đủ thông tin.');
      return;
    }
    if (_mode == 1 && name.isEmpty) {
      setState(() => _error = 'Vui lòng nhập tên hiển thị.');
      return;
    }

    setState(() { _isLoading = true; _error = null; _success = null; });

    try {
      final authService = ref.read(authServiceProvider);
      final userService = ref.read(userServiceProvider);

      if (_mode == 0) {
        final user = await authService.signInWithEmail(email, password);
        if (user != null && mounted) Navigator.pop(context);
      } else if (_mode == 1) {
        final user = await authService.signUpWithEmail(email, password, name);
        if (user != null) {
          await userService.createProfileIfNotExists(
            uid: user.uid,
            email: user.email ?? '',
            displayName: name,
            photoURL: user.photoURL,
          );
          if (mounted) Navigator.pop(context);
        }
      } else {
        await authService.sendPasswordReset(email);
        setState(() => _success = 'Email đặt lại mật khẩu đã được gửi!');
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _mapFirebaseError(e.code));
    } catch (e) {
      setState(() => _error = 'Có lỗi xảy ra. Vui lòng thử lại.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _switchMode(int mode) {
    if (_mode == mode) return;
    setState(() { _mode = mode; _error = null; _success = null; });
    _bounceController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 48),

              ScaleTransition(
                scale: _bounceAnim,
                child: Image.asset('assets/images/logo1.png', height: 96),
              ),
              const SizedBox(height: 32),

              // Tab toggle
              if (_mode != 2)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      _buildTab('Đăng nhập', 0),
                      _buildTab('Đăng ký', 1),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Google sign-in
              if (_mode != 2) ...[
                _buildOutlinedButton(
                  icon: LucideIcons.chrome,
                  label: 'Tiếp tục với Google',
                  onTap: _isLoading ? null : _handleGoogleSignIn,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'hoặc',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // Name field (signup)
              if (_mode == 1) ...[
                _buildTextField(
                  label: 'Tên hiển thị',
                  hint: 'VD: Minh Anh',
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 16),
              ],

              // Email
              _buildTextField(
                label: _mode == 2 ? 'Nhập email để đặt lại mật khẩu' : 'Email',
                hint: 'you@roomieverse.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),

              // Password
              if (_mode != 2) ...[
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Mật khẩu',
                  hint: '••••••••',
                  controller: _passwordController,
                  obscure: true,
                ),
              ],

              // Forgot password link
              if (_mode == 0) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => _switchMode(2),
                    child: const Text(
                      'Quên mật khẩu?',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blueDark,
                      ),
                    ),
                  ),
                ),
              ],

              // Error / Success
              if (_error != null) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFFDC2626)),
                  ),
                ),
              ],
              if (_success != null) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _success!,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF059669)),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleEmailAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueLight,
                    foregroundColor: AppColors.textPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(
                          _mode == 0
                              ? 'ĐĂNG NHẬP'
                              : _mode == 1
                                  ? 'ĐĂNG KÝ'
                                  : 'GỬI EMAIL ĐẶT LẠI',
                          style: const TextStyle(
                            fontFamily: 'Google Sans',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),

              // Back to login from forgot
              if (_mode == 2) ...[
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _switchMode(0),
                  child: const Text(
                    'Quay lại đăng nhập',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.blueDark),
                  ),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, int mode) {
    final selected = _mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => _switchMode(mode),
        child: AnimatedScale(
          scale: selected ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutBack,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? AppColors.blueLight : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Google Sans',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.textPrimary : AppColors.textTertiary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/google_logo.png', width: 26, height: 26),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Google Sans',
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Google Sans',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscure ? _obscurePassword : false,
            style: const TextStyle(fontFamily: 'Google Sans', fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              border: InputBorder.none,
              suffixIcon: obscure
                  ? GestureDetector(
                      onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                      child: Icon(
                        _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                        size: 18,
                        color: Colors.grey.shade400,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

