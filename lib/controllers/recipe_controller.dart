import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import '../models/recipe_model.dart';
import '../services/api_service.dart';
import '../services/firestore_service.dart';


class RecipeController with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final GoogleTranslator _translator = GoogleTranslator(); 
  
  List<Recipe> _recipes = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Trạng thái cho màn hình Chi tiết
  Recipe? _recipeDetail;
  bool _isDetailLoading = false;

  final List<Recipe> _recentRecipes = [];
  List<Recipe> get recentRecipes => _recentRecipes;

  final List<Recipe> _pinnedRecipes = [];
  List<Recipe> get pinnedRecipes => _pinnedRecipes;

  // Kiểm tra xem món ăn đã được ghim chưa
  bool isPinned(String id) {
    return _pinnedRecipes.any((r) => r.id == id);
  }

  // Xử lý Ghim / Bỏ ghim món ăn
  void togglePin(Recipe recipe) {
    if (isPinned(recipe.id)) {
      _pinnedRecipes.removeWhere((r) => r.id == recipe.id);
    } else {
      _pinnedRecipes.insert(0, recipe);
    }
    notifyListeners();
  }
  
  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  Recipe? get recipeDetail => _recipeDetail;
  bool get isDetailLoading => _isDetailLoading;

  void addToRecent(Recipe recipe) {
    _recentRecipes.removeWhere((r) => r.id == recipe.id);
    _recentRecipes.insert(0, recipe);
    if (_recentRecipes.length > 10) {
      _recentRecipes.removeLast();
    }
    notifyListeners();
  }

  Future<void> searchRecipes(String query) async {
    if (query.trim().isEmpty) return;

    _isLoading = true;
    _errorMessage = '';
    _recipes = [];
    notifyListeners(); 

    try {
      var inputTranslation = await _translator.translate(query.trim(), from: 'vi', to: 'en');
      String englishQuery = inputTranslation.text;

      // ĐÃ SỬA LỖI Ở ĐÂY: Làm sạch dữ liệu trước khi gọi API
      List<String> ingredients = englishQuery.split(',')
          .map((e) {
             // 1. Xóa các dấu chấm, chấm hỏi, chấm than do Google Translate tự thêm
             String cleanString = e.replaceAll(RegExp(r'[.!?]'), '').trim().toLowerCase();
             
             // 2. Thay thế khoảng trắng bằng dấu gạch dưới cho API TheMealDB (VD: chicken breast -> chicken_breast)
             return cleanString.replaceAll(' ', '_');
          }) 
          .where((e) => e.isNotEmpty)
          .toList();

      List<Recipe> combinedRecipes = [];
      Set<String> existingIds = {}; 

      await Future.wait(ingredients.map((ingredient) async {
        final fetched = await _apiService.searchByIngredient(ingredient);
        for (var recipe in fetched) {
          if (!existingIds.contains(recipe.id)) {
            existingIds.add(recipe.id);
            combinedRecipes.add(recipe);
          }
        }
      }));

      if (combinedRecipes.isEmpty) {
        _errorMessage = 'Không tìm thấy món ăn nào với (các) nguyên liệu này.';
      } else {
        _recipes = await Future.wait(
          combinedRecipes.map((recipe) async {
            var titleTranslation = await _translator.translate(recipe.title, from: 'en', to: 'vi');
            return Recipe(
              id: recipe.id,
              title: titleTranslation.text, 
              instructions: recipe.instructions, 
              imageUrl: recipe.imageUrl,
              missingIngredients: recipe.missingIngredients,
            );
          }),
        );
      }
    } catch (e) {
      _errorMessage = 'Lỗi tìm kiếm: Vui lòng kiểm tra kết nối mạng hoặc thử lại.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Hàm lấy và dịch CHI TIẾT MÓN ĂN
  Future<void> fetchRecipeDetail(String id) async {
    _isDetailLoading = true;
    _recipeDetail = null;
    notifyListeners();

    try {
      Recipe? rawRecipe = await _apiService.getRecipeById(id);
      
      if (rawRecipe != null) {
        var titleTrans = await _translator.translate(rawRecipe.title, from: 'en', to: 'vi');
        
        String translatedInstructions = "Chưa có hướng dẫn cụ thể.";
        if (rawRecipe.instructions.isNotEmpty) {
          var instTrans = await _translator.translate(rawRecipe.instructions, from: 'en', to: 'vi');
          translatedInstructions = instTrans.text;
        }

        List<String> translatedIngredients = [];
        if (rawRecipe.detailIngredients.isNotEmpty) {
          final joinedIngredients = rawRecipe.detailIngredients.join(" || ");
          var ingTrans = await _translator.translate(joinedIngredients, from: 'en', to: 'vi');
          translatedIngredients = ingTrans.text.split(" || ").map((e) => e.trim()).toList();
        }

        _recipeDetail = Recipe(
          id: rawRecipe.id,
          title: titleTrans.text,
          instructions: translatedInstructions,
          imageUrl: rawRecipe.imageUrl,
          missingIngredients: rawRecipe.missingIngredients,
          detailIngredients: translatedIngredients,
        );
      }
    } catch (e) {
      print("Lỗi tải chi tiết món ăn: $e");
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

 // ================= CẨM NANG CỦA TÔI =================
  List<Recipe> _myRecipes = [];
  bool _isMyRecipesLoading = false;

  // ================= CỘNG ĐỒNG ẨM THỰC =================
  List<Recipe> _communityRecipes = [];
  bool _isCommunityLoading = false;

  List<Recipe> get communityRecipes => _communityRecipes;
  bool get isCommunityLoading => _isCommunityLoading;
  List<Recipe> get myRecipes => _myRecipes;
  bool get isMyRecipesLoading => _isMyRecipesLoading;

  Future<void> fetchMyCookbook() async {
    _isMyRecipesLoading = true;
    notifyListeners();

    try {
      _myRecipes = await FirestoreService().getMyRecipes();
    } catch (e) {
      print("Lỗi khi tải cẩm nang: $e");
    } finally {
      _isMyRecipesLoading = false;
      notifyListeners();
    }
  }

  // THÊM MỚI: Hàm xóa món ăn khỏi Cẩm nang
  Future<void> deleteMyRecipe(String recipeId) async {
    try {
      await FirestoreService().deleteRecipe(recipeId);
      // Xóa món ăn khỏi danh sách hiện tại trên RAM để giao diện cập nhật ngay lập tức
      _myRecipes.removeWhere((recipe) => recipe.id == recipeId);
      notifyListeners();
    } catch (e) {
      print("Lỗi khi xóa khỏi cẩm nang: $e");
    }
  }

  Future<void> fetchCommunityRecipes() async {
    _isCommunityLoading = true;
    notifyListeners();

    try {
      _communityRecipes = await FirestoreService().getCommunityRecipes();
    } catch (e) {
      print("Lỗi bộ điều khiển khi tải dữ liệu cộng đồng: $e");
    } finally {
      _isCommunityLoading = false;
      notifyListeners();
    }
  }
}