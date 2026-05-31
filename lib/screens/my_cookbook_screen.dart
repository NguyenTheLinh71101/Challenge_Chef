import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/recipe_controller.dart';
import 'add_recipe_screen.dart'; // Import để chuyển sang màn hình sửa
import 'recipe_detail_screen.dart'; // THÊM MỚI: Import màn hình chi tiết

class MyCookbookScreen extends StatefulWidget {
  const MyCookbookScreen({super.key});

  @override
  State<MyCookbookScreen> createState() => _MyCookbookScreenState();
}

class _MyCookbookScreenState extends State<MyCookbookScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RecipeController>(context, listen: false).fetchMyCookbook();
    });
  }

  void _showDeleteDialog(BuildContext context, String recipeId, RecipeController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa công thức này khỏi cẩm nang?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              controller.deleteMyRecipe(recipeId); // Gọi hàm xóa
              Navigator.of(ctx).pop(); // Đóng hộp thoại
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa công thức thành công!')),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cẩm nang của tôi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<RecipeController>(
        builder: (context, controller, child) {
          if (controller.isMyRecipesLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          }

          if (controller.myRecipes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    'Cẩm nang của bạn đang trống.\nHãy thêm công thức mới nhé!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.myRecipes.length,
            itemBuilder: (context, index) {
              final recipe = controller.myRecipes[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: recipe.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            recipe.imageUrl, 
                            width: 60, height: 60, fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Container(
                              width: 60, height: 60, color: Colors.orange.shade100,
                              child: const Icon(Icons.fastfood, color: Colors.orange),
                            ),
                          ),
                        )
                      : Container(
                          width: 60, height: 60, color: Colors.orange.shade100,
                          child: const Icon(Icons.fastfood, color: Colors.orange),
                        ),
                  title: Text(recipe.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Món ăn của bạn', style: TextStyle(color: Colors.orange, fontSize: 12)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddRecipeScreen(existingRecipe: recipe),
                            ),
                          ).then((value) {
                            if (value == true) {
                              controller.fetchMyCookbook();
                            }
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteDialog(context, recipe.id, controller),
                      ),
                    ],
                  ),
                  // THÊM MỚI: Mở màn hình Chi tiết khi bấm vào thẻ
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailScreen(recipe: recipe),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}