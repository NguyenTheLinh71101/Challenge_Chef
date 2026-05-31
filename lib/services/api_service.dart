import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart'; 
import '../models/recipe_model.dart';

class ApiService {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';
  
  // API Key Pixabay của bạn
  static const String pixabayApiKey = '56016132-0f28013221b8a0adcc8d9d02f'; 
  
  final GoogleTranslator _translator = GoogleTranslator();

  // Hàm tìm kiếm món ăn theo nguyên liệu (CŨ)
  Future<List<Recipe>> searchByIngredient(String ingredient) async {
    try {
      final url = Uri.parse('$baseUrl/filter.php?i=$ingredient');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null) {
          final List meals = data['meals'];
          return meals.map((meal) => Recipe.fromJson(meal)).toList();
        }
        return [];
      } else {
        throw Exception('Lỗi khi kết nối đến server TheMealDB');
      }
    } catch (e) {
      throw Exception('Đã xảy ra lỗi: $e');
    }
  }

  // Hàm LẤY CHI TIẾT món ăn theo ID (CŨ)
  Future<Recipe?> getRecipeById(String id) async {
    try {
      final url = Uri.parse('$baseUrl/lookup.php?i=$id');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null && (data['meals'] as List).isNotEmpty) {
          return Recipe.fromJson(data['meals'][0]);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi tải chi tiết món ăn: $e');
    }
  }

  // THÊM MỚI: Hàm tự động tìm URL ảnh trên Pixabay dựa vào tên món ăn
  Future<String> getAutoImageUrl(String recipeName) async {
    try {
      // 1. Dịch tên món ăn từ Tiếng Việt sang Tiếng Anh
      var translation = await _translator.translate(recipeName, from: 'vi', to: 'en');
      
      // TỐI ƯU HÓA: Xóa các dấu câu do Google Translate tự sinh ra để tìm ảnh chính xác hơn
      String englishName = translation.text.replaceAll(RegExp(r'[.!?]'), '').trim();

      // 2. Gọi API Pixabay tìm ảnh (Lọc theo danh mục đồ ăn - food)
      final url = Uri.parse('https://pixabay.com/api/?key=$pixabayApiKey&q=${Uri.encodeComponent(englishName)}&image_type=photo&category=food&per_page=3');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['hits'] != null && (data['hits'] as List).isNotEmpty) {
          // Trả về đường link của bức ảnh đẹp nhất (ảnh đầu tiên)
          return data['hits'][0]['webformatURL'];
        }
      }
      // Nếu không tìm thấy ảnh nào, trả về ảnh mặc định
      return 'https://via.placeholder.com/300?text=No+Image';
    } catch (e) {
      print('Lỗi tìm ảnh tự động: $e');
      return 'https://via.placeholder.com/300?text=No+Image';
    }
  }
}