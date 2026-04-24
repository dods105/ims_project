import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import '../models/login/user.dart';
import '../models/products/products.dart';
import 'package:intl/intl.dart';

class DatabaseHelper {
  // Hash password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  //all about database
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
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL UNIQUE,
        quantity INTEGER NOT NULL DEFAULT 0,
        selling_price REAL NOT NULL,
        original_price REAL,
        product_type TEXT,
        expiry_date TEXT,
        barcode TEXT,
        description TEXT,
        FOREIGN KEY(user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        user_id INTEGER NOT NULL,
        customer_name TEXT,
        customer_address TEXT,
        total_amount REAL NOT NULL,
        amount_payed REAL NOT NULL,
        change_amount REAL NOT NULL,
        transacted_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE transaction_items (
        id INTEGER PRIMARY KEY,
        transaction_id TEXT NOT NULL,
        products_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        barcode TEXT,
        unit_price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (transaction_id) REFERENCES transactions(id),
        FOREIGN KEY (products_id) REFERENCES products(id)
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

  // ALL ABOUT TRANSACTIONS
  // num of trans by the hour
  Future<int> getTransactionCount(Database db, userId, DateTime now) async {
    final String hour = DateFormat("yyyy-MM-dd'T'HH").format(now);

    final result = await db.rawQuery(
      '''
      SELECT COUNT (*) as count
      FROM transactions
      WHERE user_id = ?
      AND transacted_at LIKE ?
    ''',
      [userId, '$hour%'],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<String> generateTransactionId(int userId) async {
    DateTime now = DateTime.now();
    final db = await instance.database;
    final String date = DateFormat('yyyyMMdd').format(now);

    final int hour12 = now.hour % 12 == 0 ? 12 : now.hour % 12;

    final String letter = String.fromCharCode(64 + hour12);

    final String period = now.hour < 12 ? 'AM' : 'PM';

    final int count = await getTransactionCount(db, userId, now);
    final String sequence = (count + 1).toString().padLeft(3, '0');

    return '$date[2]$date[3]-$hour12-$letter$period-$sequence';
  }
}
