import 'package:flutter/material.dart';

class ApiConstants {
  static const String baseUrl = 'https://houserental-backend-9k4k.onrender.com/api'; 
}

class AppColors {
  static const Color primary = Color(0xFF673AB7); // Deep Purple
  static const Color primaryLight = Color(0xFFD1C4E9);
  static const Color accent = Color(0xFFFF4081);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textLight = Color(0xFF757575);
  static const Color background = Color(0xFFF8F9FE);
  static const Color white = Colors.white;
  static const Color glassWhite = Color(0xCCFFFFFF);
}

class AppGradients {
  static const LinearGradient main = LinearGradient(
    colors: [Color(0xFF673AB7), Color(0xFF512DA8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient card = LinearGradient(
    colors: [Colors.white, Color(0xFFF3E5F5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppShadows {
  static BoxShadow soft = BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 15,
    offset: const Offset(0, 5),
  );

  static BoxShadow deep = BoxShadow(
    color: const Color(0xFF673AB7).withOpacity(0.2),
    blurRadius: 20,
    offset: const Offset(0, 8),
  );
}
