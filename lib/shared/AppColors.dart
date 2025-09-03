import 'package:habit_tracker/extensions/ColorExtensions.dart';
import 'package:flutter/material.dart';

enum AppColors {
  surfaceDark("161617"),
  primary("F1F2F0"),
  primaryDark("1B1B1C"),
  secondary("6B7994"),
  surfaceLight("EDEDED");

  const AppColors(this.value);

  final String value;

  Color color() {
    return ("FF0$value").toColor();
  }
}

Color color(String value) {
  return ("FF0$value").toColor();
}
