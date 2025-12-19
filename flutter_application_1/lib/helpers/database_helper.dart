import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/diary_entry.dart';

class DatabaseHelper {
  static const _databaseName = "MyDiary.db";
  static const _databaseVersion = 2; 
  static const table = 'diary_entries';
  
  static const columnId = 'id';
  static const columnUserId = 'userId'; 
  static const columnTitle = 'title';
  static const columnContent = 'content';
  static const columnDate = 'date';
  static const columnMood = 'moodIndex';
  static const columnImages = 'imagePaths';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId TEXT PRIMARY KEY,
        $columnUserId TEXT NOT NULL, 
        $columnTitle TEXT NOT NULL,
        $columnContent TEXT NOT NULL,
        $columnDate TEXT NOT NULL,
        $columnMood INTEGER NOT NULL,
        $columnImages TEXT NOT NULL
      )
      ''');
  }

  Future<int> insert(DiaryEntry entry) async {
    Database db = await instance.database;
    return await db.insert(table, {
      columnId: entry.id,
      columnUserId: entry.userId, 
      columnTitle: entry.title,
      columnContent: entry.content,
      columnDate: entry.date.toIso8601String(),
      columnMood: entry.moodIndex,
      columnImages: entry.imagePaths.join(',')
    });
  }

  Future<int> update(DiaryEntry entry) async {
    Database db = await instance.database;
    return await db.update(table, {
        columnTitle: entry.title,
        columnContent: entry.content,
        columnDate: entry.date.toIso8601String(),
        columnMood: entry.moodIndex,
        columnImages: entry.imagePaths.join(','),
      },
      where: '$columnId = ? AND $columnUserId = ?', 
      whereArgs: [entry.id, entry.userId]
    );
  }

  Future<List<DiaryEntry>> getEntriesByUser(String userId) async {
    Database db = await instance.database;
    final maps = await db.query(
      table, 
      where: '$columnUserId = ?', 
      whereArgs: [userId], 
      orderBy: "$columnDate DESC"
    );
    
    return List.generate(maps.length, (i) {
      final imagePathsString = maps[i][columnImages] as String? ?? '';
      final imagePaths = imagePathsString.isEmpty ? <String>[] : imagePathsString.split(',');
      return DiaryEntry(
        id: maps[i][columnId] as String,
        userId: maps[i][columnUserId] as String,
        title: maps[i][columnTitle] as String,
        content: maps[i][columnContent] as String,
        date: DateTime.parse(maps[i][columnDate] as String),
        moodIndex: maps[i][columnMood] as int,
        imagePaths: imagePaths,
      );
    });
  }

  Future<int> delete(String id, String userId) async {
    Database db = await instance.database;
    return await db.delete(
      table, 
      where: '$columnId = ? AND $columnUserId = ?', 
      whereArgs: [id, userId]
    );
  }
}