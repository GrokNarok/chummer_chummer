import 'package:flutter/material.dart';

import 'package:chummer_chummer/theme/colors.dart';

class AppTypography {
  // SR5 rulebooks actually use Univers Condensed font but it's proprietary, Roboto Condensed is pretty similar.
  static const classicTypography = TextTheme(
    headline1: TextStyle(fontFamily: 'RobotoCondensed', inherit: true, color: AppColors.white),
    headline2: TextStyle(fontFamily: 'RobotoCondensed', inherit: true, color: AppColors.white),
    headline3: TextStyle(fontFamily: 'RobotoCondensed', inherit: true, color: AppColors.white),
    headline4: TextStyle(fontFamily: 'RobotoCondensed', inherit: true, color: AppColors.white),
    headline5: TextStyle(fontFamily: 'RobotoCondensed', inherit: true, color: AppColors.white),
    headline6: TextStyle(fontFamily: 'RobotoCondensed', inherit: true, color: AppColors.white),
    bodyText1: TextStyle(fontFamily: 'RobotoCondensed', inherit: true, color: AppColors.white, fontSize: 13.45),
    bodyText2: TextStyle(fontFamily: 'RobotoCondensed', inherit: true, color: AppColors.white, fontSize: 12.25, height: 1.4),
    subtitle1: TextStyle(fontFamily: 'RobotoCondensed', inherit: true, color: AppColors.white),
    subtitle2: TextStyle(fontFamily: 'RobotoCondensed', inherit: true, color: AppColors.white),
    caption: TextStyle(fontFamily: 'RobotoCondensed', inherit: true, color: AppColors.white),
    button: TextStyle(fontFamily: 'RobotoCondensed', inherit: true, color: AppColors.white),
    overline: TextStyle(fontFamily: 'RobotoCondensed', inherit: true, color: AppColors.white),
  );
}
