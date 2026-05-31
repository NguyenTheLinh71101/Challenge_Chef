import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/recipe_controller.dart';
import '../models/recipe_model.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool isFirebaseRecipe = false;

  @override
  void initState() {
    super.initState();
    
    // THÊM MỚI: Kiểm tra xem món ăn này có ID người tạo không (từ Firebase)
    isFirebaseRecipe = widget.recipe.userId != null;

    // Tự động gọi hàm khi vừa mở màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeController>().addToRecent(widget.recipe);
      
      // THÊM MỚI: CHỈ gọi API lấy chi tiết nếu đây LÀ MÓN TỪ API (TheMealDB)
      if (!isFirebaseRecipe) {
        context.read<RecipeController>().fetchRecipeDetail(widget.recipe.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<RecipeController>(
        builder: (context, controller, child) {
          // THÊM MỚI: Logic gán dữ liệu thông minh
          // - Nếu là món Firebase: Dùng luôn dữ liệu truyền vào (widget.recipe)
          // - Nếu là món API: Dùng dữ liệu đang tải từ API về (controller.recipeDetail)
          final detail = isFirebaseRecipe ? widget.recipe : controller.recipeDetail;
          
          // - Nếu là món Firebase: Không cần load (false)
          // - Nếu là món API: Chờ trạng thái load của controller
          final isLoading = isFirebaseRecipe ? false : controller.isDetailLoading;

          return CustomScrollView(
            slivers: [
              // Ảnh bìa Parallax phía trên
              SliverAppBar(
                expandedHeight: 300.0,
                pinned: true,
                backgroundColor: Colors.orange,
                actions: [
                  IconButton(
                    icon: Icon(
                      controller.isPinned(widget.recipe.id) 
                          ? Icons.push_pin // Đậm màu khi đã ghim
                          : Icons.push_pin_outlined, // Viền mờ khi chưa ghim
                      color: Colors.white,
                    ),
                    onPressed: () {
                      controller.togglePin(widget.recipe);
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    widget.recipe.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                    ),
                  ),
                  background: Image.network(
                    widget.recipe.imageUrl,
                    fit: BoxFit.cover,
                    // Thêm errorBuilder để tránh vỡ UI nếu link ảnh bị lỗi
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.orange.shade100,
                      child: const Icon(Icons.broken_image, size: 50, color: Colors.orange),
                    ),
                  ),
                ),
              ),
              
              // Nội dung bên dưới
              SliverToBoxAdapter(
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(50.0),
                        child: Center(child: CircularProgressIndicator(color: Colors.orange)),
                      )
                    : (detail == null
                        ? const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(child: Text("Không thể tải thông tin món ăn.")),
                          )
                        : _buildRecipeContent(detail)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRecipeContent(Recipe recipe) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Nguyên liệu chuẩn bị",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange),
          ),
          const SizedBox(height: 10),
          // Nếu không có detailIngredients, hiển thị thông báo nhẹ nhàng
          if (recipe.detailIngredients.isEmpty)
            const Text("Chưa có thông tin nguyên liệu cụ thể.", style: TextStyle(fontStyle: FontStyle.italic)),
          ...recipe.detailIngredients.map((ingredient) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text(ingredient, style: const TextStyle(fontSize: 16))),
                  ],
                ),
              )),
          const Divider(height: 40, thickness: 1),
          const Text(
            "Hướng dẫn thực hiện",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange),
          ),
          const SizedBox(height: 15),
          Text(
            recipe.instructions,
            style: const TextStyle(fontSize: 16, height: 1.6),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}