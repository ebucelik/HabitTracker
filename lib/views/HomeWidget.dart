import 'package:flutter/material.dart';
import 'package:habit_tracker/models/Habit.dart';
import 'package:habit_tracker/themes/dark_mode.dart';
import 'package:habit_tracker/themes/light_mode.dart';
import 'package:habit_tracker/themes/theme_provider.dart';
import 'package:habit_tracker/views/HabitWidget.dart';
import 'package:provider/provider.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key, required this.habits});

  @override
  State<HomeWidget> createState() => HomeWidgetState();

  final List<Habit> habits;
}

class HomeWidgetState extends State<HomeWidget> {
  bool isScaled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
          shrinkWrap: false,
          children:
              <Widget>[
                Row(
                  children: [
                    Expanded(child: Container()),
                    Container(
                      margin: EdgeInsets.only(right: 12),
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
                      margin: EdgeInsets.only(right: 12),
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
                          isScaled = !isScaled;
                        }),
                        child: Icon(
                          isScaled
                              ? Icons.zoom_in_map_rounded
                              : Icons.zoom_out_map_rounded,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ] +
              widget.habits
                  .map(
                    (habit) => Padding(
                      padding: EdgeInsetsGeometry.symmetric(
                        horizontal: 8,
                        vertical: 16,
                      ),
                      child: HabitWidget(habit: habit, isScaled: isScaled),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}
