import 'package:flutter/material.dart';
import 'package:habit_tracker/models/Habit.dart';
import 'package:habit_tracker/views/HabitWidget.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key, required this.habits});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();

  final List<Habit> habits;
}

class _HomeWidgetState extends State<HomeWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
          shrinkWrap: false,
          children: widget.habits
              .map(
                (habit) => Padding(
                  padding: EdgeInsetsGeometry.symmetric(
                    horizontal: 8,
                    vertical: 4,
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
