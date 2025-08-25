import 'package:flutter/material.dart';
import 'package:habit_tracker/models/Habit.dart';
import 'package:habit_tracker/shared/AppColors.dart';

class HabitWidget extends StatefulWidget {
  const HabitWidget({super.key, required this.habit});

  final Habit habit;

  @override
  State<HabitWidget> createState() => _HabitWidgetState();
}

class _HabitWidgetState extends State<HabitWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150,
      padding: EdgeInsets.symmetric(horizontal: 16),
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: widget.habit.color.withAlpha(50),
        border: Border.all(color: AppColors.primary.color()),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        widget.habit.name,
        style: TextStyle(color: AppColors.primary.color()),
      ),
    );
  }
}
