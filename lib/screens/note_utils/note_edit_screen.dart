import 'package:flutter/material.dart';
import 'package:my_app/models/note_model.dart';
import 'package:my_app/services/database_helper.dart';
import 'package:my_app/main.dart';

class EditNoteScreen extends StatelessWidget {
  final Note note;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  EditNoteScreen({Key? key, required this.note}) : super(key: key) {
    titleController.text = note.title;
    contentController.text = note.content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Note'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: 'Content',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  // Get the current folderId before updating the note
                  int currentFolderId = note.folderId!;

                  // Update note in the database
                  Note updatedNote = Note(
                    id: note.id,
                    title: titleController.text,
                    content: contentController.text,
                    modifiedTime: DateTime.now(),
                    folderId: currentFolderId, // Restore the current folderId
                  );
                  await DatabaseHelper().updateNote(updatedNote);
                  
                  // Navigate directly to the initial route '/' and remove all other routes from the stack
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MyHomePage(title: "Home Screen")),
                    ModalRoute.withName(Navigator.defaultRouteName),
                  );
                },
                child: const Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
