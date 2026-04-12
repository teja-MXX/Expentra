import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const yellow = Color(0xFFFFE600);
  static const red = Color(0xFFE8230A);
  static const blue = Color(0xFF1B3FFF);
  static const pink = Color(0xFFFF3CAC);
  static const green = Color(0xFF00C46A);
  static const black = Color(0xFF0D0D0D);
  static const cream = Color(0xFFF5F0E8);
  static const paper = Color(0xFFEDE8DC);
  static const darkCard = Color(0xFF1A1A1A);
  static const mutedText = Color(0xFF777777);
  static const lightBorder = Color(0xFFCCCCCC);
}

class AppTextStyles {
  static TextStyle bebas(double size, {Color color = AppColors.black, double letterSpacing = 1.0}) {
    return TextStyle(
      fontFamily: 'BebasNeue',
      fontSize: size,
      color: color,
      letterSpacing: letterSpacing,
      height: 1.0,
    );
  }

  static TextStyle mono(double size, {Color color = AppColors.black, FontWeight weight = FontWeight.normal, double letterSpacing = 0.5}) {
    return TextStyle(
      fontFamily: 'SpaceMono',
      fontSize: size,
      color: color,
      fontWeight: weight,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle monoMicro({Color color = AppColors.mutedText}) => mono(9, color: color, letterSpacing: 1.5);
  static TextStyle monoSmall({Color color = AppColors.black}) => mono(11, color: color);
  static TextStyle monoBody({Color color = AppColors.black}) => mono(13, color: color);
  static TextStyle monoBold(double size, {Color color = AppColors.black}) => mono(size, color: color, weight: FontWeight.bold);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.black,
        secondary: AppColors.yellow,
        surface: AppColors.paper,
        background: AppColors.cream,
        error: AppColors.red,
      ),
      scaffoldBackgroundColor: AppColors.paper,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.paper,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'BebasNeue',
          fontSize: 32,
          color: AppColors.black,
          letterSpacing: 2,
        ),
        iconTheme: IconThemeData(color: AppColors.black),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.black,
        selectedItemColor: AppColors.yellow,
        unselectedItemColor: Color(0xFF666666),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      fontFamily: 'SpaceMono',
    );
  }
}

// Reusable brutalist card decoration
BoxDecoration brutalCard({
  Color bg = Colors.white,
  Color borderColor = AppColors.black,
  double borderWidth = 3,
  Offset shadow = const Offset(4, 4),
  Color shadowColor = AppColors.black,
}) {
  return BoxDecoration(
    color: bg,
    border: Border.all(color: borderColor, width: borderWidth),
    boxShadow: [
      BoxShadow(
        color: shadowColor,
        offset: shadow,
        blurRadius: 0,
      ),
    ],
  );
}

BoxDecoration brutalCardSmall({Color bg = Colors.white, Color borderColor = AppColors.black}) {
  return brutalCard(bg: bg, borderColor: borderColor, borderWidth: 2, shadow: const Offset(3, 3));
}
