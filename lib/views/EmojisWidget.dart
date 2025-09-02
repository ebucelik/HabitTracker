import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unicode_emojis/unicode_emojis.dart';

class EmojisWidget extends StatefulWidget {
  const EmojisWidget({super.key});

  @override
  State<EmojisWidget> createState() => _EmojisWidgetState();
}

class _EmojisWidgetState extends State<EmojisWidget> {
  List<Emoji> allEmojis = UnicodeEmojis.allEmojis;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 16, bottom: 16, right: 16),
            child: Row(
              spacing: 0,
              children: [
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search for emojis",
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      prefixIcon: Icon(
                        CupertinoIcons.search,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() {
                      allEmojis = UnicodeEmojis.search(value);

                      if (value.isEmpty) {
                        allEmojis = UnicodeEmojis.allEmojis;
                      }
                    }),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.count(
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 0),
              crossAxisCount: 7,
              children: allEmojis
                  .map(
                    (emoji) => TextButton(
                      onPressed: () => Navigator.pop(context, emoji),
                      child: Text(emoji.emoji, style: TextStyle(fontSize: 30)),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
