import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/models/Habit.dart';
import 'package:habit_tracker/views/EmojisWidget.dart';
import 'package:unicode_emojis/unicode_emojis.dart';

class CreateHabitWidget extends StatefulWidget {
  const CreateHabitWidget({super.key, this.habit});

  final Habit? habit;

  @override
  State<CreateHabitWidget> createState() => _CreateHabitWidgetState();
}

class _CreateHabitWidgetState extends State<CreateHabitWidget> {
  Emoji selectedEmoji = UnicodeEmojis.search("smile").first;

  @override
  Widget build(BuildContext context) {
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
      body: ListView(
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
                      color: Colors.amber.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: TextButton(
                      child: Text(
                        selectedEmoji.emoji,
                        style: TextStyle(
                          fontSize: 70,
                          decoration: TextDecoration.none,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () async {
                        final selectedEmoji = await showModalBottomSheet(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                          ),
                          isScrollControlled: true,
                          context: context,
                          builder: (context) => FractionallySizedBox(
                            heightFactor: 0.8,
                            child: EmojisWidget(),
                          ),
                        );

                        setState(() {
                          if (selectedEmoji != null) {
                            this.selectedEmoji = selectedEmoji;
                            widget.habit?.emoji = this.selectedEmoji.unified;
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
                  onChanged: (value) => {},
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
                  onChanged: (value) => {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
