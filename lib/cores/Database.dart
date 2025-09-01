import 'package:flutter/material.dart';
import 'package:habit_tracker/models/Habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class Database extends ChangeNotifier {
  static late Isar isar;

  final List<Habit> habits = [];

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([HabitSchema], directory: dir.path);
  }

  Future<void> addHabit(Habit habit) async {
    await isar.writeTxn(() => isar.habits.put(habit));

    getHabits();
  }

  Future<void> getHabits() async {
    List<Habit> fetchedHabits = await isar.habits.where().findAll();

    habits.clear();
    habits.addAll(fetchedHabits);

    notifyListeners();
  }

  Future<void> updateHabit(Habit habit) async {
    Habit? savedHabit = await isar.habits.get(habit.id);

    if (savedHabit != null) {
      savedHabit = habit;

      await isar.writeTxn(() async {
        await isar.habits.put(savedHabit ?? habit);
      });

      getHabits();
    }
  }

  Future<void> deleteHabit(int id) async {
    await isar.writeTxn(() async {
      await isar.habits.delete(id);
    });

    getHabits();
  }
}
