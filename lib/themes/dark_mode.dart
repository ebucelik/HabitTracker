import 'package:flutter/material.dart';
import 'package:habit_tracker/shared/AppColors.dart';

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    surface: AppColors.surfaceDark.color(),
    primary: AppColors.primary.color(),
    secondary: AppColors.secondary.color(),
    inversePrimary: AppColors.primaryDark.color(),
  ),
  splashFactory: NoSplash.splashFactory,
  highlightColor: Colors.transparent,
  splashColor: Colors.transparent,
);
