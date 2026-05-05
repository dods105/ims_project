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

class InventoryState {
  final List<Product> products;
  final List<ExpiredProduct> expiredProducts;
  final List<AppNotification> notifications;

  const InventoryState({
    this.products = const [],
    this.expiredProducts = const [],
    this.notifications = const [],
  });

  List<AppNotification> get expiringSoon =>
      notifications.where((n) => n.type == NotifType.expiringSoon).toList();

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  InventoryState copyWith({
    List<Product>? products,
    List<ExpiredProduct>? expiredProducts,
    List<AppNotification>? notifications,
  }) {
    return InventoryState(
      products: products ?? this.products,
      expiredProducts: expiredProducts ?? this.expiredProducts,
      notifications: notifications ?? this.notifications,
    );
  }
}

class InventoryNotifier extends AsyncNotifier<InventoryState> {
  // Shorthand for the database helper
  final _db = DatabaseHelper.instance;

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
    final notifications = await _db.getNotifications(userId);
    return InventoryState(
      products: products,
      expiredProducts: expiredProducts,
      notifications: notifications,
    );
  }

  Future<void> refresh() async {
    final user = ref.read(authProvider).value;
    if (user == null) return;

    await _db.checkAndProcessExpiry(user.id!);
    state = AsyncData(await _fetchAll(user.id!));
  }

  Future<Product?> getExistingProduct(Product product) async {
    return await _db.getExistingProduct(product);
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

  Future<void> deleteNotification(int id) async {
    await _db.deleteNotification(id);
    await refresh();
  }

  Future<void> markRead(int id) async {
    await _db.markNotificationRead(id);
    await refresh();
  }

  Future<String?> pickAndSaveImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return null;

    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPath = p.join(appDir.path, fileName);

    await File(picked.path).copy(savedPath);

    return savedPath;
  }
}

final inventoryProvider =
    AsyncNotifierProvider<InventoryNotifier, InventoryState>(
      InventoryNotifier.new,
    );
