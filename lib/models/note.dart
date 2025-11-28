import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String content;

  @HiveField(2)
  int bgColor;

  @HiveField(3)
  int fontColor;

  @HiveField(4)
  bool isArchived;

  @HiveField(5)
  bool isDeleted;

  Note({
    required this.title,
    required this.content,
    required this.bgColor,
    required this.fontColor,
    this.isArchived = false,
    this.isDeleted = false,
  });
}
