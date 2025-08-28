import 'package:flutter/material.dart';
import 'package:habit_tracker/models/Habit.dart';
import 'package:habit_tracker/shared/AppColors.dart';
import 'package:habit_tracker/views/HabitWidget.dart';

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
                        color: AppColors.primary.color().withAlpha(50),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.primary.color()),
                      ),
                      child: TextButton(
                        onPressed: () => setState(() {
                          isScaled = !isScaled;
                        }),
                        child: Icon(
                          isScaled
                              ? Icons.zoom_out_map_rounded
                              : Icons.zoom_in_map_rounded,
                          size: 18,
                          color: AppColors.primary.color(),
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
                        vertical: 4,
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
