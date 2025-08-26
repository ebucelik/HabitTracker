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
  late List<List<DaysInYear>> daysInYear = generateDaysInYearList();

  List<List<DaysInYear>> generateDaysInYearList() {
    int currentYear = DateTime.now().year;
    List<int> months = Iterable<int>.generate(12).toList();
    List<(int, String, int)> sumDaysWithMonthNames = months
        .map(
          (month) => (
            DateUtils.getDaysInMonth(currentYear, month + 1),
            getMonthString(month + 1, currentYear),
            month + 1,
          ),
        )
        .toList();
    List<List<(int, String, int)>> listOfSumDays = sumDaysWithMonthNames
        .map(
          (days) => Iterable<(int, String, int)>.generate(
            days.$1,
            (day) => (day, day == 1 ? days.$2 : "", days.$3),
          ).toList(),
        )
        .map(
          (day) => day
              .map(
                (singleDay) => (singleDay.$1 + 1, singleDay.$2, singleDay.$3),
              )
              .toList(),
        )
        .toList();

    List<(int, String, int)> daysOfEachMonth = List.empty(growable: true);
    for (var dayList in listOfSumDays) {
      daysOfEachMonth.addAll(dayList);
    }

    List<DaysInYear> daysInYear = daysOfEachMonth
        .map((day) => DaysInYear(day.$1, day.$2, day.$3, currentYear))
        .toList();

    List<List<DaysInYear>> daysInYearWithMonthOnTop = List.empty(
      growable: true,
    );

    for (var index = 0; index < daysInYear.length; index += 4) {
      var sublist = daysInYear.sublist(
        index,
        index > 360 ? index + (daysInYear.length - index) : index + 4,
      );

      for (var subelement in sublist) {
        if (subelement.month.isNotEmpty) {
          sublist.insert(0, DaysInYear(0, subelement.month, 0, 0));
          subelement.month = "";

          break;
        }
      }

      if (sublist.length <= 4) {
        sublist.insert(0, DaysInYear(0, "", 0, 0));
      }

      daysInYearWithMonthOnTop.add(sublist);
    }

    return daysInYearWithMonthOnTop;
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
