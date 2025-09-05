import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/cores/Database.dart';
import 'package:habit_tracker/models/Habit.dart';
import 'package:habit_tracker/themes/dark_mode.dart';
import 'package:habit_tracker/themes/light_mode.dart';
import 'package:habit_tracker/themes/theme_provider.dart';
import 'package:habit_tracker/views/CreateHabitWidget.dart';
import 'package:habit_tracker/views/HabitWidget.dart';
import 'package:provider/provider.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => HomeWidgetState();
}

class HomeWidgetState extends State<HomeWidget> {
  List<Habit> habits = List.of([], growable: true);

  StreamSubscription? habitStream;

  void presentPaywall() async {
    final paywallResult = await RevenueCatUI.presentPaywall();
    print(paywallResult);
  }

  Future<void> _getHabits() async {
    habitStream = Database.isar.habits
        .buildQuery<Habit>()
        .watch(fireImmediately: true)
        .listen((habits) {
          setState(() {
            this.habits = habits.reversed.toList();
          });
        });
  }

  @override
  void initState() {
    super.initState();

    _getHabits();
  }

  @override
  void dispose() {
    habitStream?.cancel();

    super.dispose();
  }

  var width = 0.0;
  var height = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(
          context,
        ).colorScheme.surface.withValues(alpha: 0.8),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                Provider.of<ThemeProvider>(context).themeData == lightMode
                    ? "assets/images/HabitTrackerLogo.png"
                    : "assets/images/HabitTrackerLogoLight.png",
                height: 25,
                width: 25,
              ),
            ),
            Text("ABIT", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              " TRACKER",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            height: 30,
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Theme.of(context).colorScheme.primary),
            ),
            child: GestureDetector(
              onTap: () => presentPaywall(),
              child: Text("PRO", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute<void>(
                  builder: (context) => const CreateHabitWidget(),
                ),
              );
            },
            icon: Icon(Icons.add_circle_outline_rounded, size: 30),
          ),
        ],
      ),
      body: Center(
        child: ListView(
          children:
              <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    spacing: 8,
                    children: [
                      Container(
                        height: 35,
                        width: 70,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha(15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(),
                        ),
                        child: TextButton(
                          onPressed: () => setState(() {
                            Provider.of<ThemeProvider>(
                              context,
                              listen: false,
                            ).toggleTheme();
                          }),
                          child: Icon(
                            Theme.of(context) == darkMode
                                ? Icons.light_mode_rounded
                                : Icons.dark_mode_rounded,
                            size: 18,
                          ),
                        ),
                      ),
                      Container(
                        height: 35,
                        width: 70,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha(15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(),
                        ),
                        child: TextButton(
                          onPressed: () => setState(() {
                            Provider.of<ThemeProvider>(
                              context,
                              listen: false,
                            ).toggleIsScaled();
                          }),
                          child: Icon(
                            Provider.of<ThemeProvider>(
                                  context,
                                  listen: false,
                                ).isScaled
                                ? Icons.zoom_in_map_rounded
                                : Icons.zoom_out_map_rounded,
                            size: 18,
                          ),
                        ),
                      ),
                      Expanded(child: Container()),
                    ],
                  ),
                ),
              ] +
              habits
                  .map(
                    (habit) => Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      margin: EdgeInsetsGeometry.symmetric(
                        horizontal: 8,
                        vertical: 16,
                      ),
                      child: HabitWidget(habit: habit),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}
