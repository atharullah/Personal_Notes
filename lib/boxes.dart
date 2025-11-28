import 'package:hive_flutter/hive_flutter.dart';
import 'models/note.dart';

class Boxes {
  static Box<Note> getNotes() => Hive.box<Note>('notesBox');
  static Box<Note> getArchive() => Hive.box<Note>('archiveBox');
  static Box<Note> getTrash() => Hive.box<Note>('trashBox');
}
