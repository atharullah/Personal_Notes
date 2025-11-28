import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';
import '../boxes.dart';

class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trash")),
      body: ValueListenableBuilder(
        valueListenable: Boxes.getNotes().listenable(),
        builder: (context, Box<Note> box, _) {
          final deleted = box.values.where((n) => n.isDeleted).toList();

          if (deleted.isEmpty) {
            return const Center(child: Text("Trash is empty"));
          }

          return ListView.builder(
            itemCount: deleted.length,
            itemBuilder: (context, index) {
              final note = deleted[index];

              return Dismissible(
                key: ValueKey(note.key),
                background: Container(
                  color: Colors.green,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  child: const Icon(Icons.restore, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete_forever, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    note.isDeleted = false;
                    note.save();
                    return true;
                  } else {
                    await note.delete();
                    return true;
                  }
                },
                child: Card(
                  color: Color(note.bgColor),
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(note.title),
                    subtitle: Text(note.content, maxLines: 2),
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
