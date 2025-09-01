import 'package:flutter/material.dart';
import 'package:habit_tracker/themes/dark_mode.dart';
import 'package:habit_tracker/themes/light_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData? _themeData;

  ThemeData get themeData => _themeData ?? lightMode;

  bool get _isDarkMode => _themeData == darkMode;

  bool? _isScaled;

  bool get isScaled => _isScaled ?? false;

  SharedPreferences? _sharedPreferences;
  final String isDarkKey = "isDark";
  final String isScaledKey = "isScaled";

  ThemeProvider() {
    sharedPreferencesInit();
  }

  Future<void> sharedPreferencesInit() async {
    _sharedPreferences = await SharedPreferences.getInstance();

    themeData = _sharedPreferences?.getBool(isDarkKey) == true
        ? darkMode
        : lightMode;

    isScaled = _sharedPreferences?.getBool(isScaledKey) ?? false;
  }

  set themeData(ThemeData themeData) {
    _themeData = themeData;

    notifyListeners();
  }

  void toggleTheme() async {
    themeData = _isDarkMode ? lightMode : darkMode;

    await _sharedPreferences?.setBool(isDarkKey, _isDarkMode);
  }

  set isScaled(bool isScaled) {
    _isScaled = isScaled;

    notifyListeners();
  }

  void toggleIsScaled() async {
    isScaled = !(_isScaled ?? true);

    await _sharedPreferences?.setBool(isScaledKey, isScaled);
  }
}
