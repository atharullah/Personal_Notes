// Updated Flutter notebook-style note editor based on your existing code.
// Added: notebook horizontal lines, removed content hint, auto-title from first line,
// moved title into AppBar, full notebook background, kept all functionality.

import 'package:flutter/material.dart';
import '../models/note.dart';
import '../boxes.dart';

// ignore: must_be_immutable
class EditNoteScreen extends StatefulWidget {
  Note? note;
  final bool createChecklist;

  EditNoteScreen({super.key, this.note, this.createChecklist = false});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final titleCtrl = TextEditingController();
  final contentCtrl = TextEditingController();
  int selectedColor = Colors.yellow.toARGB32();
  Color fontColor = Colors.black;

  final colors = [
    Colors.yellow,
    Colors.green,
    Colors.pink,
    Colors.lightBlue,
    Colors.orange,
    Colors.purple,
    Colors.black,
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();

    if (widget.note != null) {
      titleCtrl.text = widget.note!.title;
      contentCtrl.text = widget.note!.content;
      selectedColor = widget.note!.bgColor;
      fontColor = Color(widget.note!.fontColor);
    }

    _updateFontColor();

    contentCtrl.addListener(() {
       _autoSave();
      _updateTitleFromFirstLine();
    });

    titleCtrl.addListener(_autoSave);
    _updateTitleFromFirstLine();
  }

  void _updateTitleFromFirstLine() {

    final text = contentCtrl.text.trim();
    if (text.isEmpty) {
      // Clear title when content is empty
      if (titleCtrl.text.isNotEmpty) {
        titleCtrl.value = titleCtrl.value.copyWith(
          text: '',
          selection: const TextSelection.collapsed(offset: 0),
          composing: TextRange.empty,
        );
        setState(() {}); // rebuild AppBar
      }
      return;
    }

    final firstLine = text.split("\n").first;
    final newTitle =
      firstLine.length > 50 ? firstLine.substring(0, 50) : firstLine;

    // Avoid cursor jump — update only if title actually changed
    if (titleCtrl.text != newTitle) {
      titleCtrl.value = titleCtrl.value.copyWith(
        text: newTitle,
        selection: TextSelection.collapsed(offset: newTitle.length),
        composing: TextRange.empty,
      );
      setState(() {}); // this rebuilds AppBar title live
    }
  }

  void _autoSave() {
    final text = contentCtrl.text.trim();
    if (text.isEmpty) {
      // If note exists in Hive, delete it
      if (widget.note != null) {
        widget.note!.delete();
        widget.note = null;
      }
      return; // don't save anything
    }

    final box = Boxes.getNotes();

    String title = titleCtrl.text.trim();
    if (title.isEmpty && contentCtrl.text.trim().isNotEmpty) {
      final firstLine = contentCtrl.text.trim().split("\n").first;

      title = firstLine.length > 50 ? firstLine.substring(0, 50) : firstLine;
    }

    if (widget.note == null) {
      final newNote = Note(
        title: title,
        content: contentCtrl.text,
        bgColor: selectedColor,
        fontColor: fontColor.toARGB32()
      );
      box.add(newNote);
      widget.note = newNote;
    } else {
      widget.note!
        ..title = title
        ..content = contentCtrl.text
        ..bgColor = selectedColor
        ..fontColor = fontColor.toARGB32()
        ..save();
    }
  }

  void _updateFontColor() {
    final color = Color(selectedColor);
    final brightness = ThemeData.estimateBrightnessForColor(color);

    fontColor = brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(selectedColor),
      appBar: AppBar(
        backgroundColor: Color(selectedColor),
        iconTheme: IconThemeData(color: fontColor),
        title: Text(
          titleCtrl.text.isEmpty ? "New Note" : titleCtrl.text,
          style: TextStyle(color: fontColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: CustomPaint(
        painter: NotebookLinesPainter(fontColor: fontColor),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Expanded(
                child: TextField(
                  controller: contentCtrl,
                  style: TextStyle(color: fontColor, fontSize: 18, height: 1.6),
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '',
                  ),
                ),
              ),
              Wrap(
                spacing: 10,
                children: colors.map((c) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedColor = c.toARGB32();
                        _updateFontColor();
                        widget.note?.fontColor = fontColor.toARGB32();
                        _autoSave();
                      });
                    },
                    child: CircleAvatar(
                      backgroundColor: c,
                      radius: 20,
                      child: selectedColor == c.toARGB32()
                          ? Icon(Icons.check,
                              color: ThemeData.estimateBrightnessForColor(c) ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black)
                          : null,
                    ),
                  );
                }).toList(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class NotebookLinesPainter extends CustomPainter {
  final Color fontColor;
  NotebookLinesPainter({required this.fontColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = fontColor.withValues(alpha: (0.15 * 255))
      ..strokeWidth = 1;

    const double lineHeight = 32;

    for (double y = 0; y < size.height; y += lineHeight) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
