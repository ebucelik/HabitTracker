import 'dart:async';

import 'package:flutter/material.dart';
import 'package:habit_tracker/models/Habit.dart';
import 'package:habit_tracker/models/TimestampWithNote.dart';
import 'package:habit_tracker/shared/AppColors.dart';
import 'package:habit_tracker/themes/dark_mode.dart';
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
  bool showNotesContainer = false;
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
            RenderBox box =
                globalKey.currentContext!.findRenderObject() as RenderBox;
            successBackgroundHeight = box.size.height;
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

  void vibrateOnDatetimeSelect() async {
    final canVibrate = await Haptics.canVibrate();

    if (canVibrate) {
      await Haptics.vibrate(HapticsType.selection);
    }
  }

  final GlobalKey globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    colorScheme = Theme.of(context).colorScheme;

    return Stack(
      alignment: AlignmentGeometry.bottomCenter,
      children: [
        AnimatedContainer(
          key: globalKey,
          duration: Duration(milliseconds: widget.isScaled ? 0 : 300),
          width: double.infinity,
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
            borderRadius: BorderRadius.circular(6),
            boxShadow: successBackgroundHeight > 0
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: Offset(0, 0), // changes position of shadow
                    ),
                  ]
                : [],
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
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.inversePrimary,
              border: Border.all(
                width: 1,
                color: colorScheme.primary.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: Offset(0, 0), // changes position of shadow
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(
              8,
              widget.isScaled ? 0 : 8,
              8,
              widget.isScaled ? 0 : 8,
            ),
            child: HabitHeatMap(
              habit: widget.habit,
              isScaled: widget.isScaled,
              onDateTimeSelected: (selectedDateTime) => setState(() {
                vibrateOnDatetimeSelect();

                showNotesContainer = false;
                selectedDate = selectedDateTime;
                timestampWithNote = widget.habit.findTrackedTimestamp(
                  selectedDateTime,
                );
              }),
            ),
          ),
        ),
        AnimatedContainer(
          margin: showNotesContainer
              ? EdgeInsets.symmetric(horizontal: 4)
              : null,
          padding: showNotesContainer ? EdgeInsets.all(4) : null,
          duration: Duration(milliseconds: 200),
          width: showNotesContainer ? 100 : 0,
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
          onEnd: () => setState(() {
            showNotes = showNotesContainer;
          }),
        ),
      ],
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
    return Container(
      margin: EdgeInsets.only(top: 8),
      height: 50,
      child: Row(
        children: [
          Expanded(
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
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                Container(
                  alignment: AlignmentGeometry.center,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: widget.habit.color.withAlpha(150),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: Offset(0, 0), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Center(
                    child: isSelectedTimestampTracked()
                        ? Icon(
                            Icons.check_circle_outline,
                            size: 30,
                            color: AppColors.primary.color(),
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
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary.color(),
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
          isSelectedTimestampTracked() && isTimestampNoteAvailable()
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Center(
                    child: IconButton(
                      onPressed: () => {
                        setState(() {
                          showNotesContainer = !showNotesContainer;
                          showNotes = !showNotesContainer ? false : showNotes;
                        }),
                      },
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
    );
  }
}
