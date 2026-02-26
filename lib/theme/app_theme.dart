import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors — exactly matching web CSS vars
  static const blue = Color(0xFF93C5FD); // rgb(147, 197, 253) bg-blue-300
  static const blueDark = Color(0xFF60A5FA); // rgb(96, 165, 250) bg-blue-400
  static const blueLight = Color(0xFFBFDBFE); // rgb(191, 219, 254) bg-blue-200

  // Pastel accent colors — matching web .btn-* classes
  static const pink = Color(0xFFFBCFE8); // rgb(251, 207, 232) bg-pink-300
  static const pinkLight = Color(0xFFFCE7F3); // bg-pink-100
  static const yellow = Color(0xFFFDE047); // rgb(253, 224, 71) bg-yellow-300
  static const yellowLight = Color(0xFFFEF9C3); // bg-yellow-100
  static const emerald = Color(0xFF86EFAC); // rgb(134, 239, 172) bg-green-300
  static const emeraldLight = Color(0xFFD1FAE5); // bg-green-100
  static const orange = Color(0xFFFDBA74); // rgb(253, 186, 116) bg-orange-300
  static const orangeLight = Color(0xFFFED7AA); // bg-orange-200
  static const purple = Color(0xFFD8B4FE); // rgb(216, 180, 254) bg-purple-300
  static const purpleLight = Color(0xFFF3E8FF); // bg-purple-100
  static const red = Color(0xFFFCA5A5); // rgb(252, 165, 165) bg-red-300
  static const gray = Color(0xFFD4D4D8); // rgb(212, 212, 216) bg-zinc-300

  // Background — matching web CSS vars
  static const background = Color(0xFFFFFFFF);
  static const backgroundSky = Color(0xFFE0F2FE); // rgb(224, 242, 254) sky-100
  static const backgroundBlue = Color(0xFFDBEAFE); // rgb(219, 234, 254) blue-100
  static const backgroundPinkLight = Color(0xFFFEF8FC);
  static const backgroundSkyLight = Color(0xFFF0F9FF); // sky-50 for gradients

  // Text — matching web CSS vars
  static const textPrimary = Color(0xFF000000);
  static const textSecondary = Color(0xFF52525B); // rgb(82, 82, 91) zinc-600
  static const textTertiary = Color(0xFF71717A); // rgb(113, 113, 122) zinc-500

  // Border
  static const border = Color(0xFF000000);
}

class AppShadows {
  // Mobile-optimised — matches web @media (max-width: 768px)
  // --shadow-primary: 4px 5px 0px -1px #000000
  static const primary = [
    BoxShadow(
      color: Colors.black,
      offset: Offset(4, 5),
      blurRadius: 0,
      spreadRadius: -1,
    ),
  ];

  // --shadow-secondary: 2px 2px 0px -1px #000000
  static const secondary = [
    BoxShadow(
      color: Colors.black,
      offset: Offset(2, 2),
      blurRadius: 0,
      spreadRadius: -1,
    ),
  ];

  static const secondaryOpposite = [
    BoxShadow(
      color: Colors.black,
      offset: Offset(-2, 2),
      blurRadius: 0,
      spreadRadius: -1,
    ),
  ];

  // Pressed state — sink effect
  static const pressed = [
    BoxShadow(
      color: Colors.black,
      offset: Offset(0, 0),
      blurRadius: 0,
      spreadRadius: -1,
    ),
  ];
}

class AppRadius {
  static const sm = 6.0;
  static const md = 8.0;
  static const lg = 10.0;
  static const xl = 14.0;
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Google Sans',
      colorScheme: ColorScheme.light(
        primary: AppColors.blueDark,
        secondary: AppColors.pink,
        surface: AppColors.background,
        onPrimary: AppColors.textPrimary,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textSecondary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Google Sans',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 1.1,
        ),
        headlineLarge: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 1.2,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 1.3,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          height: 1.6,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textTertiary,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
