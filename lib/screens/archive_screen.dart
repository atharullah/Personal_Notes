import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';
import '../boxes.dart';
import 'edit_note_screen.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Archive")),
      body: ValueListenableBuilder(
        valueListenable: Boxes.getNotes().listenable(),
        builder: (context, Box<Note> box, _) {
          final archived = box.values.where((n) => n.isArchived).toList();

          if (archived.isEmpty) {
            return const Center(child: Text("No archived notes"));
          }

          return ListView.builder(
            itemCount: archived.length,
            itemBuilder: (context, index) {
              final note = archived[index];

              return Dismissible(
                key: ValueKey(note.key),
                background: Container(
                  color: Colors.orange,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  child: const Icon(Icons.unarchive, color: Colors.white),
                ),
                onDismissed: (_) {
                  note.isArchived = false;
                  note.save();
                },
                child: Card(
                  color: Color(note.bgColor),
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                      note.title,
                      maxLines: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(note.fontColor),   // APPLY FONT COLOR
                      ),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditNoteScreen(note: note),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
