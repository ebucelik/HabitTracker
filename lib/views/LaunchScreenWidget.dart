import 'package:flutter/material.dart';
import 'package:habit_tracker/themes/light_mode.dart';
import 'package:habit_tracker/themes/theme_provider.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class LaunchScreenWidget extends StatelessWidget {
  const LaunchScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Lottie.asset(
            Provider.of<ThemeProvider>(context).themeData == lightMode
                ? 'assets/lottie/entry_light.json'
                : 'assets/lottie/entry.json',
            width: 150,
            height: 150,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
