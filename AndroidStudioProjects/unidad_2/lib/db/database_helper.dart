import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/producto.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'inventario.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE productos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            categoria TEXT NOT NULL,
            precio REAL NOT NULL,
            cantidad INTEGER NOT NULL,
            emailProveedor TEXT NOT NULL,
            fechaIngreso TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertar(Producto producto) async {
    final db = await database;
    return await db.insert('productos', producto.toMap());
  }

  Future<int> eliminar(int id) async {
    final db = await database;
    return await db.delete('productos', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Producto>> obtenerTodos() async {
    final db = await database;
    final maps = await db.query('productos', orderBy: 'nombre ASC');
    return maps.map((m) => Producto.fromMap(m)).toList();
  }

  Future<List<Producto>> filtrarPorCategoria(String categoria) async {
    final db = await database;
    final maps = await db.query(
      'productos',
      where: 'categoria LIKE ?',
      whereArgs: ['%$categoria%'],
      orderBy: 'nombre ASC',
    );
    return maps.map((m) => Producto.fromMap(m)).toList();
  }
}