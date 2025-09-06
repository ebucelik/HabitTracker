import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/cores/Database.dart';
import 'package:habit_tracker/extensions/ColorExtensions.dart';
import 'package:habit_tracker/models/Habit.dart';
import 'package:habit_tracker/models/TimestampWithNote.dart';
import 'package:habit_tracker/shared/AppColors.dart';
import 'package:habit_tracker/themes/light_mode.dart';
import 'package:habit_tracker/themes/theme_provider.dart';
import 'package:habit_tracker/views/HabitHeatMap.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:unicode_emojis/unicode_emojis.dart';

class HabitWidget extends StatefulWidget {
  const HabitWidget({super.key, required this.habit});

  final Habit habit;

  @override
  State<HabitWidget> createState() => _HabitWidgetState();
}

class _HabitWidgetState extends State<HabitWidget> {
  double successBackgroundHeight = 0;
  DateTime selectedDate = DateTime.now();
  bool showNotesContainer = false;
  bool showNotes = false;
  TimestampWithNote? timestampWithNote;
  ColorScheme colorScheme = lightMode.colorScheme;

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();
    selectedDate = DateTime(now.year, now.month, now.day);
    timestampWithNote = widget.habit.findTrackedTimestamp(selectedDate);
  }

  void trackHabit(BuildContext context) async {
    if (isSelectedTimestampTracked()) {
      removeHabit();
    } else {
      if (mounted) {
        setState(() {
          RenderBox box =
              globalKey.currentContext!.findRenderObject() as RenderBox;
          successBackgroundHeight = box.size.height;

          final timestamps = widget.habit.timestamps.toList();
          timestamps.add(TimestampWithNote(timestamp: selectedDate));

          widget.habit.timestamps = timestamps;

          final database = Provider.of<Database>(context, listen: false);
          database.addHabit(widget.habit);
        });

        final canVibrate = await Haptics.canVibrate();

        if (canVibrate) {
          await Haptics.vibrate(HapticsType.warning);
        }
      }
    }
  }

  void resetSuccessBackgroundHeight() async {
    await Future.delayed(Duration(milliseconds: 2000));

    if (mounted) {
      setState(() {
        successBackgroundHeight = 0;
      });
    }
  }

  bool isSelectedTimestampTracked() {
    return widget.habit.isSelectedTimestampTracked(selectedDate);
  }

  void removeHabit() async {
    final canVibrate = await Haptics.canVibrate();

    if (canVibrate) {
      await Haptics.vibrate(HapticsType.medium);
    }

    if (mounted) {
      setState(() {
        final timestamps = widget.habit.timestamps.toList();

        timestamps.removeWhere(
          (timestamp) =>
              timestamp.timestamp?.day == selectedDate.day &&
              timestamp.timestamp?.month == selectedDate.month &&
              timestamp.timestamp?.year == selectedDate.year,
        );

        widget.habit.timestamps = timestamps;

        final database = Provider.of<Database>(context, listen: false);
        database.addHabit(widget.habit);
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
    bool isScaled = Provider.of<ThemeProvider>(context, listen: false).isScaled;
    colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Stack(
        alignment: AlignmentGeometry.bottomCenter,
        children: [
          AnimatedContainer(
            key: globalKey,
            duration: Duration(milliseconds: isScaled ? 0 : 300),
            width: double.infinity,
            child: Column(children: [headerWidget(), bodyWidget()]),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: double.infinity,
            height: successBackgroundHeight,
            padding: EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: successBackgroundHeight > 0
                  ? color(widget.habit.color)
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
      ),
    );
  }

  Widget headerWidget() {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 0, 8, 4),
      child: Row(
        spacing: 8,
        children: [
          Text(
            UnicodeEmojis.allEmojis
                .firstWhere((emoji) => emoji.unified == widget.habit.emoji)
                .emoji,
            style: TextStyle(fontSize: 25),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.habit.name,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                Text(
                  widget.habit.description,
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 10),
                ),
              ],
            ),
          ),
          isSelectedTimestampTracked() && isTimestampNoteAvailable()
              ? GestureDetector(
                  onTap: () => {
                    setState(() {
                      showNotesContainer = !showNotesContainer;
                      showNotes = !showNotesContainer ? false : showNotes;
                    }),
                  },
                  child: Icon(
                    Icons.info_rounded,
                    size: 30,
                    color: colorScheme.secondary,
                  ),
                )
              : Container(),
          GestureDetector(
            onTap: () => trackHabit(context),
            child: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: widget.habit.color.toColor().withValues(
                  alpha: isSelectedTimestampTracked() ? 1 : 0.5,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                size: 18,
                CupertinoIcons.check_mark,
                color: colorScheme.primary.withValues(
                  alpha: isSelectedTimestampTracked() ? 1 : 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget bodyWidget() {
    bool isScaled = Provider.of<ThemeProvider>(context, listen: false).isScaled;
    final database = context.watch<Database>();

    return CupertinoContextMenu(
      enableHapticFeedback: true,
      actions: [
        CupertinoContextMenuAction(
          onPressed: () {
            database.deleteHabit(widget.habit.id);
            Navigator.pop(context);
          },
          isDestructiveAction: true,
          trailingIcon: CupertinoIcons.trash,
          child: Text("Delete"),
        ),
      ],
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width - 50,
        child: Material(
          child: DecoratedBox(
            decoration: BoxDecoration(),
            child: Row(
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
                      isScaled ? 0 : 8,
                      8,
                      isScaled ? 0 : 8,
                    ),
                    child: HabitHeatMap(
                      habit: widget.habit,
                      isScaled: isScaled,
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
            ),
          ),
        ),
      ),
    );
  }
}
