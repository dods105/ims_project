import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../database/database_helper.dart';
import '../models/products/products.dart';
import '../models/products/expired_product.dart';
import '../models/notifications/notification_model.dart';
import 'auth_provider.dart';

//sort order
enum NotifSortOrder { newestFirst, oldestFirst }

class InventoryState {
  final List<Product> products;
  final List<ExpiredProduct> expiredProducts;
  final List<AppNotification> notifications;
  final NotifSortOrder sortOrder;

  const InventoryState({
    this.products = const [],
    this.expiredProducts = const [],
    this.notifications = const [],
    this.sortOrder = NotifSortOrder.newestFirst,
  });

  //filltered getters
  List<AppNotification> get expiringSoon =>
      notifications.where((n) => n.type == NotifType.expiringSoon).toList();

  List<AppNotification> get lowStockNotifications => notifications
      .where(
        (n) => n.type == NotifType.lowStock || n.type == NotifType.outOfStock,
      )
      .toList();

  InventoryState copyWith({
    List<Product>? products,
    List<ExpiredProduct>? expiredProducts,
    List<AppNotification>? notifications,
    NotifSortOrder? sortOrder,
  }) {
    return InventoryState(
      products: products ?? this.products,
      expiredProducts: expiredProducts ?? this.expiredProducts,
      notifications: notifications ?? this.notifications,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

// Notifier
class InventoryNotifier extends AsyncNotifier<InventoryState> {
  final _db = DatabaseHelper.instance;

  NotifSortOrder _sortOrder = NotifSortOrder.newestFirst;

  @override
  Future<InventoryState> build() async {
    final user = ref.watch(authProvider).value;
    if (user == null) return const InventoryState();

    await _db.checkAndProcessExpiry(user.id!);
    return _fetchAll(user.id!);
  }

  Future<InventoryState> _fetchAll(int userId) async {
    final products = await _db.getProductsByUser(userId);
    final expiredProducts = await _db.getExpiredProductByUSer(userId);
    final notifications = await _db.getNotifications(
      userId,
      ascending: _sortOrder == NotifSortOrder.oldestFirst,
    );
    return InventoryState(
      products: products,
      expiredProducts: expiredProducts,
      notifications: notifications,
      sortOrder: _sortOrder,
    );
  }

  Future<void> refresh() async {
    final user = ref.read(authProvider).value;
    if (user == null) return;

    await _db.checkAndProcessExpiry(user.id!);
    state = AsyncData(await _fetchAll(user.id!));
  }

  Future<void> toggleSortOrder() async {
    _sortOrder = _sortOrder == NotifSortOrder.newestFirst
        ? NotifSortOrder.oldestFirst
        : NotifSortOrder.newestFirst;

    final user = ref.read(authProvider).value;
    if (user == null) return;
    state = AsyncData(await _fetchAll(user.id!));
  }

  Future<Product?> getExistingProduct(Product product) async {
    return await _db.getExistingProduct(product);
  }

  Future<Product?> getProductByBarcode(int userId, String barcode) async {
    return _db.getProductByBarcode(userId, barcode);
  }

  Future<List<Product>> searchProduct(int userId, String query) async {
    final products = await _db.getProductsByUser(userId);
    if (query.isEmpty) return products;
    final lowQuery = query.toLowerCase();
    return products.where((p) {
      return p.name.toLowerCase().contains(lowQuery) ||
          (p.barcode?.toLowerCase().contains(lowQuery) ?? false);
    }).toList();
  }

  Future<void> addProduct(Product product) async {
    await _db.insertOrUpdateProduct(product);
    await refresh();
  }

  Future<void> updateProduct(Product product) async {
    await _db.updateProduct(product);
    await refresh();
  }

  Future<void> deleteProduct(int id) async {
    await _db.deleteProduct(id);
    await refresh();
  }

  Future<void> deleteExpiredProduct(int id) async {
    await _db.deleteExpiredProduct(id);
    await refresh();
  }

  // deletes a notification.
  // for expired type. remove expired_product record.
  // for outOfStock type. remove zero-stock product record.
  Future<void> deleteNotification(int id) async {
    await _db.deleteNotification(id); // cascade logic is in DB layer
    await refresh();
  }

  // image picker
  Future<String?> pickAndSaveImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return null;

    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPath = p.join(appDir.path, fileName);
    await File(picked.path).copy(savedPath);
    return savedPath;
  }
}

// Provider
final inventoryProvider =
    AsyncNotifierProvider<InventoryNotifier, InventoryState>(
      InventoryNotifier.new,
    );
