import 'package:flutter/material.dart';
import 'package:habit_tracker/models/DaysInYear.dart';
import 'package:habit_tracker/models/Habit.dart';
import 'package:habit_tracker/views/HabitWidget.dart';
import 'package:intl/intl.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key, required this.habits});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();

  final List<Habit> habits;
}

class _HomeWidgetState extends State<HomeWidget> {
  late List<DaysInYear> daysInYear = generateDaysInYearList();

  List<DaysInYear> generateDaysInYearList() {
    int currentYear = DateTime.now().year;
    List<int> months = Iterable<int>.generate(12).toList();
    List<(int, String)> sumDaysWithMonthNames = months
        .map(
          (month) => (
            DateUtils.getDaysInMonth(currentYear, month + 1),
            getMonthString(month + 1, currentYear),
          ),
        )
        .toList();
    List<List<(int, String)>> listOfSumDays = sumDaysWithMonthNames
        .map(
          (days) => Iterable<(int, String)>.generate(
            days.$1,
            (day) => (day, day == 1 ? days.$2 : ""),
          ).toList(),
        )
        .map(
          (day) =>
              day.map((singleDay) => (singleDay.$1 + 1, singleDay.$2)).toList(),
        )
        .toList();

    List<(int, String)> daysOfEachMonth = List.empty(growable: true);
    for (var dayList in listOfSumDays) {
      daysOfEachMonth.addAll(dayList);
    }

    return daysOfEachMonth
        .map((day) => DaysInYear(day.$1, day.$2, currentYear))
        .toList();
  }

  String getMonthString(int month, int year) {
    final DateTime dateTime = DateTime(year, month, 1);
    final DateFormat formatter = DateFormat('MMMM');
    return formatter.format(dateTime);
  }

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
                  child: HabitWidget(habit: habit, daysInYear: daysInYear),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
