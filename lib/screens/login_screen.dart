import 'package:flutter/material.dart';
import '../services/firebase_auth_service.dart';
import '../core/constants.dart'; // Chứa AppColors.background, AppColors.primary

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isLoading = false;

  // Xử lý Đăng nhập bằng Google
  void _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    
    final user = await _authService.signInWithGoogle();

    setState(() => _isLoading = false);

    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Đăng nhập Google thất bại hoặc đã bị hủy!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red, // Thêm nền đỏ cho báo lỗi
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo_app.png',
                height: 180, // Tăng nhẹ kích thước logo để lấp khoảng trống
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 60), // Tăng khoảng cách để cân đối màn hình

              SizedBox(
                width: double.infinity,
                height: 55, // Nút to hơn một chút để dễ bấm
                child: OutlinedButton.icon(
                  icon: _isLoading 
                      ? const SizedBox(
                          width: 24, 
                          height: 24, 
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.orange)
                        )
                      : Image.network(
                          'https://img.icons8.com/color/48/000000/google-logo.png',
                          height: 28,
                        ),
                  label: Text(
                    _isLoading ? 'Đang kết nối...' : 'Đăng nhập với Google',
                    style: const TextStyle(
                      fontSize: 16, 
                      color: Colors.black87, 
                      fontWeight: FontWeight.w600
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white, // Nền trắng giúp nút nổi bật hơn
                    elevation: 2, // Thêm đổ bóng nhẹ
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}