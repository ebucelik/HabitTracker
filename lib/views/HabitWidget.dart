import 'dart:async';

import 'package:flutter/material.dart';
import 'package:habit_tracker/models/Habit.dart';
import 'package:habit_tracker/models/TimestampWithNote.dart';
import 'package:habit_tracker/shared/AppColors.dart';
import 'package:habit_tracker/themes/light_mode.dart';
import 'package:habit_tracker/views/HabitHeatMap.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class HabitWidget extends StatefulWidget {
  const HabitWidget({super.key, required this.habit, required this.isScaled});

  final Habit habit;
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
  ColorScheme colorScheme = lightMode.colorScheme;

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();
    selectedDate = DateTime(now.year, now.month, now.day);
    timestampWithNote = widget.habit.findTrackedTimestamp(selectedDate);
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
            successBackgroundHeight = widget.isScaled ? 378 : 220;
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

  String defaultNote = "";

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

  bool isTimestampNoteAvailable() {
    var note = widget.habit.findTrackedTimestamp(selectedDate)?.note;

    return note != null && note != "";
  }

  @override
  Widget build(BuildContext context) {
    colorScheme = Theme.of(context).colorScheme;

    return Stack(
      alignment: AlignmentGeometry.bottomCenter,
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: widget.isScaled ? 0 : 300),
          width: double.infinity,
          height: widget.isScaled ? 378 : 220,
          child: Column(
            children: [headerWidget(), bodyWidget(), footerWidget()],
          ),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: double.infinity,
          height: successBackgroundHeight,
          padding: EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: successBackgroundHeight > 0
                ? widget.habit.color
                : Colors.transparent,
            border: Border.all(width: 2, color: colorScheme.primary),
            borderRadius: BorderRadius.circular(8),
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
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                Text(
                  widget.habit.description,
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
                ),
              ],
            ),
          ),
          Text("🔥", style: TextStyle(fontSize: 30)),
          Container(
            margin: EdgeInsets.only(right: 8),
            child: Text(
              widget.habit.streak.toString(),
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 30),
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
          border: Border.all(width: 2, color: colorScheme.primary),
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
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    padding: EdgeInsets.only(
                      left: 8,
                      top: widget.isScaled ? 0 : 6,
                      right: 8,
                      bottom: 0,
                    ),
                    child: HabitHeatMap(
                      habit: widget.habit,
                      isScaled: widget.isScaled,
                      onDateTimeSelected: (selectedDateTime) => setState(() {
                        showNotes = false;
                        selectedDate = selectedDateTime;
                      }),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(child: Container()),
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withAlpha(150),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              width: showNotes ? 100 : 0,
                              margin: showNotes
                                  ? EdgeInsets.fromLTRB(
                                      4,
                                      widget.isScaled ? 24 : 9,
                                      0,
                                      4,
                                    )
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
                                            color: colorScheme.surface,
                                          ),
                                        ),

                                        Text(
                                          getTimestampNote(timestampWithNote),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: colorScheme.surface,
                                          ),
                                        ),
                                      ]
                                    : [],
                              ),
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
            decoration: BoxDecoration(
              color: widget.habit.color.withAlpha(150),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(9),
                bottomRight: Radius.circular(9),
              ),
              border: Border(
                left: BorderSide(width: 2, color: colorScheme.primary),
                right: BorderSide(width: 2, color: colorScheme.primary),
                bottom: BorderSide(width: 2, color: colorScheme.primary),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration:
                        isSelectedTimestampTracked() &&
                            isTimestampNoteAvailable()
                        ? BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                width: 1,
                                color: colorScheme.primary,
                              ),
                            ),
                          )
                        : null,
                    child: isSelectedTimestampTracked()
                        ? Center(
                            child: Icon(Icons.check_circle_outline, size: 30),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check, size: didTapOnTrack ? 20 : 30),
                              didTapOnTrack
                                  ? Text(
                                      "Hold to track",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                  ),
                ),
                isSelectedTimestampTracked() && isTimestampNoteAvailable()
                    ? Container(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          border: Border(
                            left: BorderSide(
                              width: isSelectedTimestampTracked() ? 1 : 0,
                              color: colorScheme.primary,
                            ),
                          ),
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(6),
                          ),
                        ),
                        child: Center(
                          child: IconButton(
                            onPressed: () => showNotes = !showNotes,
                            icon: Icon(
                              Icons.info_rounded,
                              size: 30,
                              color: colorScheme.secondary,
                            ),
                          ),
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
