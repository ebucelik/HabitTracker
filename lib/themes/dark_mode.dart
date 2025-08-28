import 'package:flutter/material.dart';
import 'package:habit_tracker/shared/AppColors.dart';

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    surface: AppColors.background.color(),
    primary: AppColors.primary.color(),
    secondary: AppColors.unselectedItem.color(),
    inversePrimary: AppColors.background.color(),
  ),
  splashFactory: NoSplash.splashFactory,
  highlightColor: Colors.transparent,
  splashColor: Colors.transparent,
);
