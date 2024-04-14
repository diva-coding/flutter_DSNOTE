import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:my_app/models/folder_model.dart';

class FolderDatabase {
  static Database? _database;
  static const String _tableName = 'folders';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'folders_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE $_tableName(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)',
        );
      },
    );
  }

  Future<void> insertFolder(Folder folder) async {
    final db = await database;
    await db.insert(
      _tableName,
      folder.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Folder>> getFolders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    return List.generate(
      maps.length,
      (i) => Folder(
        id: maps[i]['id'],
        name: maps[i]['name'],
      ),
    );
  }

  Future<void> updateFolder(Folder folder) async {
    final db = await database;
    await db.update(
      _tableName,
      folder.toMap(),
      where: 'id = ?',
      whereArgs: [folder.id],
    );
  }

  Future<void> deleteFolder(int id) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Folder?> getFolderById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Folder(
        id: maps[0]['id'] as int,
        name: maps[0]['name'] as String,
      );
    } else {
      return null;
    }
  }
}