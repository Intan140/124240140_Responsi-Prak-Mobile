import 'package:flutter/material.dart';
import 'services/db_service.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

class AppColors {
  static const brown = Color(0xFF4E342E);
  static const brownLight = Color(0xFF795548);
  static const cream = Color(0xFFF5ECD7);
  static const white = Colors.white;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DB.init();
  runApp(const ShoppingHubApp());
}

class ShoppingHubApp extends StatelessWidget {
  const ShoppingHubApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShoppingHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.brown,
          primary: AppColors.brown,
          surface: AppColors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.brown,
          foregroundColor: AppColors.white,
          centerTitle: false,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brown,
            foregroundColor: AppColors.white,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: DB.currentUser == null
          ? const LoginScreen()
          : HomeScreen(username: DB.currentUser!),
    );
  }
}