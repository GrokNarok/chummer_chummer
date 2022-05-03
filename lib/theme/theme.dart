import 'package:chummer_chummer/theme/fonts.dart';
import 'package:flutter/material.dart';

import 'package:chummer_chummer/theme/colors.dart';

enum AppThemes {
  classic,
  //dark,
  //light,
}

const Map<AppThemes, ColorScheme> colorSchemeMap = {
  AppThemes.classic: AppColorSchemes.classicColorScheme,
};

const Map<AppThemes, ColorSchemeExtension> colorSchemeExtensionMap = {
  AppThemes.classic: AppColorSchemes.classicColorSchemeExtension,
};

const Map<AppThemes, TextTheme> typographyMap = {
  AppThemes.classic: AppTypography.classicTypography,
};

class AppTheme {
  static ThemeData themeData(AppThemes theme) => ThemeData.from(colorScheme: colorSchemeMap[theme]!, textTheme: typographyMap[theme]!);

  static ColorSchemeExtension colorSchemeExtension(AppThemes theme) => colorSchemeExtensionMap[theme]!;
}

class ThemeExtension extends InheritedWidget {
  final ColorSchemeExtension colorScheme;

  const ThemeExtension({
    Key? key,
    required this.colorScheme,
    required Widget child,
  }) : super(key: key, child: child);

  static ThemeExtension of(BuildContext context) {
    final ThemeExtension? result = context.dependOnInheritedWidgetOfExactType<ThemeExtension>();
    assert(result != null, 'No ThemeExtension found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(ThemeExtension oldWidget) => colorScheme != oldWidget.colorScheme;
}
