import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'book_model.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_registro_books.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        isbn TEXT NOT NULL,
        year INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertBook(Book book) async {
    final db = await instance.database;
    return await db.insert('books', book.toMap());
  }

  Future<List<Book>> getBooks() async {
    final db = await instance.database;
    final result = await db.query('books', orderBy: 'id DESC');
    return result.map((json) => Book.fromMap(json)).toList();
  }

  Future<int> deleteBook(int id) async {
    final db = await instance.database;
    return await db.delete('books', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}