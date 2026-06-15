import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/recipe_controller.dart';
import 'recipe_detail_screen.dart'; // ĐÃ MỞ COMMENT DÒNG NÀY

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  @override
  void initState() {
    super.initState();
    // Tự động gọi nạp dữ liệu cộng đồng khi màn hình vừa được mở
    Future.microtask(() =>
        Provider.of<RecipeController>(context, listen: false).fetchCommunityRecipes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Cộng đồng ẩm thực',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: Consumer<RecipeController>(
        builder: (context, controller, child) {
          if (controller.isCommunityLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          if (controller.communityRecipes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có món ăn nào được chia sẻ.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: Colors.orange,
            onRefresh: () async {
              await controller.fetchCommunityRecipes();
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Hiển thị lưới 2 cột
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75, // Tỷ lệ khung hình của thẻ món ăn
              ),
              itemCount: controller.communityRecipes.length,
              itemBuilder: (context, index) {
                final recipe = controller.communityRecipes[index];
                return GestureDetector(
                  onTap: () {
                    // 1. Kích hoạt lưu lịch sử món vừa xem
                    controller.addToRecent(recipe);
                    
                    // CHÚ Ý: Tôi đã xóa dòng controller.fetchRecipeDetail(recipe.id); 
                    // Vì đây là dữ liệu Firebase, nó đã có sẵn nguyên liệu và cách làm. 
                    // Gọi API ở đây là dư thừa và có thể gây lỗi.

                    // 2. Chuyển hướng sang màn hình Chi tiết và truyền món ăn sang
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailScreen(recipe: recipe), 
                      ),
                    );
                  },
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hình ảnh món ăn
                        Expanded(
                          child: recipe.imageUrl.isNotEmpty
                              ? Image.network(
                                  recipe.imageUrl,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    color: Colors.orange.shade50,
                                    child: const Icon(Icons.fastfood, color: Colors.orange),
                                  ),
                                )
                              : Container(
                                  color: Colors.orange.shade50,
                                  child: const Icon(Icons.fastfood, color: Colors.orange),
                                ),
                        ),
                        // Nội dung chữ
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column( 
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recipe.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Nhãn định danh tác giả cộng đồng công khai
                              Row(
                                children: [
                                  const Icon(Icons.account_circle, size: 14, color: Colors.orange),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      recipe.authorName ?? 'Đầu bếp bí ẩn',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ), 
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}