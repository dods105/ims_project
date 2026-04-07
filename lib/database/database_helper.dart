import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import '../models/login/user.dart';
import '../models/products/products.dart';

class DatabaseHelper {
  // Hash password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  //aall about data base
  //------------------------------------------------------

  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // get database or initialize if not created yet
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('inventory.db');
    return _database!;
  }

  Future<Database> _initDB(String dbName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        quantity INTEGER NOT NULL,
        selling_price INTEGER NOT NULL,
        original_price INTEGER NOT NULL,
        product_type TEXT,
        expiry_date TEXT,
        barcode TEXT,
        user_id INTEGER NOT NULL,
        FOREIGN KEY(user_id) REFERENCES users(id)
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  // all about user
  //--------------------------------------------------------

  Future<User?> checkUser(String username, String password) async {
    final db = await instance.database;
    final hashedPassword = _hashPassword(password);
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, hashedPassword],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<bool> usernameExists(String username) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty;
  }

  Future<User> createUser(User user) async {
    final db = await instance.database;
    final hashedPassword = _hashPassword(user.password);
    final userWithHashedPassword = User(
      username: user.username,
      password: hashedPassword,
    );
    final id = await db.insert('users', userWithHashedPassword.toMap());
    print('user: ${user.username} now created');
    return User(id: id, username: user.username, password: hashedPassword);
  }

  // all about products
  //--------------------------------------------------------

  Future<int> insertProduct(Product product) async {
    final db = await instance.database;
    return await db.insert('products', product.toMap());
  }

  Future<int> deleteProduct(int id) async {
    final db = await instance.database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateProduct(Product product) async {
    final db = await instance.database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<List<Product>> getProductsByUser(int userId) async {
    final db = await instance.database;

    final result = await db.query(
      'products',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return result.map((e) => Product.fromMap(e)).toList();
  }
}
