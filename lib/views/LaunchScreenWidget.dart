import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LaunchScreenWidget extends StatelessWidget {
  const LaunchScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Lottie.asset(
            'assets/lottie/entry.json',
            width: 150,
            height: 150,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
