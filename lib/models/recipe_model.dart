import 'ingredient_model.dart';

class Recipe {
  final String id;
  final String title;
  final String instructions;
  final String imageUrl;
  final List<Ingredient> missingIngredients;
  final List<String> detailIngredients;
  final String? userId;
  final String? authorName;

  Recipe({
    required this.id,
    required this.title,
    required this.instructions,
    required this.imageUrl,
    required this.missingIngredients,
    this.detailIngredients = const [],
    this.userId,
    this.authorName,
  });

  Recipe copyWith({
    String? authorName,
  }) {
    return Recipe(
      id: id,
      title: title,
      instructions: instructions,
      imageUrl: imageUrl,
      missingIngredients: missingIngredients,
      detailIngredients: detailIngredients,
      userId: userId,
      authorName: authorName ?? this.authorName,
    );
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    List<String> parsedIngredients = [];
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];
      
      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        final String measureText = (measure != null && measure.toString().trim().isNotEmpty) 
            ? '${measure.toString().trim()} ' 
            : '';
        parsedIngredients.add('$measureText${ingredient.toString().trim()}');
      }
    }

    return Recipe(
      id: json['idMeal'] ?? json['id'] ?? '',
      title: json['strMeal'] ?? json['title'] ?? '',
      instructions: json['strInstructions'] ?? json['instructions'] ?? 'Chưa có hướng dẫn',
      imageUrl: json['strMealThumb'] ?? json['imageUrl'] ?? '',
      
      // ================= ĐÃ SỬA LỖI Ở ĐÂY =================
      // Kiểm tra an toàn: Chỉ ép kiểu khi dữ liệu thực sự là kiểu List
      missingIngredients: (json['missingIngredients'] is List)
          ? (json['missingIngredients'] as List)
              .map((item) => Ingredient.fromJson(item))
              .toList()
          : [], 
      // ====================================================
      
      detailIngredients: parsedIngredients, 
      userId: json['userId'], 
    );
  }
}