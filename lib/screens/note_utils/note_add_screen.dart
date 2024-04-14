import 'package:flutter/material.dart';
import 'package:my_app/models/note_model.dart';
import 'package:my_app/services/database_helper.dart';

class AddNoteScreen extends StatefulWidget {
  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          controller: _scrollController,
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
                onChanged: (_) {
                  // Scroll to the end of the content while typing
                  _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                },
                decoration: const InputDecoration(
                  labelText: 'Content',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Save note to database
                  DatabaseHelper().insertNote(
                    Note(
                      title: titleController.text,
                      content: contentController.text,
                      modifiedTime: DateTime.now(),
                    ),
                  );
                  // Navigate back to home screen
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
