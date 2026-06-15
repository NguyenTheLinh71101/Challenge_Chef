import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/recipe_model.dart';

const String _defaultAuthorName = 'Đầu bếp bí ẩn';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 1. LẤY TOÀN BỘ CÔNG THỨC (Dùng cho trang chủ/tìm kiếm chung)
  Future<List<Recipe>> getRecipes() async {
    try {
      QuerySnapshot snapshot = await _db.collection('recipes').get();
      return snapshot.docs.map((doc) {
        return Recipe.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print("Lỗi tải toàn bộ công thức: $e");
      return [];
    }
  }

  /// 2. LẤY CÔNG THỨC RIÊNG CỦA TÔI (Hiển thị trong Cẩm nang của bạn)
  Future<List<Recipe>> getMyRecipes() async {
    try {
      String? currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return [];

      // Lọc các công thức có thuộc tính 'userId' trùng với tài khoản hiện tại
      QuerySnapshot snapshot = await _db
          .collection('recipes')
          .where('userId', isEqualTo: currentUserId)
          .get();
          
      return snapshot.docs.map((doc) {
        return Recipe.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print("Lỗi tải cẩm nang cá nhân: $e");
      return [];
    }
  }

  /// 3. HÀM THÊM CÔNG THỨC MỚI (Ánh xạ từ Form giao diện lên Database)
  Future<void> addRecipe(Recipe recipe) async {
    try {
      String? currentUserId = _auth.currentUser?.uid;

      // Gom các trường thông tin cơ bản từ UI
      Map<String, dynamic> firestoreData = {
        'id': recipe.id,
        'title': recipe.title,
        'instructions': recipe.instructions,
        'imageUrl': recipe.imageUrl,
        'userId': currentUserId, // Định danh chủ sở hữu bài viết
      };
      
      // Khởi tạo sẵn cấu trúc 20 nguyên liệu trống
      for (int i = 1; i <= 20; i++) {
        firestoreData['strIngredient$i'] = '';
        firestoreData['strMeasure$i'] = '';
      }

      // Đổ danh sách nguyên liệu từ UI bóc tách được vào các trường tương ứng
      for (int i = 0; i < recipe.detailIngredients.length; i++) {
        if (i < 20) {
          firestoreData['strIngredient${i + 1}'] = recipe.detailIngredients[i];
        }
      }

      // Đẩy dữ liệu lên bộ sưu tập 'recipes' trên đám mây kèm bộ hẹn giờ chống treo app
      await _db.collection('recipes').doc(recipe.id).set(firestoreData).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception("Kết nối mạng yếu hoặc chưa cấu hình Firestore Database trên Firebase Console.");
        },
      );

    } catch (e) {
      print("Lỗi thực thi thêm công thức: $e");
      rethrow;
    }
  }

  /// 4. HÀM CẬP NHẬT / SỬA CÔNG THỨC
  Future<void> updateRecipe(Recipe recipe) async {
    try {
      Map<String, dynamic> firestoreData = {
        'title': recipe.title,
        'instructions': recipe.instructions,
        'imageUrl': recipe.imageUrl,
      };
      
      // Xóa trắng dữ liệu cũ của 20 nguyên liệu để tránh rác dữ liệu khi ghi đè dữ liệu mới ít ký tự hơn
      for (int i = 1; i <= 20; i++) {
        firestoreData['strIngredient$i'] = '';
        firestoreData['strMeasure$i'] = '';
      }

      // Nạp danh sách nguyên liệu đã chỉnh sửa mới vào
      for (int i = 0; i < recipe.detailIngredients.length; i++) {
        if (i < 20) {
          firestoreData['strIngredient${i + 1}'] = recipe.detailIngredients[i];
        }
      }

      // Tiến hành cập nhật lên Document tương ứng trên Firestore
      await _db.collection('recipes').doc(recipe.id).update(firestoreData).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception("Thời gian kết nối quá hạn. Không thể lưu thay đổi.");
        },
      );
    } catch (e) {
      print("Lỗi thực thi cập nhật công thức: $e");
      rethrow;
    }
  }

  /// 5. HÀM XÓA CÔNG THỨC
  Future<void> deleteRecipe(String recipeId) async {
    try {
      await _db.collection('recipes').doc(recipeId).delete().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception("Không thể thực hiện lệnh xóa dữ liệu do sự cố kết nối.");
        },
      );
    } catch (e) {
      print("Lỗi thực thi xóa công thức: $e");
      rethrow;
    }
  }

  /// 6. ĐỒNG BỘ HỒ SƠ NGƯỜI DÙNG LÊN COLLECTION 'users'
  Future<void> syncUserProfile(User user) async {
    try {
      await _db.collection('users').doc(user.uid).set({
        'displayName': user.displayName ?? _defaultAuthorName,
        'email': user.email ?? '',
        'photoUrl': user.photoURL ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print("Lỗi đồng bộ hồ sơ người dùng: $e");
    }
  }

  /// 7. TRA CỨU TÊN HIỂN THỊ THEO DANH SÁCH userId
  Future<Map<String, String>> getDisplayNamesByIds(Set<String> userIds) async {
    if (userIds.isEmpty) return {};

    final Map<String, String> result = {};
    final ids = userIds.where((id) => id.isNotEmpty).toList();

    try {
      final snapshots = await Future.wait(
        ids.map((id) => _db.collection('users').doc(id).get()),
      );

      for (final doc in snapshots) {
        if (!doc.exists) continue;
        final data = doc.data();
        result[doc.id] = data?['displayName'] as String? ?? _defaultAuthorName;
      }
    } catch (e) {
      print("Lỗi tra cứu tên người dùng: $e");
    }

    return result;
  }

  Future<List<Recipe>> _attachAuthorNames(List<Recipe> recipes) async {
    final userIds = recipes
        .map((recipe) => recipe.userId)
        .where((id) => id != null && id.isNotEmpty)
        .cast<String>()
        .toSet();

    final nameMap = await getDisplayNamesByIds(userIds);

    return recipes.map((recipe) {
      if (recipe.userId == null || recipe.userId!.isEmpty) {
        return recipe;
      }
      return recipe.copyWith(
        authorName: nameMap[recipe.userId] ?? _defaultAuthorName,
      );
    }).toList();
  }

  /// 8. LẤY CÔNG THỨC CỘNG ĐỒNG (Tất cả món ăn do người dùng tự tạo đóng góp công khai)
  Future<List<Recipe>> getCommunityRecipes() async {
    try {
      // Thử truy vấn trực tiếp từ Firestore để tối ưu băng thông
      QuerySnapshot snapshot = await _db
          .collection('recipes')
          .where('userId', isNotEqualTo: null)
          .get();

      final recipes = snapshot.docs.map((doc) {
        return Recipe.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      return _attachAuthorNames(recipes);
    } catch (e) {
      print("Lỗi truy vấn trực tiếp community index, chuyển sang bộ lọc RAM dự phòng: $e");
      try {
        // Cơ chế dự phòng: Lấy toàn bộ hồ chứa về rồi lọc ra những món có tác giả (userId != null)
        QuerySnapshot snapshot = await _db.collection('recipes').get();
        final recipes = snapshot.docs
            .map((doc) => Recipe.fromJson(doc.data() as Map<String, dynamic>))
            .where((recipe) => recipe.userId != null && recipe.userId!.isNotEmpty)
            .toList();

        return _attachAuthorNames(recipes);
      } catch (err) {
        print("Lỗi hệ thống lưu trữ cộng đồng: $err");
        return [];
      }
    }
  }
}