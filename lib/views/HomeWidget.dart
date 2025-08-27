import 'package:flutter/material.dart';
import 'package:habit_tracker/models/DaysInYear.dart';
import 'package:habit_tracker/models/Habit.dart';
import 'package:habit_tracker/shared/AppColors.dart';
import 'package:habit_tracker/views/HabitWidget.dart';
import 'package:intl/intl.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key, required this.habits});

  @override
  State<HomeWidget> createState() => HomeWidgetState();

  final List<Habit> habits;
}

class HomeWidgetState extends State<HomeWidget> {
  late List<List<DaysInYear>> daysInYear = generateDaysInYearList(4);

  bool isScaled = false;

  List<List<DaysInYear>> generateDaysInYearList(int rows) {
    int currentYear = DateTime.now().year;
    List<int> months = Iterable<int>.generate(12).toList();

    months =
        months.sublist(DateTime.now().month - 1, months.length) +
        months.sublist(0, DateTime.now().month - 1);

    // months = months.reversed.toList();

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
            (day) => (day, day == 0 ? days.$2 : "", days.$3),
          ).toList().reversed.toList(),
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

    for (var index = 0; index < daysInYear.length; index += rows) {
      var sublist = daysInYear.sublist(
        index,
        index > 360 ? index + (daysInYear.length - index) : index + rows,
      );

      for (var subelement in sublist) {
        if (subelement.month.isNotEmpty) {
          sublist.insert(0, DaysInYear(0, subelement.month, 0, 0));
          subelement.month = "";

          break;
        }
      }

      if (sublist.length <= rows) {
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
                          daysInYear = generateDaysInYearList(isScaled ? 7 : 4);
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
                      child: HabitWidget(
                        habit: habit,
                        daysInYear: daysInYear,
                        isScaled: isScaled,
                      ),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}
