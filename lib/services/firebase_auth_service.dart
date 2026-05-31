import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  // Theo dõi trạng thái đăng nhập
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Đăng nhập Email
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.user;
    } catch (e) {
      print("Lỗi đăng nhập Email: $e");
      return null;
    }
  }

  // Đăng ký
  Future<User?> signUp(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Cập nhật Họ và Tên (displayName) cho tài khoản vừa tạo
      await result.user?.updateDisplayName(name);
      await result.user?.reload(); // Làm mới dữ liệu người dùng

      return _auth.currentUser;
    } on FirebaseAuthException {
      // Bắt lỗi từ Firebase và ném ra ngoài để giao diện UI xử lý thông báo
      rethrow;
    } catch (e) {
      print("Lỗi đăng ký: $e");
      return null;
    }
  }

  // Đăng nhập Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      return userCredential.user;
    } catch (e) {
      print("Lỗi đăng nhập Google: $e");
      return null;
    }
  }

  // Đăng xuất (Đã được sửa lỗi triệt để)
  Future<void> signOut() async {
    try {
      // 1. Đăng xuất khỏi Google
      await _googleSignIn.signOut();
      
      // 2. Ngắt kết nối hoàn toàn để xóa cache, buộc hiện lại bảng chọn tài khoản lần sau
      // (Dùng try-catch bọc lại vì nếu user đăng nhập bằng Email thì hàm này có thể báo lỗi nhẹ)
      try {
        await _googleSignIn.disconnect();
      } catch (e) {
        print("Bỏ qua lỗi disconnect (Có thể user không dùng Google): $e");
      }

      // 3. Đăng xuất khỏi Firebase
      await _auth.signOut();
      
    } catch (e) {
      print("Lỗi khi đăng xuất: $e");
    }
  }
}