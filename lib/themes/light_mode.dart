import 'package:flutter/material.dart';
import 'package:habit_tracker/shared/AppColors.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: AppColors.surfaceLight.color(),
    primary: AppColors.primaryDark.color(),
    secondary: AppColors.secondary.color(),
    inversePrimary: AppColors.primary.color(),
  ),
  splashFactory: NoSplash.splashFactory,
  highlightColor: Colors.transparent,
  splashColor: Colors.transparent,
);
