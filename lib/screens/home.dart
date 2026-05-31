import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../widgets/menu_app.dart';
import '../controllers/recipe_controller.dart';
import '../models/recipe_model.dart';
import 'search_results_screen.dart';
import 'recipe_detail_screen.dart';
import 'add_recipe_screen.dart';
import 'my_cookbook_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final photoUrl = user?.photoURL;

    final recentRecipes =
        context.watch<RecipeController>().recentRecipes;

    final pinnedRecipes =
        context.watch<RecipeController>().pinnedRecipes;

    return Scaffold(
      resizeToAvoidBottomInset: false,

      drawer: const SideMenu(),

      // ================= APP BAR =================
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          centerTitle: true,

          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),

          leading: Builder(
            builder: (BuildContext context) {
              return Padding(
                padding: const EdgeInsets.all(10),
                child: GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.orange.shade100,
                    backgroundImage:
                        photoUrl != null
                            ? NetworkImage(photoUrl)
                            : null,
                    child:
                        photoUrl == null
                            ? const Icon(
                              Icons.person,
                              color: Colors.orange,
                            )
                            : null,
                  ),
                ),
              );
            },
          ),

          title: const CircleAvatar(
            radius: 27,
            backgroundColor: Colors.white,
            backgroundImage: AssetImage(
              'assets/logo_app.png',
            ),
          ),

          // actions: [
          //   IconButton(
          //     onPressed: () {},
          //     icon: const Icon(
          //       Icons.notifications,
          //       color: Colors.black,
          //       size: 28,
          //     ),
          //   ),
          // ],
        ),
      ),

      // ================= BODY =================
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,

            children: [
              // ===== SEARCH BAR =====
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius:
                      BorderRadius.circular(10),
                ),

                child: TextField(
                  controller: _searchController,

                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      context
                          .read<RecipeController>()
                          .searchRecipes(value);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  SearchResultsScreen(
                                    query: value,
                                  ),
                        ),
                      ).then((_) {
                        _searchController.clear();
                      });
                    }
                  },

                  decoration:
                      const InputDecoration(
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.black,
                        ),

                        hintText:
                            'Nhập nguyên liệu (VD: trứng, cà chua)...',

                        hintStyle: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),

                        border: InputBorder.none,

                        contentPadding:
                            EdgeInsets.symmetric(
                              vertical: 15,
                            ),
                      ),
                ),
              ),

              const SizedBox(height: 20),

              // ===== POPULAR RECIPES =====
              _buildSection(
                title: 'Các món phổ biến',
                isTitleItalic: false,

                children:
                    pinnedRecipes.isEmpty
                        ? [
                          const Padding(
                            padding:
                                EdgeInsets.all(16),
                            child: Text(
                              'Bạn chưa ghim món ăn nào.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontStyle:
                                    FontStyle.italic,
                              ),
                            ),
                          ),
                        ]
                        : pinnedRecipes
                            .map(
                              (recipe) =>
                                  _buildFoodCard(
                                    recipe,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  RecipeDetailScreen(
                                                    recipe:
                                                        recipe,
                                                  ),
                                        ),
                                      );
                                    },
                                  ),
                            )
                            .toList(),
              ),

              const SizedBox(height: 20),

              // ===== RECENT RECIPES =====
              _buildSection(
                title: 'Món vừa xem',
                isTitleItalic: true,

                children:
                    recentRecipes.isEmpty
                        ? [
                          const Padding(
                            padding:
                                EdgeInsets.all(16),
                            child: Text(
                              'Chưa có món ăn nào.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontStyle:
                                    FontStyle.italic,
                              ),
                            ),
                          ),
                        ]
                        : recentRecipes
                            .map(
                              (recipe) =>
                                  _buildFoodCard(
                                    recipe,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  RecipeDetailScreen(
                                                    recipe:
                                                        recipe,
                                                  ),
                                        ),
                                      );
                                    },
                                  ),
                            )
                            .toList(),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),

      // ================= FLOATING BUTTON =================
      floatingActionButton:
          FloatingActionButton(
            backgroundColor: Colors.black,
            shape: const CircleBorder(),

            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          const AddRecipeScreen(),
                ),
              );
            },

            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 32,
            ),
          ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,

      // ================= BOTTOM BAR =================
      bottomNavigationBar: BottomAppBar(
        color: AppColors.primary,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,

        child: SizedBox(
          height: 75,

          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceAround,

            children: [
              _buildBottomNavItem(
                Icons.search,
                'Tìm kiếm',
                onTap: () {},
              ),

              const SizedBox(width: 48),

              _buildBottomNavItem(
                Icons.menu_book,
                'Cẩm nang của tôi',

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              const MyCookbookScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= SECTION =================
  Widget _buildSection({
    required String title,
    required bool isTitleItalic,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: AppColors.sectionBackground,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Text(
                title,

                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,

                  fontStyle:
                      isTitleItalic
                          ? FontStyle.italic
                          : FontStyle.normal,
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.arrow_forward,
                size: 24,
              ),
            ],
          ),

          const SizedBox(height: 16),

          ...children,
        ],
      ),
    );
  }

  // ================= FOOD CARD =================
  Widget _buildFoodCard(
    Recipe recipe, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        height: 110,
        width: double.infinity,

        margin: const EdgeInsets.only(
          bottom: 12,
        ),

        decoration: BoxDecoration(
          color: AppColors.cardOrange,

          borderRadius:
              BorderRadius.circular(15),

          image:
              recipe.imageUrl.isNotEmpty
                  ? DecorationImage(
                    image: NetworkImage(
                      recipe.imageUrl,
                    ),

                    fit: BoxFit.cover,

                    colorFilter:
                        ColorFilter.mode(
                          Colors.black.withOpacity(
                            0.4,
                          ),
                          BlendMode.darken,
                        ),
                  )
                  : null,
        ),

        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(
                  horizontal: 16,
                ),

            child: Text(
              recipe.title,

              textAlign: TextAlign.center,

              maxLines: 2,

              overflow:
                  TextOverflow.ellipsis,

              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= BOTTOM NAV ITEM =================
  Widget _buildBottomNavItem(
    IconData icon,
    String label, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,

      borderRadius:
          BorderRadius.circular(10),

      child: Padding(
        padding:
            const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              icon,
              size: 26,
              color: Colors.black,
            ),

            const SizedBox(height: 2),

            Text(
              label,

              style: const TextStyle(
                fontSize: 11,
                fontWeight:
                    FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}