import 'package:flutter/material.dart';
import 'package:my_app/models/note_model.dart';
import 'package:my_app/screens/note_utils/note_detail_screen.dart';
import 'package:my_app/screens/note_utils/note_edit_screen.dart';
import 'package:my_app/services/database_helper.dart';
import 'package:intl/intl.dart'; // Import DateFormat for date formatting

class FolderDetailScreen extends StatefulWidget {
  final int folderId;

  const FolderDetailScreen({Key? key, required this.folderId}) : super(key: key);

  @override
  _FolderDetailScreenState createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen> {
  late List<Note> notes = [];
  final Set<int> selectedNotes = Set<int>();

  @override
  void initState() {
    super.initState();
    _fetchNotesInFolder();
  }

  Future<void> _fetchNotesInFolder() async {
    final List<Note> fetchedNotes = await DatabaseHelper().getNotesInFolder(widget.folderId);
    setState(() {
      notes = fetchedNotes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: selectedNotes.isEmpty ? const Text('Folder Notes') : Text('${selectedNotes.length} selected'),
        actions: [
          if (selectedNotes.length == 1)
            IconButton(
              onPressed: _editSelectedNote,
              icon: const Icon(Icons.edit),
            ),
          if (selectedNotes.isNotEmpty)
            IconButton(
              onPressed: _deleteSelectedNotes,
              icon: const Icon(Icons.delete),
            ),
          if (selectedNotes.isNotEmpty)
            IconButton(
              onPressed: _removeSelectedNotesFromFolder,
              icon: const Icon(Icons.arrow_upward),
            ),
        ],
      ),
      body: notes.isEmpty
          ? const Center(
              child: Text("There's no note available in this folder"),
            )
          : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    if (selectedNotes.isEmpty) {
                      _navigateToNoteDetailScreen(notes[index]);
                    } else {
                      setState(() {
                        _toggleNoteSelection(notes[index].id!);
                      });
                    }
                  },
                  onLongPress: () {
                    setState(() {
                      _toggleNoteSelection(notes[index].id!);
                    });
                  },
                 child: ListTile(
                    leading: const Icon(Icons.note), // Add an icon before the note name
                    title: Text(notes[index].title),
                    subtitle: Text(DateFormat.yMMMd().format(notes[index].modifiedTime)),
                  ),
                );
              },
            ),
    );
  }

  void _toggleNoteSelection(int noteId) {
    if (selectedNotes.contains(noteId)) {
      selectedNotes.remove(noteId);
    } else {
      selectedNotes.add(noteId);
    }
    setState(() {});
  }

  void _navigateToNoteDetailScreen(Note note) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => NoteDetailScreen(note: note, onNoteUpdated: _fetchNotesInFolder),
    ),
  );
}

  void _editSelectedNote() {
  if (selectedNotes.length != 1) return;

  final selectedNoteId = selectedNotes.first;
  final selectedNote = notes.firstWhere((note) => note.id == selectedNoteId);

  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNoteScreen(note: selectedNote),
      ),
    );
  }


  void _deleteSelectedNotes() async {
    if (selectedNotes.isEmpty) return;

    final confirmed = await _showDeleteConfirmationDialog();
    if (confirmed) {
      for (final noteId in selectedNotes) {
        await DatabaseHelper().deleteNote(noteId);
      }
      setState(() {
        selectedNotes.clear();
      });
      _fetchNotesInFolder();
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete the selected notes?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _removeSelectedNotesFromFolder() async {
    if (selectedNotes.isEmpty) return;

    final confirmed = await _showRemoveFromFolderConfirmationDialog();
    if (confirmed) {
      for (final noteId in selectedNotes) {
        await DatabaseHelper().removeNoteFromFolder(noteId, widget.folderId);
      }
      setState(() {
        selectedNotes.clear();
      });
      _fetchNotesInFolder();
    }
  }

  Future<bool> _showRemoveFromFolderConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Removal'),
          content: const Text('Are you sure you want to remove the selected notes from this folder?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }
}
