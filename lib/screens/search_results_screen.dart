import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/recipe_controller.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart'; // THÊM DÒNG NÀY ĐỂ KẾT NỐI

class SearchResultsScreen extends StatelessWidget {
  final String query;

  const SearchResultsScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kết quả cho: $query'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Consumer<RecipeController>(
        builder: (context, controller, child) {
          
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          }

          if (controller.errorMessage.isNotEmpty) {
            return Center(
              child: Text(controller.errorMessage, style: const TextStyle(color: Colors.red, fontSize: 16)),
            );
          }

          if (controller.recipes.isEmpty) {
            return const Center(
              child: Text('Không tìm thấy món ăn nào phù hợp.', style: TextStyle(fontSize: 16)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.recipes.length,
            itemBuilder: (context, index) {
              final recipe = controller.recipes[index];
              return RecipeCard(
                recipe: recipe,
                onTap: () {
                  // CẬP NHẬT ĐOẠN ĐIỀU HƯỚNG NÀY
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeDetailScreen(recipe: recipe),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}