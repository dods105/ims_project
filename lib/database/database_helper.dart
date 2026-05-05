import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import '../models/login/user.dart';
import '../models/products/products.dart';
import 'package:intl/intl.dart';
import '../models/products/expired_product.dart';
import '../models/notifications/notification_model.dart';

class DatabaseHelper {
  //all about database

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
        image_path TEXT,
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
      CREATE TABLE expired_products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        selling_price REAL NOT NULL,
        original_price REAL,
        product_type TEXT,
        expiry_date TEXT NOT NULL,
        description TEXT,
        image_path TEXT,
        moved_at TEXT NOT NULL,
        FOREIGN KEY(user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        product_id INTEGER,
        product_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        expiry_date TEXT NOT NULL,
        type TEXT NOT NULL,
        is_read INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY(user_id) REFERENCES users(id)
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

  // Hash password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // checks login credentials
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

  //checks if user exists when logging in
  Future<bool> usernameExists(String username) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty;
  }

  //creates a new user
  Future<User> createUser(User user) async {
    final db = await instance.database;
    final hashedPassword = _hashPassword(user.password);
    final newUser = User(username: user.username, password: hashedPassword);
    final id = await db.insert('users', newUser.toMap());
    return User(id: id, username: user.username, password: hashedPassword);
  }

  Future<User> editUsername(int id, String newUsername) async {
    final db = await instance.database;
    await db.update(
      'users',
      {'username': newUsername},
      where: 'id = ?',
      whereArgs: [id],
    );
    return User(id: id, username: newUsername, password: '');
  }

  Future<User> editPassword(int id, String newPassword) async {
    final db = await instance.database;
    final hashedPassword = _hashPassword(newPassword);
    await db.update(
      'users',
      {'password': hashedPassword},
      where: 'id = ?',
      whereArgs: [id],
    );
    return User(id: id, username: '', password: hashedPassword);
  }

  // all about products

  //creates a new product
  //problem: now logic that says if the product name already exists,
  //it will just create a new product with the same name.
  //We need to add logic that checks if the product name already exists for the user,
  //if it does, we update the quantity and selling price instead of creating a new product.

  // for adding prod only (Adding page)
  Future<void> insertOrUpdateProduct(Product product) async {
    final db = await instance.database;
    List<Map<String, dynamic>> existing;

    if (product.expiryDate == null || product.expiryDate!.isEmpty) {
      // No expiry
      existing = await db.query(
        'products',
        where:
            'user_id = ? AND name = ? AND (expiry_date IS NULL or expiry_date = "")',
        whereArgs: [product.userId, product.name],
      );
    } else {
      // same expiry date
      existing = await db.query(
        'products',
        where: 'user_id = ? AND name = ? AND expiry_date = ?',
        whereArgs: [product.userId, product.name, product.expiryDate],
      );
    }

    if (existing.isNotEmpty) {
      // same prod info exists (update only prices or quantity)
      final existingId = existing.first['id'] as int; // prod id
      final existingStock = existing.first['quantity'] as int;

      await db.update(
        'products',
        {
          'quantity': existingStock + product.quantity,
          'selling_price': product.sellingPrice,
          'original_price': product.originalPrice,
        },
        where: 'id = ?',
        whereArgs: [existingId],
      );
    } else {
      // new product
      await db.insert('products', product.toMap());
    }
  }

  // for editing a product info ?????????????
  Future<Product?> getExistingProduct(Product product) async {
    final db = await instance.database;
    List<Map<String, dynamic>> existing;

    if (product.expiryDate == null || product.expiryDate == "") {
      existing = await db.query(
        'products',
        where:
            'user_id = ? AND name = ? AND (expiry_date IS NULL OR expiry_date = "")',
        whereArgs: [product.userId, product.name],
      );
    } else {
      existing = await db.query(
        'products',
        where: 'user_id = ? AND name = ? AND expiry_date = ?',
        whereArgs: [product.userId, product.name, product.expiryDate],
      );
    }

    if (existing.isNotEmpty) {
      return Product.fromMap(existing.first);
    }

    return null;
  }

  // get user products
  Future<List<Product>> getProductsByUser(int userId) async {
    final db = await instance.database;

    final result = await db.query(
      'products',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return result.map((product) => Product.fromMap(product)).toList();
  }

  /*Future<int> insertProduct(Product product) async {
    final db = await instance.database;
    return await db.insert('products', product.toMap());
  }*/

  Future<int> deleteProduct(int id) async {
    final db = await instance.database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  //to implement:
  //update product, get product by user id, get product by product id
  // logic for the multiple expiry date of the same product name is to
  //just create a new product with the same name but different expiry date?????
  Future<int> updateProduct(Product product) async {
    final db = await instance.database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  //  EXPIRED PRODUCTS

  Future<int> insertExpiredProduct(ExpiredProduct product) async {
    final db = await instance.database;
    return await db.insert('expired_products', product.toMap());
  }

  Future<List<ExpiredProduct>> getExpiredProductByUSer(int userId) async {
    final db = await instance.database;
    final productsExpired = await db.query(
      'expired_products',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'moved_at DESC',
    );
    return productsExpired
        .map((product) => ExpiredProduct.fromMap(product))
        .toList();
  }

  // delete expired product and all notif of product
  Future<void> deleteExpiredProduct(int id) async {
    final db = await instance.database;
    final expiredProduct = await db.query(
      'expired_products',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (expiredProduct.isNotEmpty) {
      final name = expiredProduct.first['name'];
      final expiryDate = expiredProduct.first['expiry_date'];
      final userId = expiredProduct.first['user_id'];
      // delete all notif about the product
      await db.delete(
        'notifications',
        where: 'user_id = ? AND expiry_date = ? AND product_name = ?',
        whereArgs: [userId, expiryDate, name],
      );
    }
    // del the expired prod
    await db.delete('expired_products', where: 'id = ?', whereArgs: [id]);
  }

  // Notifications

  Future<int> insertNotification(AppNotification notif) async {
    final db = await instance.database;
    return await db.insert('notifications', notif.toMap());
  }

  Future<List<AppNotification>> getNotifications(int userId) async {
    final db = await instance.database;
    final notifs = await db.query(
      'notifications',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return notifs.map((notif) => AppNotification.fromMap(notif)).toList();
  }

  Future<void> deleteNotification(int id) async {
    final db = await instance.database;
    await db.delete('notifications', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markNotificationRead(int id) async {
    final db = await database;
    await db.update(
      'notifications',
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> checkAndProcessExpiry(int userId) async {
    final db = await database;
    final today = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(today);
    final in7Days = DateFormat(
      'yyyy-MM-dd',
    ).format(today.add(const Duration(days: 7)));
    final now = today.toIso8601String();

    // expired products
    final expired = await db.query(
      'products',
      where:
          'user_id = ? AND expiry_date IS NOT NULL AND expiry_date != "" AND expiry_date <= ?',
      whereArgs: [userId, todayStr],
    );

    // Expired Items
    for (final p in expired) {
      // Move product to expired_products
      await db.insert('expired_products', {
        'user_id': p['user_id'],
        'name': p['name'],
        'quantity': p['quantity'],
        'selling_price': p['selling_price'],
        'original_price': p['original_price'],
        'product_type': p['product_type'],
        'expiry_date': p['expiry_date'],
        'description': p['description'],
        'image_path': p['image_path'],
        'moved_at': todayStr,
      });

      // search notif table
      final alreadyNotified = await db.query(
        'notifications',
        where:
            "user_id = ? AND product_name = ? AND expiry_date = ? AND type = 'expired'",
        whereArgs: [userId, p['name'], p['expiry_date']],
      );
      if (alreadyNotified.isEmpty) {
        // create notif if doesnt exist yet
        await db.insert('notifications', {
          'user_id': userId,
          'product_id': p['id'],
          'product_name': p['name'],
          'quantity': p['quantity'],
          'expiry_date': p['expiry_date'],
          'type': 'expired',
          'is_read': 0,
          'created_at': now,
        });
      }

      // Remove from inventory
      await db.delete('products', where: 'id = ?', whereArgs: [p['id']]);
    }

    //  Find products expiring in 1 week
    final expiringSoon = await db.query(
      'products',
      where:
          'user_id = ? AND expiry_date IS NOT NULL AND expiry_date != "" AND expiry_date > ? AND expiry_date <= ?',
      whereArgs: [userId, todayStr, in7Days],
    );

    for (final p in expiringSoon) {
      final alreadyNotified = await db.query(
        'notifications',
        where:
            "user_id = ? AND product_name = ? AND expiry_date = ? AND type = 'expiringSoon'",
        whereArgs: [userId, p['name'], p['expiry_date']],
      );
      if (alreadyNotified.isEmpty) {
        await db.insert('notifications', {
          'user_id': userId,
          'product_id': p['id'],
          'product_name': p['name'],
          'quantity': p['quantity'],
          'expiry_date': p['expiry_date'],
          'type': 'expiringSoon',
          'is_read': 0,
          'created_at': now,
        });
      }
    }
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

  //for generating transaction id (use this gian)
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
