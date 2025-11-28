import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';
import '../boxes.dart';
import 'edit_note_screen.dart';
import 'archive_screen.dart';
import 'trash_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text("Menu", style: TextStyle(fontSize: 22)),
            ),
            ListTile(
              leading: const Icon(Icons.note),
              title: const Text("Notes"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.check_box),
              title: const Text("Checklist"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => EditNoteScreen(createChecklist: true)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text("Archive"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ArchiveScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text("Trash"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const TrashScreen()));
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text("Notes", style: TextStyle(fontSize: 20)),
            ),
            const Spacer(),
            SizedBox(
              width: 180,
              child: TextField(
                onChanged: (v) => setState(() => searchText = v.toLowerCase()),
                decoration: InputDecoration(
                  hintText: "Search",
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: Boxes.getNotes().listenable(),
        builder: (context, Box<Note> box, _) {
          final notes = box.values
              .where((n) =>
                  !n.isArchived &&
                  !n.isDeleted &&
                  (n.title.toLowerCase().contains(searchText) ||
                      n.content.toLowerCase().contains(searchText)))
              .toList()
              .cast<Note>();

          if (notes.isEmpty) {
            return const Center(child: Text("No notes found"));
          }

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];

              return Dismissible(
                key: ValueKey(note.key),
                background: Container(
                  color: Colors.green,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  child: const Icon(Icons.archive, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    note.isArchived = true;
                  } else {
                    note.isDeleted = true;
                  }
                  note.save();
                  return true;
                },
                child: Card(
                  margin: const EdgeInsets.all(10),
                  color: Color(note.bgColor),
                  child: ListTile(
                    title: Text(
                      note.title,
                      maxLines: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(note.fontColor),   // APPLY FONT COLOR
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditNoteScreen(note: note),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EditNoteScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
