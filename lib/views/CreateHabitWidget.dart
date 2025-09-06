import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/cores/Database.dart';
import 'package:habit_tracker/models/Habit.dart';
import 'package:habit_tracker/views/EmojisWidget.dart';
import 'package:provider/provider.dart';
import 'package:unicode_emojis/unicode_emojis.dart';

class CreateHabitWidget extends StatefulWidget {
  const CreateHabitWidget({super.key, this.habit});

  final Habit? habit;

  @override
  State<CreateHabitWidget> createState() => _CreateHabitWidgetState();
}

class _CreateHabitWidgetState extends State<CreateHabitWidget> {
  Emoji selectedEmoji = UnicodeEmojis.search("smile").first;
  List<Color> colors = List.of([
    // Colors.indigo,
    // Colors.indigoAccent,
    Colors.blue,
    // Colors.lightBlue,
    Colors.cyan,
    // Colors.greenAccent,
    Colors.green,
    // Colors.lightGreen,
    // Colors.lightGreenAccent,
    // Colors.lime,
    // Colors.yellow,
    // Colors.amberAccent,
    Colors.amber,
    Colors.orange,
    // Colors.deepOrange,
    Colors.red,
    // Colors.redAccent,
    // Colors.pinkAccent,
    // Colors.pink,
    // Colors.purpleAccent,
    Colors.purple,
  ]);
  Color selectedColor = Colors.blue;

  Habit habit = Habit(
    "",
    "",
    UnicodeEmojis.search("smile").first.unified,
    Colors.blue.toARGB32().toRadixString(16),
    "",
    List.of([], growable: true),
  );

  @override
  void initState() {
    super.initState();

    if (widget.habit != null) {
      habit = widget.habit ?? Habit.empty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final database = context.watch<Database>();

    return Scaffold(
      appBar: CupertinoNavigationBar(
        backgroundColor: Theme.of(
          context,
        ).colorScheme.surface.withValues(alpha: 0.8),
        middle: Text("New Habit"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(CupertinoIcons.back),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: selectedColor.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.3),
                                  spreadRadius: 1,
                                  blurRadius: 8,
                                  offset: Offset(
                                    0,
                                    2,
                                  ), // changes position of shadow
                                ),
                              ],
                            ),
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: TextButton(
                              child: Text(
                                selectedEmoji.emoji,
                                style: TextStyle(
                                  fontSize: 90,
                                  decoration: TextDecoration.none,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              onPressed: () async {
                                final selectedEmoji =
                                    await showModalBottomSheet(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(8),
                                        ),
                                      ),
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (context) =>
                                          FractionallySizedBox(
                                            heightFactor: 0.8,
                                            child: EmojisWidget(),
                                          ),
                                    );

                                setState(() {
                                  if (selectedEmoji != null) {
                                    this.selectedEmoji = selectedEmoji;
                                    habit.emoji = this.selectedEmoji.unified;
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    child: Column(
                      spacing: 16,
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            hintText: "Name",
                            hintStyle: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            prefixIcon: Icon(
                              CupertinoIcons.person,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => {
                            setState(() {
                              habit.name = value;
                            }),
                          },
                        ),
                        TextField(
                          decoration: InputDecoration(
                            hintText: "Description",
                            hintStyle: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            prefixIcon: Icon(
                              CupertinoIcons.pen,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => {
                            setState(() {
                              habit.description = value;
                            }),
                          },
                        ),
                        GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 7,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          children: colors
                              .map(
                                (color) => GestureDetector(
                                  onTap: () => setState(() {
                                    selectedColor = color;
                                    habit.color = color
                                        .toARGB32()
                                        .toRadixString(16);
                                  }),
                                  child: Stack(
                                    alignment: AlignmentGeometry.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: color,
                                          border: Border.all(
                                            color: selectedColor == color
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.inversePrimary
                                                : Colors.transparent,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                      ),
                                      selectedColor == color
                                          ? Icon(
                                              CupertinoIcons.check_mark,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.inversePrimary,
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () async => {
                await database.addHabit(habit),

                Navigator.pop(context),
              },
              child: Container(
                height: 60,
                margin: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: habit.isHabitReady()
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: Offset(0, 0), // changes position of shadow
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Save",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
