import 'package:flutter/material.dart';

class Habit {
  String name;
  String description;
  Color color;

  Habit(this.name, this.description, this.color);

  static List<Habit> mock = List.of([
    Habit("Football", "Go 3 times a week", Colors.blue),
    Habit("Gym", "Go 5 times a week", Colors.red),
    Habit("Stop Sugar", "Don't eat sugar!", Colors.orange),
  ]);
}
