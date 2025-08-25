import 'dart:async';

import 'package:flutter/material.dart';
import 'package:habit_tracker/models/Habit.dart';
import 'package:habit_tracker/models/TimestampWithNote.dart';
import 'package:habit_tracker/shared/AppColors.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:lottie/lottie.dart';

class HabitWidget extends StatefulWidget {
  const HabitWidget({super.key, required this.habit});

  final Habit habit;

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

    setState(() {
      successBackgroundHeight = 0;
    });
  }

  void resetTrackButtonBackgroundWidth() async {
    await Future.delayed(Duration(milliseconds: 1000));

    setState(() {
      trackButtonBackgroundWidth = 0;
    });
  }

  bool isSelectedTimestampTracked() {
    return widget.habit.isSelectedTimestampTracked(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentGeometry.bottomCenter,
      children: [
        Container(
          width: double.infinity,
          height: 300,
          padding: EdgeInsets.only(top: 8),
          margin: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: widget.habit.color.withAlpha(60),
            border: Border.all(color: AppColors.primary.color()),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Row(
                  spacing: 8,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.unselectedItem.color().withAlpha(70),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        widget.habit.iconData,
                        color: widget.habit.color,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.habit.name,
                            style: TextStyle(
                              color: AppColors.primary.color(),
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            widget.habit.description,
                            style: TextStyle(
                              color: AppColors.primary.color(),
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
                          color: AppColors.primary.color(),
                          fontWeight: FontWeight.w700,
                          fontSize: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(color: AppColors.primary.color()),
                ),
              ),
              Listener(
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
              ),
            ],
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

  void onTrackButtonPressed() {
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
              color: Colors.transparent,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(9),
                bottomRight: Radius.circular(9),
              ),
            ),
            child: isSelectedTimestampTracked()
                ? Center(
                    child: Icon(
                      Icons.check_circle,
                      size: 30,
                      color: AppColors.primary.color(),
                    ),
                  )
                : Text(
                    "TRACK",
                    style: TextStyle(
                      color: AppColors.primary.color(),
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
        ],
      ),
    );
  }
}
