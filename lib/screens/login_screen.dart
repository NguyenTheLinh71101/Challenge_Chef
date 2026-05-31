import 'package:flutter/material.dart';
import '../services/firebase_auth_service.dart';
import '../core/constants.dart'; // Chứa AppColors.background, AppColors.primary
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isLoading = false;

  // Xử lý Đăng nhập bằng Email
  void _handleLogin() async {
    // 1. Dọn dẹp ngay các thông báo cũ còn kẹt trên màn hình
    ScaffoldMessenger.of(context).clearSnackBars();

    setState(() => _isLoading = true);
    
    final user = await _authService.signIn(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    // 2. Chỉ hiện thông báo lỗi khi user bị null (đăng nhập thất bại)
    if (user == null) {
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text('Email hoặc mật khẩu không chính xác !'),
      //       duration: Duration(seconds: 2), // Rút ngắn thời gian hiển thị xuống 2 giây
      //     ),
      //   );
      // }
    } else {
      // 3. (Tùy chọn) Đảm bảo sạch sẽ thông báo một lần nữa trước khi qua trang Home
      ScaffoldMessenger.of(context).clearSnackBars();
    }
  }

  // Xử lý Đăng nhập bằng Google
  void _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    
    final user = await _authService.signInWithGoogle();

    setState(() => _isLoading = false);

    if (user == null) {
      // if (mounted) {
      //   // ScaffoldMessenger.of(context).showSnackBar(
      //   //   const SnackBar(content: Text('Đăng nhập Google thất bại hoặc đã bị hủy!')),
      //   // );
      // }
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
                height: 150, // Bạn có thể tăng giảm số này để chỉnh kích thước logo
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 40),

              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text('Đăng Nhập', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              
              const SizedBox(height: 20),
              
              const Row(
                children: [
                  Expanded(child: Divider(thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("HOẶC", style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider(thickness: 1)),
                ],
              ),
              
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  // Thay thế link ảnh ở đây
                  icon: Image.network(
                    'https://img.icons8.com/color/48/000000/google-logo.png',
                    height: 24,
                  ),
                  label: const Text(
                    'Đăng nhập với Google',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                ),
              ),

              const SizedBox(height: 20),

              // CHÍNH LÀ ĐOẠN NÀY: Nút chuyển sang trang đăng ký được bổ sung
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Chưa có tài khoản?',
                    style: TextStyle(fontSize: 15),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Text(
                      'Đăng ký ngay',
                      style: TextStyle(
                        color: Colors.orange, 
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}