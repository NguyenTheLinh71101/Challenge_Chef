import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin user
    final User? user = FirebaseAuth.instance.currentUser;
    final String displayName = user?.displayName ?? 'Đầu bếp bí ẩn';
    final String email = user?.email ?? 'Chưa cập nhật email';
    final String? photoUrl = user?.photoURL;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Bếp cá nhân', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Ảnh đại diện
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.orange.shade100,
                backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                child: photoUrl == null
                    ? const Icon(Icons.person, size: 50, color: Colors.orange)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            // Tên và Email
            Text(
              displayName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              email,
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            
            // Khu vực Thống kê giả lập
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn('Yêu thích', '0'),
                _buildStatColumn('Công thức', '0'),
                _buildStatColumn('Đóng góp', '0'),
              ],
            ),
            const SizedBox(height: 30),
            const Divider(thickness: 1, height: 1),
            
            // Các tùy chọn mở rộng
            _buildActionTile(Icons.favorite_border, 'Món ăn yêu thích của tôi'),
            _buildActionTile(Icons.kitchen, 'Nguyên liệu tủ lạnh'),
            _buildActionTile(Icons.edit_note, 'Chỉnh sửa thông tin cá nhân'),
          ],
        ),
      ),
    );
  }

  // Hàm hỗ trợ vẽ cột thống kê
  Widget _buildStatColumn(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // Hàm hỗ trợ vẽ nút bấm chức năng
  Widget _buildActionTile(IconData icon, String title) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.orange),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        // TODO: Gắn logic chuyển sang các màn hình con tương ứng sau
      },
    );
  }
}