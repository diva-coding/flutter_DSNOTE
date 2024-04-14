import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:my_app/models/note_model.dart';

class DatabaseHelper {
  static Database? _database;
  static const String _tableName = 'notes';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'notes_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          '''CREATE TABLE $_tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            content TEXT,
            modifiedTime TEXT,
            folderId INTEGER,  -- Add folderId column
            FOREIGN KEY (folderId) REFERENCES folders(id) ON DELETE CASCADE  -- Add foreign key constraint
          )''',
        );
      },
    );
  }

  // Insert a Note into the database
  Future<void> insertNote(Note note) async {
    final db = await database;
    await db.insert(
      _tableName,
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch all Notes from the database
  Future<List<Note>> getNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }

  // Update a Note in the database
Future<void> updateNote(Note note) async {
  final db = await database;
  
  // Get the current folder ID of the note
  final currentFolderId = note.folderId;

  // Update the note in the database
  await db.update(
    _tableName,
    note.toMap(),
    where: 'id = ?',
    whereArgs: [note.id],
  );

  // Restore the current folder association of the note
  note.folderId = currentFolderId;
}

  // Delete a Note from the database
  Future<void> deleteNote(int id) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> moveNotesToFolder(List<Note> notes, int folderId) async {
    final db = await database;
    final batch = db.batch();
    for (var note in notes) {
      batch.update(
        _tableName,
        {'folderId': folderId},
        where: 'id = ?',
        whereArgs: [note.id],
      );
    }
    await batch.commit();
  }

  Future<List<Note>> getNotesInFolder(int folderId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'folderId = ?',
      whereArgs: [folderId],
    );
    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }


  // Update folderId of a Note in the database
  Future<void> updateNoteFolder(int noteId, int folderId) async {
    final db = await database;
    await db.update(
      _tableName,
      {'folderId': folderId},
      where: 'id = ?',
      whereArgs: [noteId],
    );
  }

   Future<void> removeNoteFromFolder(int noteId, int folderId) async {
    final db = await database;
    await db.update(
      _tableName,
      {'folderId': null}, // Set folderId to null to remove note from folder
      where: 'id = ? AND folderId = ?',
      whereArgs: [noteId, folderId],
    );
  }
}
