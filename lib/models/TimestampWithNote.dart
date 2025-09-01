import 'package:isar/isar.dart';

part 'TimestampWithNote.g.dart';

@embedded
class TimestampWithNote {
  DateTime? timestamp;
  String? note;

  TimestampWithNote({this.timestamp, this.note});
}
