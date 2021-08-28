import 'dart:ui';

import 'package:flutter/material.dart';

class AppColors {
  // Black
  static const Color black = Color(0xFF000000);

  // White
  static const Color white = Color(0xFFFFFFFF);

  // Grey
  static const Color lighterGrey = Color(0xFFF5F5F5);
  static const Color lightGrey = Color(0xFFE6E6E6);
  static const Color grey = Color(0xFF59595B);
  static const Color darkGrey = Color(0xFF393939);
  static const Color darkerGrey = Color(0xFF353535);

  // Yellow
  static const Color yellow = Color(0xFFEBB531);

  // Red
  static const Color red = Color(0xFFF44336);
}

class ColorSchemeExtension {
  final Color backgroundPattern;

  const ColorSchemeExtension({
    required this.backgroundPattern,
  });
}

class AppColorSchemes {
  static const classicColorScheme = ColorScheme(
    primary: AppColors.black,
    primaryVariant: AppColors.black,
    secondary: AppColors.yellow,
    secondaryVariant: AppColors.yellow,
    surface: AppColors.grey,
    background: AppColors.darkGrey,
    error: AppColors.red,
    onPrimary: AppColors.yellow,
    onSecondary: AppColors.black,
    onSurface: AppColors.white,
    onBackground: AppColors.white,
    onError: AppColors.white,
    brightness: Brightness.dark,
  );

  static const classicColorSchemeExtension = ColorSchemeExtension(
    backgroundPattern: AppColors.darkerGrey,
  );
}
