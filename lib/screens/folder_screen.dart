import 'package:flutter/material.dart';
import 'package:my_app/models/folder_model.dart';
import 'package:my_app/screens/folder_utils/folder_detail_screen.dart';
import 'package:my_app/services/folder_database.dart';
import 'dart:async';

class FolderScreen extends StatefulWidget {
  const FolderScreen({Key? key}) : super(key: key);

  @override
  _FolderScreenState createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  late List<Folder> folders = [];
  final Set<int> selectedFolders = Set<int>();

  @override
  void initState() {
    super.initState();
    _fetchFolders();
  }

  Future<void> _fetchFolders() async {
    final folderDatabase = FolderDatabase();
    final fetchedFolders = await folderDatabase.getFolders();
    setState(() {
      folders = fetchedFolders;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Folders'),
        actions: [
          if (selectedFolders.length == 1)
            IconButton(
              onPressed: () {
                _editSelectedFolder();
              },
              icon: const Icon(Icons.edit),
            ),
          if (selectedFolders.isNotEmpty)
            Text('${selectedFolders.length} selected'),
          if (selectedFolders.isNotEmpty)
            IconButton(
              onPressed: () {
                _deleteSelectedFolders();
              },
              icon: const Icon(Icons.delete),
            ),
        ],
      ),
      body: folders.isEmpty
          ? const Center(
              child: Text("There's no folder available"),
            )
          : ListView.builder(
              itemCount: folders.length,
              itemBuilder: (context, index) {
                final folder = folders[index];
                return ListTile(
                  title: Text(folder.name),
                  onTap: () {
                    if (selectedFolders.isEmpty) {
                      _navigateToFolderDetailScreen(folder.id!);
                    } else {
                      setState(() {
                        _toggleFolderSelection(folder.id!);
                      });
                    }
                  },
                  onLongPress: () {
                    setState(() {
                      _toggleFolderSelection(folder.id!);
                    });
                  },
                  leading: selectedFolders.contains(folder.id)
                      ? const Icon(Icons.check_circle)
                      : const Icon(Icons.folder),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _showAddFolderDialog(context);
          _fetchFolders();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddFolderDialog(BuildContext context) async {
    final TextEditingController folderNameController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Folder'),
          content: TextField(
            controller: folderNameController,
            decoration: const InputDecoration(
              labelText: 'Folder Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final folderName = folderNameController.text;
                if (folderName.isNotEmpty) {
                  await FolderDatabase().insertFolder(Folder(name: folderName));
                  Navigator.pop(context);
                  _fetchFolders();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToFolderDetailScreen(int folderId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FolderDetailScreen(folderId: folderId),
      ),
    );
  }

  void _editSelectedFolder() async {
    final selectedFolderId = selectedFolders.first;
    final selectedFolder = folders.firstWhere((folder) => folder.id == selectedFolderId);

    final TextEditingController folderNameController = TextEditingController(text: selectedFolder.name);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Folder'),
          content: TextField(
            controller: folderNameController,
            decoration: const InputDecoration(
              labelText: 'Folder Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final folderName = folderNameController.text;
                if (folderName.isNotEmpty) {
                  selectedFolder.name = folderName;
                  await FolderDatabase().updateFolder(selectedFolder);
                  Navigator.pop(context);
                  _fetchFolders();
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _deleteSelectedFolders() async {
    if (selectedFolders.isEmpty) return;

    final confirmed = await _showDeleteConfirmationDialog();
    if (confirmed) {
      for (final folderId in selectedFolders) {
        await FolderDatabase().deleteFolder(folderId);
      }
      setState(() {
        selectedFolders.clear();
      });
      _fetchFolders();
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    Completer<bool> completer = Completer<bool>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete the selected folder(s)?'),
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

  void _toggleFolderSelection(int folderId) {
    if (selectedFolders.contains(folderId)) {
      selectedFolders.remove(folderId);
    } else {
      selectedFolders.add(folderId);
    }
  }
}
