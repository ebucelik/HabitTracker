import 'package:habit_tracker/extensions/ColorExtensions.dart';
import 'package:flutter/material.dart';

enum AppColors {
  background("222327"),
  primary("F1F2F0"),
  unselectedItem("6B7994"),
  success("95F54E");

  const AppColors(this.value);

  final String value;

  Color color() {
    return ("FF0$value").toColor();
  }
}
