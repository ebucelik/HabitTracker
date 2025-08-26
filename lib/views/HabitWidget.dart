import 'dart:async';

import 'package:flutter/material.dart';
import 'package:habit_tracker/models/DaysInYear.dart';
import 'package:habit_tracker/models/Habit.dart';
import 'package:habit_tracker/models/TimestampWithNote.dart';
import 'package:habit_tracker/shared/AppColors.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:lottie/lottie.dart';

class HabitWidget extends StatefulWidget {
  const HabitWidget({super.key, required this.habit, required this.daysInYear});

  final Habit habit;
  final List<List<DaysInYear>> daysInYear;

  @override
  State<HabitWidget> createState() => _HabitWidgetState();
}

class _HabitWidgetState extends State<HabitWidget> {
  bool trackButtonIsPressed = false;
  bool isLoopActive = false;
  int counter = 0;
  double widthToReach = 0;
  double widthIncreaseStep = 150;
  double trackButtonBackgroundWidth = 0;
  double successBackgroundHeight = 0;
  DateTime selectedDate = DateTime.now();
  bool showNotes = false;

  void increaseCounterWhileTrackButtonIsPressed() async {
    if (isLoopActive || isSelectedTimestampTracked()) return;

    isLoopActive = true;

    while (trackButtonIsPressed) {
      await Future.delayed(Duration(milliseconds: 1000));

      setState(() {
        trackButtonBackgroundWidth += widthIncreaseStep;
      });

      final canVibrate = await Haptics.canVibrate();

      if (canVibrate) {
        await Haptics.vibrate(HapticsType.success);
      }

      if (trackButtonBackgroundWidth >= widthToReach) {
        isLoopActive = false;
        trackButtonIsPressed = false;
        counter = 0;
        successBackgroundHeight = 300;

        if (canVibrate) {
          await Haptics.vibrate(HapticsType.warning);
        }

        setState(() {
          widget.habit.timestamps.add(
            TimestampWithNote(timestamp: selectedDate),
          );
        });
      }
    }

    isLoopActive = false;
  }

  void resetSuccessBackgroundHeight() async {
    await Future.delayed(Duration(milliseconds: 3000));

    if (mounted) {
      setState(() {
        successBackgroundHeight = 0;
      });
    }
  }

  void resetTrackButtonBackgroundWidth() async {
    await Future.delayed(Duration(milliseconds: 1000));

    if (mounted) {
      setState(() {
        trackButtonBackgroundWidth = 0;
      });
    }
  }

  bool isSelectedTimestampTracked() {
    return widget.habit.isSelectedTimestampTracked(selectedDate);
  }

  void onTrackButtonPressed() async {
    final canVibrate = await Haptics.canVibrate();

    if (canVibrate) {
      await Haptics.vibrate(HapticsType.medium);
    }

    if (mounted) {
      setState(() {
        trackButtonBackgroundWidth = 0;

        widget.habit.timestamps.removeWhere(
          (timestamp) =>
              timestamp.timestamp.day == selectedDate.day &&
              timestamp.timestamp.month == selectedDate.month &&
              timestamp.timestamp.year == selectedDate.year,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentGeometry.bottomCenter,
      children: [
        Container(
          width: double.infinity,
          height: 300,
          margin: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.primary.color(),
            border: Border.all(color: AppColors.primary.color()),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [headerWidget(), bodyWidget(), footerWidget()],
          ),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: double.infinity,
          height: successBackgroundHeight,
          padding: EdgeInsets.only(top: 8),
          margin: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: widget.habit.color,
            border: Border.all(color: AppColors.primary.color()),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Stack(
              children: [
                Lottie.asset(
                  'assets/lottie/confetti.json',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.fitHeight,
                ),
                Center(
                  child: Lottie.asset(
                    'assets/lottie/success.json',
                    width: 200,
                    height: 200,
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ],
            ),
          ),
          onEnd: () => {resetSuccessBackgroundHeight()},
        ),
      ],
    );
  }

  Widget headerWidget() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.color(),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: Row(
        spacing: 8,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.color().withAlpha(150),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(widget.habit.iconData, color: widget.habit.color),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.habit.name,
                  style: TextStyle(
                    color: AppColors.background.color(),
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  widget.habit.description,
                  style: TextStyle(
                    color: AppColors.background.color(),
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text("🔥", style: TextStyle(fontSize: 30)),
          Container(
            margin: EdgeInsets.only(right: 8),
            child: Text(
              widget.habit.streak.toString(),
              style: TextStyle(
                color: AppColors.background.color(),
                fontWeight: FontWeight.w700,
                fontSize: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget bodyWidget() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.fromLTRB(8, 0, 8, 4),
        decoration: BoxDecoration(color: AppColors.primary.color()),
        child: Row(
          children: [
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: widget.daysInYear
                    .map(
                      (calendar) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: calendar
                            .map(
                              (daysInYear) => daysInYear.days == 0
                                  ? SizedBox(
                                      height: 20,
                                      child: Text(
                                        daysInYear.month.isEmpty
                                            ? ""
                                            : daysInYear.month.substring(0, 3),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                          color: AppColors.background.color(),
                                        ),
                                      ),
                                    )
                                  : Flexible(
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        margin: EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: widget.habit.color.withAlpha(
                                            widget.habit.isSelectedTimestampTracked(
                                                      DateTime(
                                                        daysInYear.year,
                                                        daysInYear.monthNum,
                                                        daysInYear.days,
                                                      ),
                                                    ) ==
                                                    true
                                                ? 255
                                                : 40,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                    ),
                            )
                            .toList(),
                      ),
                    )
                    .toList(),
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 100),
              width: showNotes ? 100 : 0,
              margin: EdgeInsets.fromLTRB(4, 24, 4, 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: showNotes
                    ? [
                        Text(
                          "12.08.2025",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Keine Notizen verfügbar.",
                          style: TextStyle(fontSize: 10),
                        ),
                      ]
                    : [],
              ),
            ),
            Align(
              alignment: AlignmentGeometry.center,
              child: Container(
                height: double.infinity,
                width: 40,
                margin: EdgeInsets.fromLTRB(4, 24, 0, 4),
                decoration: BoxDecoration(
                  color: widget.habit.color.withAlpha(180),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AppColors.unselectedItem.color().withAlpha(100),
                  ),
                ),
                child: IconButton(
                  color: AppColors.primary.color(),
                  onPressed: () => {
                    setState(() {
                      showNotes = !showNotes;
                    }),
                  },
                  icon: Icon(
                    showNotes
                        ? Icons.arrow_forward_rounded
                        : Icons.arrow_back_rounded,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget footerWidget() {
    return Listener(
      onPointerDown: (_) => {
        trackButtonIsPressed = true,
        increaseCounterWhileTrackButtonIsPressed(),
      },
      onPointerUp: (_) => {
        trackButtonIsPressed = false,
        counter = 0,
        resetTrackButtonBackgroundWidth(),
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          widthToReach = constraints.widthConstraints().maxWidth;

          return isSelectedTimestampTracked()
              ? GestureDetector(
                  child: trackButtonWidget(),
                  onTap: () => {onTrackButtonPressed()},
                )
              : trackButtonWidget();
        },
      ),
    );
  }

  Widget trackButtonWidget() {
    return SizedBox(
      height: 50,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: Duration(seconds: 1),
            alignment: AlignmentGeometry.center,
            height: double.infinity,
            width: isSelectedTimestampTracked()
                ? widthToReach
                : trackButtonBackgroundWidth,
            decoration: BoxDecoration(
              color: widget.habit.color,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(9),
                bottomRight: Radius.circular(9),
              ),
            ),
          ),
          Container(
            alignment: AlignmentGeometry.center,
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              color: trackButtonIsPressed
                  ? Colors.grey.withAlpha(30)
                  : widget.habit.color.withAlpha(150),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(9),
                bottomRight: Radius.circular(9),
              ),
            ),
            child: isSelectedTimestampTracked()
                ? Center(
                    child: Icon(
                      Icons.check_circle_outline,
                      size: 30,
                      color: AppColors.primary.color(),
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.check,
                      size: 30,
                      color: AppColors.primary.color(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
