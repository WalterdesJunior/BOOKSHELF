import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/article_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'bookshelf.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE saved_articles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        url TEXT NOT NULL UNIQUE,
        image_url TEXT,
        source TEXT,
        published_at TEXT,
        category TEXT,
        is_read INTEGER DEFAULT 0,
        is_saved INTEGER DEFAULT 1
      )
    ''');
  }

  // ─── USUÁRIOS ────────────────────────────────────────────────

  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  Future<bool> emailExists(String email) async {
    final user = await getUserByEmail(email);
    return user != null;
  }

  // ─── ARTIGOS SALVOS ──────────────────────────────────────────

  Future<int> saveArticle(ArticleModel article) async {
    final db = await database;
    final map = article.toMap();
    map.remove('id');
    map['is_saved'] = 1;
    return await db.insert('saved_articles', map,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> deleteArticle(String url) async {
    final db = await database;
    return await db
        .delete('saved_articles', where: 'url = ?', whereArgs: [url]);
  }

  Future<List<ArticleModel>> getSavedArticles() async {
    final db = await database;
    final result = await db.query('saved_articles',
        orderBy: 'is_read ASC, id DESC');
    return result.map((m) => ArticleModel.fromMap(m)).toList();
  }

  Future<bool> isArticleSaved(String url) async {
    final db = await database;
    final result = await db.query('saved_articles',
        where: 'url = ?', whereArgs: [url], limit: 1);
    return result.isNotEmpty;
  }

  Future<int> markAsRead(String url, bool isRead) async {
    final db = await database;
    return await db.update(
      'saved_articles',
      {'is_read': isRead ? 1 : 0},
      where: 'url = ?',
      whereArgs: [url],
    );
  }
}
