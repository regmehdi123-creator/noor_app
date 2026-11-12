import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../data/models/fatwa_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'noor_fatwa.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorites(
        id INTEGER PRIMARY KEY,
        title TEXT,
        question TEXT,
        answer TEXT,
        source TEXT,
        sourceUrl TEXT,
        category TEXT,
        scholar TEXT,
        addDate TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE cache(
        id INTEGER PRIMARY KEY,
        title TEXT,
        question TEXT,
        answer TEXT,
        source TEXT,
        sourceUrl TEXT,
        category TEXT,
        scholar TEXT,
        addDate TEXT,
        cachedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  // --- Favorites ---

  Future<void> addFavorite(Fatwa fatwa) async {
    final db = await database;
    await db.insert(
      'favorites',
      {
        'id': fatwa.id,
        'title': fatwa.title,
        'question': fatwa.question,
        'answer': fatwa.answer,
        'source': fatwa.source,
        'sourceUrl': fatwa.sourceUrl,
        'category': fatwa.category,
        'scholar': fatwa.scholar,
        'addDate': fatwa.addDate,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFavorite(int id) async {
    final db = await database;
    await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> isFavorite(int id) async {
    final db = await database;
    final maps = await db.query('favorites', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty;
  }

  Future<List<Fatwa>> getFavorites() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favorites');
    return List.generate(maps.length, (i) {
      return Fatwa(
        id: maps[i]['id'],
        title: maps[i]['title'],
        question: maps[i]['question'],
        answer: maps[i]['answer'],
        source: maps[i]['source'],
        sourceUrl: maps[i]['sourceUrl'],
        category: maps[i]['category'],
        scholar: maps[i]['scholar'],
        addDate: maps[i]['addDate'],
      );
    });
  }

  // --- Caching ---

  Future<void> cacheFatwas(List<Fatwa> fatwas) async {
    final db = await database;
    Batch batch = db.batch();
    for (var fatwa in fatwas) {
      batch.insert(
        'cache',
        {
          'id': fatwa.id,
          'title': fatwa.title,
          'question': fatwa.question,
          'answer': fatwa.answer,
          'source': fatwa.source,
          'sourceUrl': fatwa.sourceUrl,
          'category': fatwa.category,
          'scholar': fatwa.scholar,
          'addDate': fatwa.addDate,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Fatwa>> getCachedFatwas() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cache', orderBy: 'cachedAt DESC', limit: 50);
    return List.generate(maps.length, (i) {
      return Fatwa(
        id: maps[i]['id'],
        title: maps[i]['title'],
        question: maps[i]['question'],
        answer: maps[i]['answer'],
        source: maps[i]['source'],
        sourceUrl: maps[i]['sourceUrl'],
        category: maps[i]['category'],
        scholar: maps[i]['scholar'],
        addDate: maps[i]['addDate'],
      );
    });
  }

  Future<void> clearFatwaCache() async {
    final db = await database;
    await db.delete('cache');
  }
}
