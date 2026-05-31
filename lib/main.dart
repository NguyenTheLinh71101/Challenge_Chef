import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'core/constants.dart';
import 'screens/home.dart'; 
import 'screens/login_screen.dart'; 
import 'firebase_options.dart'; 

// Thêm import cho các controllers quản lý trạng thái
import 'controllers/auth_controller.dart';
import 'controllers/recipe_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        // Thay thế Provider tạm thời bằng các Controller thực tế
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => RecipeController()), 
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const AuthWrapper(), // Quản lý luồng bằng AuthWrapper
      routes: {
        AppRoutes.home: (context) => HomeScreen(),
      },
    );
  }
}

// Lắng nghe và điều hướng luồng tự động
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.hasData) {
          return HomeScreen(); 
        }
        
        return const LoginScreen(); 
      },
    );
  }
}