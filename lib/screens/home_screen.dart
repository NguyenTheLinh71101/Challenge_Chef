import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/recipe_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    // Giải phóng bộ nhớ khi chuyển màn hình
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gợi ý món ăn'),
        backgroundColor: Colors.orange, // Đồng bộ màu sắc giống UI ảnh 3
      ),
      body: Column(
        children: [
          // Khu vực thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Nhập nguyên liệu (VD: chicken)...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onSubmitted: (value) {
                // Kích hoạt hàm tìm kiếm khi người dùng nhấn Enter trên bàn phím
                context.read<RecipeController>().searchRecipes(value);
              },
            ),
          ),
          
          // Khu vực hiển thị kết quả
          Expanded(
            child: Consumer<RecipeController>(
              builder: (context, controller, child) {
                // Trạng thái đang tải
                if (controller.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Trạng thái báo lỗi
                if (controller.errorMessage.isNotEmpty) {
                  return Center(child: Text(controller.errorMessage));
                }

                // Trạng thái chưa nhập tìm kiếm
                if (controller.recipes.isEmpty) {
                  return const Center(
                    child: Text('Hãy nhập nguyên liệu để tìm món ăn.')
                  );
                }

                // Trạng thái hiển thị danh sách món ăn
                return ListView.builder(
                  itemCount: controller.recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = controller.recipes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: recipe.imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  recipe.imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.fastfood, size: 60),
                        title: Text(
                          recipe.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          // TODO: Chuyển sang màn hình chi tiết món ăn (DetailScreen)
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Chuyển hướng sang màn hình tủ lạnh (FridgeScreen)
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.kitchen, color: Colors.white), 
      ),
    );
  }
}