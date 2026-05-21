import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import '../models/login/user.dart';
import '../models/products/products.dart';
import 'package:intl/intl.dart';
import '../models/products/expired_product.dart';
import '../models/notifications/notification_model.dart';
import '../models/purchase/transaction_sale.dart';
import '../models/purchase/transaction_items.dart';

// Thrown by DatabaseHelper.checkoutTransactio when the requested quantity
//for a product is more than the available stock at checkout.
class InsufficientStockException implements Exception {
  final String productName;
  final int requested;
  final int available;

  const InsufficientStockException(
    this.productName, {
    required this.requested,
    required this.available,
  });

  @override
  String toString() =>
      'InsufficientStockException: "$productName" requested is $requested but only $available are in stock.';
}

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
        password TEXT NOT NULL,
        profile_pic TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
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
        created_at TEXT NOT NULL,
        FOREIGN KEY(user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE transaction_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id TEXT NOT NULL,
        products_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        barcode TEXT,
        unit_price REAL NOT NULL,
        original_price REAL,
        quantity INTEGER NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (transaction_id) REFERENCES transactions(id),
        FOREIGN KEY (products_id) REFERENCES products(id)
      )
    ''');

    await db.execute('''
    CREATE TABLE categories (
      id INTEGER PRIMARY KEY,
      user_id INTEGER,
      category_name TEXT NOT NULL,
      FOREIGN KEY(user_id) REFERENCES users(id)
    )
  ''');

    /*List<String> types = [
      "DRINKS",
      "FROZEN FOODS",
      "CANNED GOODS",
      "BAKERY",
      "BISCUITS",
      "SNACKS",
      'TOILETRIES',
      'CLEANING SUPPLIES',
    ];

    for (String type in types) {
      await db.insert('categories', {'user_id': null, 'catergory_name': type});
    }*/
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

  Future<String?> getProfilePicById(int userId) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      columns: ['profile_pic'],
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return result.first['profile_pic'] as String?;
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

  Future<void> editPassword(int id, String newPassword) async {
    final db = await instance.database;
    final hashedPassword = _hashPassword(newPassword);
    await db.update(
      'users',
      {'password': hashedPassword},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //Saves a profile picture path to the users table.
  Future<void> saveProfilePic(int userId, String path) async {
    final db = await instance.database;
    await db.update(
      'users',
      {'profile_pic': path},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  //retrieves the stored profile picture path, or null if none set.
  Future<String?> getProfilePic(int userId) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      columns: ['profile_pic'],
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return result.first['profile_pic'] as String?;
  }

  //all about products

  Future<List<String>> getCategoryNames(int userId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'categories',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'category_name ASC',
    );

    return result.map((map) => map['category_name'] as String).toList();
  }

  Future<void> insertCustomCategory(int userId, String categoryName) async {
    final db = await instance.database;

    // Check if it already exists globally or for this specific user
    final existing = await db.query(
      'categories',
      where: '(user_id = ? OR user_id IS NULL) AND UPPER(category_name) = ?',
      whereArgs: [userId, categoryName.trim()],
    );

    if (existing.isEmpty) {
      await db.insert('categories', {
        'user_id': userId,
        'category_name': categoryName.trim(),
      });
    }
  }

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
    // Remove any notifications related to this product before deleting it,
    await db.delete('notifications', where: 'product_id = ?', whereArgs: [id]);
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

  // ascending true = oldest first, false = newest first.
  Future<List<AppNotification>> getNotifications(
    int userId, {
    bool ascending = false,
  }) async {
    final db = await instance.database;
    final result = await db.query(
      'notifications',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at ${ascending ? 'ASC' : 'DESC'}',
    );
    return result.map((n) => AppNotification.fromMap(n)).toList();
  }

  //Deletes a notification.
  //If type is expired. Also delete the matching expired_product row.
  //If type is outOfStock. Also delete the matching product row.
  Future<void> deleteNotification(int id) async {
    final db = await instance.database;

    final rows = await db.query(
      'notifications',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isNotEmpty) {
      final row = rows.first;
      final type = row['type'] as String?;
      final productId = row['product_id'];
      final productName = row['product_name'];
      final expiryDate = row['expiry_date'];
      final userId = row['user_id'];

      if (type == 'expired') {
        await db.delete(
          'expired_products',
          where: 'user_id = ? AND name = ? AND expiry_date = ?',
          whereArgs: [userId, productName, expiryDate],
        );
      } else if (type == 'outOfStock' && productId != null) {
        await db.delete(
          'products',
          where: 'id = ? AND quantity = 0',
          whereArgs: [productId],
        );
      }
    }

    await db.delete('notifications', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> checkAndProcessExpiry(int userId) async {
    final db = await database;
    final nowFull = DateTime.now();
    // Midnight today — all comparisons are date-only, no time component.
    final today = DateTime(nowFull.year, nowFull.month, nowFull.day);
    final in7Days = today.add(const Duration(days: 7));
    final nowIso = nowFull.toIso8601String();
    final todayStr = DateFormat('MM-dd-yyyy').format(today);

    // Fetch every product that has an expiry date.
    final allWithExpiry = await db.query(
      'products',
      where: "user_id = ? AND expiry_date IS NOT NULL AND expiry_date != ''",
      whereArgs: [userId],
    );

    final List<Map<String, dynamic>> expiredProducts = [];
    final List<Map<String, dynamic>> expiringSoonProducts = [];

    for (final p in allWithExpiry) {
      final raw = p['expiry_date'] as String? ?? '';
      DateTime expiry;
      try {
        final parsed = DateFormat('MM-dd-yyyy').parse(raw);
        expiry = DateTime(parsed.year, parsed.month, parsed.day);
      } catch (_) {
        continue;
      }

      if (expiry.isBefore(today)) {
        expiredProducts.add(p);
      } else if (!expiry.isAfter(in7Days)) {
        expiringSoonProducts.add(p);
      }
    }

    //process expired products
    for (final p in expiredProducts) {
      // only add into expired_products if not already there.
      final alreadyMoved = await db.query(
        'expired_products',
        columns: ['id'],
        where: 'user_id = ? AND name = ? AND expiry_date = ?',
        whereArgs: [p['user_id'], p['name'], p['expiry_date']],
        limit: 1,
      );

      if (alreadyMoved.isEmpty) {
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
      }

      //insert an 'expired' notification if one doesn't exist yet.
      final alreadyNotified = await db.query(
        'notifications',
        where:
            "user_id = ? AND product_name = ? AND expiry_date = ? AND type = 'expired'",
        whereArgs: [userId, p['name'], p['expiry_date']],
      );
      if (alreadyNotified.isEmpty) {
        await db.insert('notifications', {
          'user_id': userId,
          'product_id': p['id'],
          'product_name': p['name'],
          'quantity': p['quantity'],
          'expiry_date': p['expiry_date'],
          'type': 'expired',
          'created_at': nowIso,
        });
      }

      // Remove from live inventory.
      await db.delete('products', where: 'id = ?', whereArgs: [p['id']]);
    }

    // Process expiring-soon products
    for (final p in expiringSoonProducts) {
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
          'created_at': nowIso,
        });
      }
    }

    // low-stock and out-of-stock
    final allProducts = await db.query(
      'products',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    for (final p in allProducts) {
      final qty = p['quantity'] as int;
      final productId = p['id'] as int;
      final name = p['name'] as String;
      const noExpiry = 'N/A';

      if (qty == 0) {
        // Out of stock notify once
        ////re-notify if the previous one was deleted
        final existing = await db.query(
          'notifications',
          where: "user_id = ? AND product_id = ? AND type = 'outOfStock'",
          whereArgs: [userId, productId],
        );
        if (existing.isEmpty) {
          await db.insert('notifications', {
            'user_id': userId,
            'product_id': productId,
            'product_name': name,
            'quantity': 0,
            'expiry_date': noExpiry,
            'type': 'outOfStock',

            'created_at': nowIso,
          });
        }
      } else if (qty <= 5) {
        // Low stock:
        //update quantity if notif exists, insert if not
        final existing = await db.query(
          'notifications',
          where: "user_id = ? AND product_id = ? AND type = 'lowStock'",
          whereArgs: [userId, productId],
        );
        if (existing.isEmpty) {
          await db.insert('notifications', {
            'user_id': userId,
            'product_id': productId,
            'product_name': name,
            'quantity': qty,
            'expiry_date': noExpiry,
            'type': 'lowStock',

            'created_at': nowIso,
          });
        } else {
          await db.update(
            'notifications',
            {'quantity': qty},
            where: "user_id = ? AND product_id = ? AND type = 'lowStock'",
            whereArgs: [userId, productId],
          );
        }

        // If there was an outOfStock notif and stock came back, remove it
        await db.delete(
          'notifications',
          where: "user_id = ? AND product_id = ? AND type = 'outOfStock'",
          whereArgs: [userId, productId],
        );
      } else {
        // stock is okay, delete low/out-of-stock notifs for this product
        await db.delete(
          'notifications',
          where:
              "user_id = ? AND product_id = ? AND type IN ('lowStock','outOfStock')",
          whereArgs: [userId, productId],
        );
      }
    }
  }

  Future<int> getItemCount(String transId) async {
    try {
      final db = await instance.database;
      final result = await db.rawQuery(
        '''
    SELECT COUNT(*) as count
    FROM transaction_items
    WHERE transaction_id = ?
    ''',
        [transId],
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      print('Error in getItemCount for transaction $transId: $e');
      return 0;
    }
  }

  // ALL ABOUT TRANSACTIONS
  Future<Map<String, int>> getItemCountsForUser(int userId) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      '''
      SELECT ti.transaction_id, COUNT(*) as count
      FROM transaction_items ti
      JOIN transactions t ON ti.transaction_id = t.id
      WHERE t.user_id = ?
      GROUP BY ti.transaction_id
      ''',
      [userId],
    );
    return {
      for (final row in result)
        row['transaction_id'] as String: (row['count'] as int? ?? 0),
    };
  }

  Future<String> generateTransactionId(int userId) async {
    final now = DateTime.now();
    final db = await instance.database;

    final String date = DateFormat('yyyyMMdd').format(now);
    final int hour12 = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final String letter = String.fromCharCode(64 + hour12);
    final String period = now.hour < 12 ? 'AM' : 'PM';

    final String ms = now.millisecond.toString().padLeft(3, '0');
    final String us = (now.microsecond % 1000).toString().padLeft(
      3,
      '0',
    ); //sub-millisecond
    final String suffix = '$ms$us';

    String candidate = '$date-$hour12-$letter$period-$suffix';

    int guard = 0;
    while (true) {
      final existing = await db.query(
        'transactions',
        columns: ['id'],
        where: 'id = ?',
        whereArgs: [candidate],
        limit: 1,
      );
      if (existing.isEmpty) break;
      guard++;
      candidate = '$date-$hour12-$letter$period-$suffix-$guard';
    }

    return candidate;
  }

  Future<int> insertTransaction(TransactionSale transaction) async {
    final db = await instance.database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<int> insertTransactionItem(TransactionItems item) async {
    final db = await instance.database;
    return await db.insert('transaction_items', item.toMap());
  }

  Future<void> checkoutTransaction({
    required TransactionSale transaction,
    required List<TransactionItems> items,
  }) async {
    final db = await instance.database;

    await db.transaction((txn) async {
      await txn.insert('transactions', transaction.toMap());

      for (final item in items) {
        final rows = await txn.query(
          'products',
          columns: ['quantity'],
          where: 'id = ?',
          whereArgs: [item.productsId],
          limit: 1,
        );

        if (rows.isEmpty) {
          throw InsufficientStockException(
            item.name,
            requested: item.quantity,
            available: 0,
          );
        }

        final liveStock = rows.first['quantity'] as int;
        if (item.quantity > liveStock) {
          throw InsufficientStockException(
            item.name,
            requested: item.quantity,
            available: liveStock,
          );
        }

        await txn.update(
          'products',
          {'quantity': liveStock - item.quantity},
          where: 'id = ?',
          whereArgs: [item.productsId],
        );

        await txn.insert('transaction_items', item.toMap());
      }
    });
  }

  Future<List<TransactionSale>> getTransactionsByUser(int userId) async {
    final db = await instance.database;
    final result = await db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'transacted_at DESC',
    );
    return result
        .map((transaction) => TransactionSale.fromMap(transaction))
        .toList();
  }

  Future<List<TransactionItems>> getTransactionItems(
    String transactionId,
  ) async {
    final db = await instance.database;
    final result = await db.query(
      'transaction_items',
      where: 'transaction_id = ?',
      whereArgs: [transactionId],
    );
    return result.map((item) => TransactionItems.fromMap(item)).toList();
  }

  Future<List<Map<String, dynamic>>> getTransactionItemsByUser(
    int userId,
  ) async {
    final db = await instance.database;
    return await db.rawQuery(
      '''
      SELECT
        ti.id,
        ti.transaction_id,
        ti.products_id,
        ti.product_name,
        ti.barcode,
        ti.unit_price,
        ti.original_price,
        ti.quantity,
        ti.subtotal,
        t.transacted_at
      FROM transaction_items ti
      JOIN transactions t ON ti.transaction_id = t.id
      WHERE t.user_id = ?
      ORDER BY t.transacted_at DESC
      ''',
      [userId],
    );
  }

  Future<TransactionSale?> getTransactionById(String transactionId) async {
    final db = await instance.database;
    final result = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [transactionId],
    );

    if (result.isNotEmpty) {
      return TransactionSale.fromMap(result.first);
    }
    return null;
  }

  // For receipt data - get complete transaction with items
  Future<Map<String, dynamic>?> getCompleteTransaction(
    String transactionId,
  ) async {
    final transaction = await getTransactionById(transactionId);
    if (transaction == null) return null;

    final items = await getTransactionItems(transactionId);

    return {'transaction': transaction, 'items': items};
  }

  Future<List<TransactionSale>> getTransactionByDate(String date) async {
    final db = await instance.database;
    final result = await db.query(
      'transactions',
      where: 'transacted_at = ?',
      whereArgs: [date],
    );

    return result.map((item) => TransactionSale.fromMap(item)).toList();
  }

  Future<Product?> getProductByBarcode(int userId, String barcode) async {
    final db = await instance.database;
    final result = await db.query(
      'products',
      where: 'user_id = ? AND barcode = ?',
      whereArgs: [userId, barcode],
    );

    if (result.isNotEmpty) {
      return Product.fromMap(result.first);
    }
    return null;
  }
}
