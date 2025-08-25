import 'dart:async';

import 'package:flutter/material.dart';
import 'package:habit_tracker/models/Habit.dart';
import 'package:habit_tracker/shared/AppColors.dart';
import 'package:habit_tracker/views/LaunchScreenWidget.dart';
import 'package:habit_tracker/views/HomeWidget.dart';

void main() {
  runApp(const MainApp());
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
      home: isLaunchedInitially
          ? LaunchScreenWidget()
          : DefaultTabController(
              length: 3,
              child: Scaffold(
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
                  backgroundColor: AppColors.background.color(),
                ),
                backgroundColor: AppColors.background.color(),
                body: tabWidgets.elementAt(selectedIndex),
                bottomNavigationBar: BottomNavigationBar(
                  backgroundColor: AppColors.background.color(),
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: AppColors.primary.color(),
                  unselectedItemColor: AppColors.unselectedItem.color(),
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
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background.color(),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
    );
  }
}
