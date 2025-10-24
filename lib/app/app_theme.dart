import 'package:flutter/material.dart';

class AppTheme {
  // الألوان الأساسية للتطبيق
  static const Color primaryGreen = Color(0xFF1B5E20); // أخضر داكن
  static const Color lightGold = Color(0xFFFFD700); // ذهبي فاتح
  static const Color white = Color(0xFFFFFFFF);
  static const Color correctGreen = Color(0xFF4CAF50); // أخضر للإجابة الصحيحة
  static const Color errorRed = Color(0xFFE53935); // أحمر للأخطاء
  static const Color backgroundColor = Color(0xFFF5F5F5);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: 'Cairo', // خط عربي جميل
      
      // إعداد الاتجاه RTL
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: primaryGreen,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: primaryGreen,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          color: Colors.black87,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        titleMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: primaryGreen,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: white,
          fontFamily: 'Cairo',
        ),
      ),

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: lightGold,
        error: errorRed,
      ),
    );
  }
}