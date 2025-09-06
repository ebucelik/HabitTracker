import 'package:flutter/material.dart';
import 'package:habit_tracker/models/HabitCategory.dart';
import 'package:habit_tracker/models/TimestampWithNote.dart';
import 'package:isar/isar.dart';
import 'package:random_date/random_date.dart';

part 'Habit.g.dart';

@Collection()
class Habit {
  Id id = Isar.autoIncrement;
  String description;
  String name;
  String emoji;
  String color;
  String category;
  List<TimestampWithNote> timestamps = List.empty(growable: true);

  Habit(
    this.name,
    this.description,
    this.emoji,
    this.color,
    this.category,
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

  bool isHabitReady() {
    return name.isNotEmpty &&
        description.isNotEmpty &&
        color.isNotEmpty &&
        emoji.isNotEmpty;
  }

  static Habit empty = Habit("", "", "", "", "", List.of([], growable: true));

  static List<Habit> mock = List.of([
    Habit(
      "Gym",
      "Benchpress, Legpress and so on",
      "1F4AA",
      Colors.red.toARGB32().toRadixString(16),
      HabitCategory.work.value,
      List.generate(300, (index) {
        return TimestampWithNote(
          timestamp: RandomDate.withRange(2025, 2025).random(),
          note: index % 8 == 0 ? "Trained for 2 hours." : "",
        );
      }).toList(),
    ),
    Habit(
      "Drink Water",
      "Drink 1-2 liters of water",
      "1F4A7",
      Colors.blue.toARGB32().toRadixString(16),
      HabitCategory.fitness.value,
      List.generate(300, (index) {
        return TimestampWithNote(
          timestamp: RandomDate.withRange(2025, 2025).random(),
          note: index % 4 == 0 ? "Trained for 2 hours." : "",
        );
      }).toList(),
    ),
    Habit(
      "Read Books",
      "Learn to read & understand faster",
      "1F4D9",
      Colors.green.toARGB32().toRadixString(16),
      HabitCategory.nutrition.value,
      List.generate(300, (index) {
        return TimestampWithNote(
          timestamp: RandomDate.withRange(2025, 2025).random(),
          note: index % 4 == 0 ? "Trained for 2 hours." : "",
        );
      }).toList(),
    ),
    Habit(
      "Get Brown",
      "Be ready for the summer",
      "2600-FE0F",
      Colors.yellow.toARGB32().toRadixString(16),
      HabitCategory.nutrition.value,
      List.generate(300, (index) {
        return TimestampWithNote(
          timestamp: RandomDate.withRange(2025, 2025).random(),
          note: index % 4 == 0 ? "Trained for 2 hours." : "",
        );
      }).toList(),
    ),
  ]);
}
