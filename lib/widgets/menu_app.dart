import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';

// TẠM ẨN IMPORT: Comment lại để tránh báo lỗi "unused import" (thư viện không được sử dụng)
// import '../screens/profile_screen.dart'; 
// import '../screens/my_cookbook_screen.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // Tự động lấy thông tin người dùng đang đăng nhập từ Firebase
    final User? user = FirebaseAuth.instance.currentUser;
    final String displayName = user?.displayName ?? 'Đầu bếp bí ẩn';
    final String email = user?.email ?? 'Chưa cập nhật email';
    final String? photoUrl = user?.photoURL;

    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Phần Header hiển thị thông tin thật
          Container(
            padding: const EdgeInsets.only(top: 60, left: 20, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.orange.shade100,
                  backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                  // Nếu không có ảnh, hiển thị icon mặc định
                  child: photoUrl == null 
                      ? const Icon(Icons.person, size: 30, color: Colors.orange) 
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  displayName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  email,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  '0 Món ăn yêu thích  •  0 Đóng góp', // Dữ liệu giả lập cho đẹp mắt
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Divider(), 
          
          /* ==========================================
             BẮT ĐẦU PHẦN TẠM ẨN CÁC MENU
             ========================================== 
          // Truyền thêm action chuyển trang cho mục Bếp cá nhân
          _buildMenuItem(Icons.person_outline, 'Bếp cá nhân', context, onTap: () {
            Navigator.pop(context); // Đóng menu trước
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }),
          // THÊM NÚT CẨM NANG CỦA TÔI
          _buildMenuItem(Icons.menu_book, 'Cẩm nang của tôi', context, onTap: () {
            Navigator.pop(context); // Đóng menu trước
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyCookbookScreen()), // Chuyển sang trang mới
            );
          }), 
          _buildMenuItem(Icons.history, 'Món Vừa Xem', context),
          _buildMenuItem(Icons.settings_outlined, 'Cài đặt', context),
          
          const Divider(), 
             ==========================================
             KẾT THÚC PHẦN TẠM ẨN
             ========================================== */
          
          // Nút Đăng Xuất
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              'Đăng xuất',
              style: TextStyle(
                fontSize: 15, 
                fontWeight: FontWeight.w600, 
                color: Colors.redAccent
              ),
            ),
            onTap: () async {
              Navigator.pop(context); 
              await FirebaseAuthService().signOut(); 
            },
          ),
        ],
      ),
    );
  }

  // Cập nhật hàm này để nhận thêm thuộc tính onTap tùy chỉnh
  // ignore: unused_element
  Widget _buildMenuItem(IconData icon, String title, BuildContext context, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      onTap: onTap ?? () {
        Navigator.pop(context); 
      },
    );
  }
}