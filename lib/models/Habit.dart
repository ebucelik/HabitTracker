import 'package:flutter/material.dart';
import 'package:habit_tracker/models/HabitCategory.dart';
import 'package:habit_tracker/models/TimestampWithNote.dart';

class Habit {
  String name;
  String description;
  IconData iconData;
  Color color;
  int streak;
  HabitCategory category;
  bool showNote;
  List<TimestampWithNote> timestamps;

  Habit(
    this.name,
    this.description,
    this.iconData,
    this.color,
    this.streak,
    this.category,
    this.showNote,
    this.timestamps,
  );

  bool isSelectedTimestampTracked(DateTime selectedTimestamp) {
    return findTrackedTimestamp(selectedTimestamp) != null;
  }

  TimestampWithNote? findTrackedTimestamp(DateTime selectedTimestamp) {
    TimestampWithNote? timestampWithNote = timestamps
        .cast<TimestampWithNote?>()
        .firstWhere(
          (timestamp) =>
              timestamp?.timestamp.day == selectedTimestamp.day &&
              timestamp?.timestamp.month == selectedTimestamp.month &&
              timestamp?.timestamp.year == selectedTimestamp.year,
          orElse: () => null,
        );

    return timestampWithNote;
  }

  bool isTimestampNoteAvailale(DateTime selectedDateTime) {
    TimestampWithNote? timestamp = findTrackedTimestamp(selectedDateTime);

    return timestamp?.note != null && timestamp?.note != "";
  }

  static List<Habit> mock = List.of([
    Habit(
      "Work",
      "2 hours of pure work.",
      Icons.work,
      Colors.blue,
      0,
      HabitCategory.work,
      false,
      List.of([
        TimestampWithNote(timestamp: DateTime.now(), note: "Ebu"),
      ], growable: true),
    ),
    Habit(
      "Gym",
      "Go 5 times a week",
      Icons.fitness_center,
      Colors.red,
      4,
      HabitCategory.fitness,
      false,
      List.of([
        TimestampWithNote(
          timestamp: DateTime.now().subtract(Duration(days: 100)),
          note: "I trained triceps.",
        ),
      ], growable: true),
    ),
    Habit(
      "Stop Sugar",
      "Don't eat sugar!",
      Icons.apple,
      Colors.orange,
      2,
      HabitCategory.nutrition,
      false,
      List.of([
        TimestampWithNote(
          timestamp: DateTime.now().subtract(Duration(days: 10)),
          note: "Only protein caffe latte.",
        ),
      ]),
    ),
  ]);
}
