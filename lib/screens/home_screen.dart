import 'package:flutter/material.dart';
import 'package:my_app/models/note_model.dart';
import 'dart:async';
import 'package:my_app/services/database_helper.dart';
import 'package:my_app/services/folder_database.dart';
import 'package:intl/intl.dart';
import 'package:my_app/screens/note_utils/note_add_screen.dart';
import 'package:my_app/screens/note_utils/note_detail_screen.dart';
import 'package:my_app/screens/note_utils/note_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Note> notes = [];
  final Set<int> selectedNotes = {};

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    List<Note> fetchedNotes = await DatabaseHelper().getNotes();
    setState(() {
      notes = fetchedNotes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          if (selectedNotes.length == 1)
            IconButton(
              onPressed: () {
                _editSelectedNote();
              },
              icon: const Icon(Icons.edit),
            ),
          if (selectedNotes.isNotEmpty)
            Text('${selectedNotes.length} selected'),
          if (selectedNotes.isNotEmpty)
            IconButton(
              onPressed: () {
                _deleteSelectedNotes();
              },
              icon: const Icon(Icons.delete),
            ),
          if (selectedNotes.isNotEmpty)
            IconButton(
              onPressed: () {
                _moveSelectedNotesToFolder();
              },
              icon: const Icon(Icons.folder),
            ),
        ],
      ),
      body: notes.isEmpty
          ? const Center(
              child: Text("There's no note available"),
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
                    leading: selectedNotes.contains(notes[index].id)
                        ? const Icon(Icons.check_circle)
                        : const Icon(Icons.note),
                    title: Text(notes[index].title),
                    subtitle: Text(
                      DateFormat.yMMMd().format(notes[index].modifiedTime),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNoteScreen(),
            ),
          ).then((_) {
            _fetchNotes();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _toggleNoteSelection(int noteId) {
    if (selectedNotes.contains(noteId)) {
      selectedNotes.remove(noteId);
    } else {
      selectedNotes.add(noteId);
    }
  }

  void _navigateToNoteDetailScreen(Note note) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => NoteDetailScreen(
        note: note,
        onNoteUpdated: () {
          // Perform any necessary actions after the note is updated
          _fetchNotes(); // For example, refresh the notes list
        },
      ),
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
    ).then((_) {
      _fetchNotes();
    });
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
      _fetchNotes();
    }
  }

 Future<bool> _showDeleteConfirmationDialog() {
  Completer<bool> completer = Completer<bool>();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete the selected notes?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              completer.complete(false); // Complete the future with false (cancel)
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              completer.complete(true); // Complete the future with true (delete)
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  return completer.future;
}


  void _moveSelectedNotesToFolder() {
    if (selectedNotes.isEmpty) return;

    FolderDatabase().getFolders().then((folders) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Move to Folder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: folders.map((folder) {
              return ListTile(
                title: Text(folder.name),
                onTap: () {
                  _moveNotesToFolder(selectedNotes.toList(), folder.id!);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        ),
      );
    });
  }

  void _moveNotesToFolder(List<int> noteIds, int folderId) {
    for (final noteId in noteIds) {
      DatabaseHelper().updateNoteFolder(noteId, folderId);
      selectedNotes.remove(noteId);
    }
    _fetchNotes();
  }
}
