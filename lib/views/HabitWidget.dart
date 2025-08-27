import 'dart:async';

import 'package:flutter/material.dart';
import 'package:habit_tracker/models/DaysInYear.dart';
import 'package:habit_tracker/models/Habit.dart';
import 'package:habit_tracker/models/TimestampWithNote.dart';
import 'package:habit_tracker/shared/AppColors.dart';
import 'package:habit_tracker/views/HomeWidget.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class HabitWidget extends StatefulWidget {
  HabitWidget({
    super.key,
    required this.habit,
    required this.daysInYear,
    required this.isScaled,
  });

  final Habit habit;
  List<List<DaysInYear>> daysInYear;
  final bool isScaled;

  @override
  State<HabitWidget> createState() => _HabitWidgetState();
}

class _HabitWidgetState extends State<HabitWidget> {
  bool trackButtonIsPressed = false;
  bool isLoopActive = false;
  int counter = 0;
  double widthToReach = 0;
  double trackButtonBackgroundWidth = 0;
  double successBackgroundHeight = 0;
  DateTime selectedDate = DateTime.now();
  bool showNotes = false;
  TimestampWithNote? timestampWithNote;
  bool didTapOnTrack = false;
  Timer timer = Timer(Duration.zero, () => {});

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();
    selectedDate = DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void increaseCounterWhileTrackButtonIsPressed() async {
    trackButtonIsPressed = true;

    if (isLoopActive || isSelectedTimestampTracked()) return;

    isLoopActive = true;

    while (trackButtonIsPressed) {
      if (mounted) {
        setState(() {
          trackButtonBackgroundWidth += widthToReach + 1;
        });
      }

      final canVibrate = await Haptics.canVibrate();

      if (canVibrate) {
        await Haptics.vibrate(HapticsType.success);
      }

      await Future.delayed(Duration(milliseconds: 800));

      if (trackButtonBackgroundWidth >= widthToReach) {
        if (mounted) {
          setState(() {
            isLoopActive = false;
            trackButtonIsPressed = false;
            counter = 0;
            successBackgroundHeight = widget.isScaled ? 240 : 300;
            widget.habit.timestamps.add(
              TimestampWithNote(timestamp: selectedDate),
            );
          });
        }

        if (canVibrate) {
          await Haptics.vibrate(HapticsType.warning);
        }
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

  void resetTrackButton() async {
    if (mounted) {
      setState(() {
        trackButtonIsPressed = false;
        counter = 0;
        trackButtonBackgroundWidth = 0;
        didTapOnTrack = false;
      });

      timer.cancel();
    }
  }

  void setDidTapOnTrack() {
    if (mounted) {
      setState(() {
        didTapOnTrack = true;
      });
    }

    timer = Timer(Duration(milliseconds: 3000), () => resetTrackButton());
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

  String getSelectedDate() {
    DateFormat formatDay = DateFormat("dd");
    DateFormat formatMonth = DateFormat("MM");

    return "${formatDay.format(selectedDate)}.${formatMonth.format(selectedDate)}.${selectedDate.year}";
  }

  String defaultNote = "Keine Notizen verfügbar.";

  String getTimestampNote(TimestampWithNote? timestampWithNote) {
    if (timestampWithNote != null) {
      if (timestampWithNote.note != null) {
        return timestampWithNote.note == ""
            ? defaultNote
            : timestampWithNote.note ?? defaultNote;
      }
    }

    return defaultNote;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentGeometry.bottomCenter,
      children: [
        Container(
          width: double.infinity,
          height: widget.isScaled ? 240 : 300,
          margin: EdgeInsets.all(4),
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
      padding: EdgeInsets.fromLTRB(8, 0, 8, 4),
      child: Row(
        spacing: 8,
        children: [
          Icon(widget.habit.iconData, color: widget.habit.color, size: 35),
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
    );
  }

  Widget bodyWidget() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary.color(),
          border: Border.all(color: AppColors.primary.color()),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.color(),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    padding: EdgeInsets.only(
                      left: 8,
                      top: 2,
                      right: 42,
                      bottom: 2,
                    ),
                    child: habitListView(),
                  ),
                  Row(
                    children: [
                      Expanded(child: Container()),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary.color().withAlpha(150),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              width: showNotes ? 100 : 0,
                              margin: showNotes
                                  ? EdgeInsets.fromLTRB(4, 24, 4, 4)
                                  : null,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: showNotes
                                    ? [
                                        Text(
                                          getSelectedDate(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),

                                        Text(
                                          getTimestampNote(timestampWithNote),
                                          style: TextStyle(fontSize: 10),
                                        ),
                                      ]
                                    : [],
                              ),
                            ),
                            Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    width: 40,
                                    margin: EdgeInsets.fromLTRB(
                                      0,
                                      widget.isScaled ? 17 : 24,
                                      0,
                                      4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: widget.habit.color.withAlpha(180),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: AppColors.unselectedItem
                                            .color()
                                            .withAlpha(100),
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget habitListView() {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: widget.daysInYear
          .map(
            (calendar) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: calendar
                  .map(
                    (daysInYear) => daysInYear.days == 0
                        ? SizedBox(
                            height: widget.isScaled ? 15 : 20,
                            child: Text(
                              daysInYear.month.isEmpty
                                  ? ""
                                  : daysInYear.month.substring(0, 3),
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: widget.isScaled ? 6 : 12,
                                color: AppColors.background.color(),
                              ),
                            ),
                          )
                        : Flexible(
                            flex: widget.isScaled ? 0 : 1,
                            child: InkWell(
                              onTap: () => {
                                setState(() {
                                  selectedDate = DateTime(
                                    daysInYear.year,
                                    daysInYear.monthNum,
                                    daysInYear.days,
                                  );
                                  timestampWithNote = widget.habit
                                      .findTrackedTimestamp(selectedDate);
                                }),
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    height: widget.isScaled ? 15 : 40,
                                    width: widget.isScaled ? 15 : 40,
                                    margin: EdgeInsets.all(
                                      widget.isScaled ? 1 : 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: widget.habit.color.withAlpha(
                                        widget.habit.isSelectedTimestampTracked(
                                              DateTime(
                                                daysInYear.year,
                                                daysInYear.monthNum,
                                                daysInYear.days,
                                              ),
                                            )
                                            ? 255
                                            : 40,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                      border:
                                          DateTime(
                                                daysInYear.year,
                                                daysInYear.monthNum,
                                                daysInYear.days,
                                              ) ==
                                              selectedDate
                                          ? Border.all(
                                              width: 2,
                                              color: AppColors.background
                                                  .color(),
                                            )
                                          : null,
                                    ),
                                  ),
                                  widget.habit.isSelectedTimestampTracked(
                                        DateTime(
                                          daysInYear.year,
                                          daysInYear.monthNum,
                                          daysInYear.days,
                                        ),
                                      )
                                      ? getTimestampNote(
                                                  widget.habit
                                                      .findTrackedTimestamp(
                                                        DateTime(
                                                          daysInYear.year,
                                                          daysInYear.monthNum,
                                                          daysInYear.days,
                                                        ),
                                                      ),
                                                ) !=
                                                defaultNote
                                            ? Positioned(
                                                top: 0.5,
                                                right: 3,
                                                child: Icon(
                                                  size: widget.isScaled
                                                      ? 8
                                                      : 18,
                                                  Icons.bookmark,
                                                  color: AppColors.background
                                                      .color(),
                                                ),
                                              )
                                            : Container()
                                      : Container(),
                                ],
                              ),
                            ),
                          ),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
  }

  Widget footerWidget() {
    return Listener(
      onPointerUp: (_) => resetTrackButton(),
      onPointerCancel: (_) => resetTrackButton(),
      child: InkWell(
        onTap: () => setDidTapOnTrack(),
        onLongPress: () => increaseCounterWhileTrackButtonIsPressed(),
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
    );
  }

  Widget trackButtonWidget() {
    return SizedBox(
      height: 50,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 800),
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
              color: widget.habit.color.withAlpha(150),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(9),
                bottomRight: Radius.circular(9),
              ),
              border: Border.all(color: AppColors.primary.color(), width: 2),
            ),
            child: isSelectedTimestampTracked()
                ? Center(
                    child: Icon(
                      Icons.check_circle_outline,
                      size: 30,
                      color: AppColors.primary.color(),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check,
                        size: didTapOnTrack ? 20 : 30,
                        color: AppColors.primary.color(),
                      ),
                      didTapOnTrack
                          ? Text(
                              "Hold to track",
                              style: TextStyle(
                                color: AppColors.primary.color(),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Container(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
