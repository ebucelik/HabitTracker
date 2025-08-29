import 'package:flutter/material.dart';
import 'package:habit_tracker/models/Habit.dart';
import 'package:habit_tracker/views/HeatMap/data/heatmap_color_mode.dart';
import 'package:habit_tracker/views/HeatMap/heatmap.dart';

class HabitHeatMap extends StatefulWidget {
  const HabitHeatMap({
    super.key,
    required this.habit,
    required this.isScaled,
    required this.onDateTimeSelected,
  });

  final Habit habit;
  final bool isScaled;
  final Function(DateTime) onDateTimeSelected;

  @override
  State<HabitHeatMap> createState() => _HabitHeatMapState();
}

class _HabitHeatMapState extends State<HabitHeatMap> {
  DateTime selectedDateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return HeatMap(
      endDate: DateTime.now().add(Duration(days: 1)),
      colorsets: {1: widget.habit.color},
      colorMode: ColorMode.color,
      fontSize: widget.isScaled ? 10 : 6,
      defaultColor: widget.habit.color.withAlpha(50),
      datasets: {
        for (var timestamp in widget.habit.timestamps)
          DateTime(
            timestamp.timestamp.year,
            timestamp.timestamp.month,
            timestamp.timestamp.day,
          ): 1,
      },
      showColorTip: false,
      scrollable: true,
      size: widget.isScaled ? 30 : 10,
      margin: EdgeInsets.all(widget.isScaled ? 2.2 : 1.8),
      borderRadius: widget.isScaled ? 4 : 2,
      onClick: (dateTime) => setState(() {
        selectedDateTime = dateTime;
        widget.onDateTimeSelected(dateTime);
      }),
      selectedDateTime: selectedDateTime,
      isScaled: widget.isScaled,
      habit: widget.habit,
    );
  }
}
