import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/models/note_model.dart';
import 'package:my_app/screens/note_utils/note_edit_screen.dart';
import 'package:my_app/services/database_helper.dart';
import 'package:my_app/services/folder_database.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note note;
  final Function() onNoteUpdated; // Callback function to notify parent widget

  const NoteDetailScreen({Key? key, required this.note, required this.onNoteUpdated})
      : super(key: key);

  @override
  _NoteDetailScreenState createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late Future<String?> _folderNameFuture;

  @override
  void initState() {
    super.initState();
    _folderNameFuture = _fetchFolderName(widget.note.folderId ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.note.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat.yMMMd().format(widget.note.modifiedTime),
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.note.content,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<String?>(
              future: _folderNameFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final folderName = snapshot.data ?? 'None';
                  return Text(
                    'Folder: $folderName',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditNoteScreen(note: widget.note),
                      ),
                    ).then((_) {
                      // Call the callback function to notify parent widget of the update
                      widget.onNoteUpdated();
                    });
                  },
                  child: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    DatabaseHelper().deleteNote(widget.note.id!);
                    // Call the callback function to notify parent widget of the update
                    widget.onNoteUpdated();
                    Navigator.pop(context);
                  },
                  child: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _fetchFolderName(int folderId) async {
    final folder = await FolderDatabase().getFolderById(folderId);
    return folder?.name;
  }
}
