import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/firestore_service.dart';
import '../services/api_service.dart'; // Import API Service mới
import '../core/constants.dart';

class AddRecipeScreen extends StatefulWidget {
  final Recipe? existingRecipe; 

  const AddRecipeScreen({super.key, this.existingRecipe});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingRecipe != null) {
      _titleController.text = widget.existingRecipe!.title;
      _ingredientsController.text = widget.existingRecipe!.detailIngredients.join(', ');
      _instructionsController.text = widget.existingRecipe!.instructions;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      try {
        List<String> ingredientsList = _ingredientsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        bool isEditing = widget.existingRecipe != null;
        
        String recipeId = isEditing ? widget.existingRecipe!.id : DateTime.now().millisecondsSinceEpoch.toString();
        
        // Mặc định lấy lại link ảnh cũ nếu đang sửa
        String finalImageUrl = isEditing ? widget.existingRecipe!.imageUrl : 'https://via.placeholder.com/300?text=No+Image';

        // TỰ ĐỘNG TÌM ẢNH: Nếu là thêm mới món ăn
        if (!isEditing) {
          // Tùy chọn: Báo cho người dùng biết hệ thống đang xử lý tìm ảnh
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hệ thống đang tự động tìm ảnh phù hợp...'), duration: Duration(seconds: 2)),
          );
          
          finalImageUrl = await ApiService().getAutoImageUrl(_titleController.text.trim());
        }

        final newRecipe = Recipe(
          id: recipeId,
          title: _titleController.text.trim(),
          instructions: _instructionsController.text.trim(),
          imageUrl: finalImageUrl, // Gán URL ảnh tự động tìm được
          missingIngredients: [],
          detailIngredients: ingredientsList,
        );

        if (isEditing) {
          await FirestoreService().updateRecipe(newRecipe);
        } else {
          await FirestoreService().addRecipe(newRecipe);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isEditing ? 'Cập nhật thành công!' : 'Thêm công thức thành công!')),
          );
          Navigator.pop(context, true); 
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Có lỗi xảy ra: $e')));
        }
      } finally {
        if (mounted) setState(() => _isSaving = false); 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.existingRecipe != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Sửa Công Thức' : 'Thêm Công Thức Mới', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextField(
                      controller: _titleController,
                      label: 'Tên món ăn',
                      hint: 'Ví dụ: Trứng chiên thịt băm',
                      icon: Icons.fastfood,
                      validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập tên món ăn' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _ingredientsController,
                      label: 'Nguyên liệu (cách nhau bằng dấu phẩy)',
                      hint: 'Ví dụ: 2 quả trứng, 100g thịt băm, hành lá',
                      icon: Icons.list_alt,
                      maxLines: 3,
                      validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập nguyên liệu' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _instructionsController,
                      label: 'Cách thực hiện',
                      hint: 'Bước 1: Đánh trứng...\nBước 2: Xào thịt...',
                      icon: Icons.menu_book,
                      maxLines: 5,
                      validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập cách thực hiện' : null,
                    ),
                    const SizedBox(height: 32), // Đã xóa hẳn phần chọn ảnh ở đây

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _saveRecipe,
                      child: Text(isEditing ? 'LƯU THAY ĐỔI' : 'HOÀN TẤT', style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}