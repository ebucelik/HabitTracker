import 'package:flutter/material.dart';
import 'package:habit_tracker/models/HabitCategory.dart';
import 'package:habit_tracker/models/TimestampWithNote.dart';
import 'package:isar/isar.dart';
import 'package:unicode_emojis/unicode_emojis.dart';

part 'Habit.g.dart';

@Collection()
class Habit {
  Id id = Isar.autoIncrement;
  String description;
  String name;
  String emoji;
  String color;
  int streak;
  String category;
  bool showNote;
  List<TimestampWithNote> timestamps = [];

  Habit(
    this.id,
    this.name,
    this.description,
    this.emoji,
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
              timestamp?.timestamp?.day == selectedTimestamp.day &&
              timestamp?.timestamp?.month == selectedTimestamp.month &&
              timestamp?.timestamp?.year == selectedTimestamp.year,
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
      0,
      "Work",
      "2 hours of pure work.",
      UnicodeEmojis.allEmojis.first.emoji,
      Colors.blue.toARGB32().toRadixString(16),
      0,
      HabitCategory.work.value,
      false,
      List.of([
        TimestampWithNote(timestamp: DateTime.now(), note: "Ebu"),
      ], growable: true),
    ),
    Habit(
      1,
      "Gym",
      "Go 5 times a week",
      UnicodeEmojis.allEmojis.first.emoji,
      Colors.red.toARGB32().toRadixString(16),
      4,
      HabitCategory.fitness.value,
      false,
      List.of([
        TimestampWithNote(
          timestamp: DateTime.now().subtract(Duration(days: 100)),
          note: "I trained triceps.",
        ),
      ], growable: true),
    ),
    Habit(
      2,
      "Stop Sugar",
      "Don't eat sugar!",
      UnicodeEmojis.allEmojis.first.emoji,
      Colors.orange.toARGB32().toRadixString(16),
      2,
      HabitCategory.nutrition.value,
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
