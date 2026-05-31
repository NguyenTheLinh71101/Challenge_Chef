import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';

class AuthController with ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    _currentUser = await _authService.signIn(email, password);

    _isLoading = false;
    notifyListeners();
    return _currentUser != null;
  }
}