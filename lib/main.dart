import 'dart:async';

import 'package:flutter/material.dart';
import 'package:habit_tracker/models/Habit.dart';
import 'package:habit_tracker/shared/AppColors.dart';
import 'package:habit_tracker/themes/light_mode.dart';
import 'package:habit_tracker/themes/theme_provider.dart';
import 'package:habit_tracker/views/LaunchScreenWidget.dart';
import 'package:habit_tracker/views/HomeWidget.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool isLaunchedInitially = true;
  int selectedIndex = 0;

  final List<Widget> tabWidgets = [
    HomeWidget(habits: Habit.mock),
    Text("Habit Entry"),
    Text("Account"),
  ];

  void onTabItemTapped(int currentIndex) {
    setState(() {
      selectedIndex = currentIndex;
    });
  }

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 5), handleTimeout);
  }

  void handleTimeout() {
    setState(() {
      isLaunchedInitially = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: isLaunchedInitially
          ? LaunchScreenWidget()
          : DefaultTabController(
              length: 3,
              child: Scaffold(
                extendBody: true,
                appBar: AppBar(
                  title: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        "assets/images/HabitTrackerLogo.png",
                        width: 40,
                        height: 40,
                      ),
                    ),
                  ),
                ),
                body: tabWidgets.elementAt(selectedIndex),
                bottomNavigationBar: BottomNavigationBar(
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  type: BottomNavigationBarType.fixed,
                  unselectedItemColor: AppColors.secondary.color(),
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_filled),
                      label: "Home",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.link_sharp),
                      label: "Habit",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: "Account",
                    ),
                  ],
                  currentIndex: selectedIndex,
                  onTap: onTabItemTapped,
                ),
              ),
            ),
    );
  }
}
