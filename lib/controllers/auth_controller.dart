import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';

class AuthController with ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  User? _currentUser;
  bool _isLoading = false;

  // Khởi tạo controller, lấy thông tin user hiện tại nếu đã đăng nhập trước đó
  AuthController() {
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  // Xử lý Đăng nhập bằng Google
  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.signInWithGoogle();
    } catch (e) {
      print("Lỗi trong AuthController (Google Sign-In): $e");
      _currentUser = null;
    }

    _isLoading = false;
    notifyListeners();

    return _currentUser != null;
  }

  // Xử lý Đăng xuất
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.signOut();
    _currentUser = null;

    _isLoading = false;
    notifyListeners();
  }
}