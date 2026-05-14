import 'package:flutter_application_1/models/notifications/notification_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../designs/drawer.dart';
import '../../designs/themes.dart';
import '../../designs/appbar.dart';
import '../../models/products/expired_product.dart';
import '../../providers/inventoryProvider.dart';

class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(inventoryProvider);
    final cs = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBarDesign(page: 'Notification'),
        endDrawer: const AppDrawer(page: '/notification'),
        body: Column(
          children: [
            Material(
              color: cs.primary,
              child: TabBar(
                labelColor: AppTheme.white,
                unselectedLabelColor: AppTheme.white.withOpacity(0.6),
                indicatorColor: AppTheme.white,
                tabs: const [
                  Tab(text: 'Expiring Soon'),
                  Tab(text: 'Low Stock'),
                  Tab(text: 'All'),
                  Tab(text: 'Expired'),
                ],
              ),
            ),
            Expanded(
              child: inventoryAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) =>
                    const Center(child: Text('Error loading notifications')),
                data: (state) => TabBarView(
                  children: [
                    // Expiring Soon
                    NotifList(
                      notifications: state.expiringSoon,
                      emptyMessage: 'No expiring products.',
                      onDelete: (id) => ref
                          .read(inventoryProvider.notifier)
                          .deleteNotification(id),
                    ),
                    // Low Stock / Out of Stock
                    NotifList(
                      notifications: state.lowStockNotifications,
                      emptyMessage: 'All products are sufficiently stocked.',
                      onDelete: (id) => ref
                          .read(inventoryProvider.notifier)
                          .deleteNotification(id),
                    ),
                    // All notifications
                    NotifList(
                      notifications: state.notifications,
                      emptyMessage: 'No notifications.',
                      onDelete: (id) => ref
                          .read(inventoryProvider.notifier)
                          .deleteNotification(id),
                    ),
                    // Expired products
                    ExpiredList(
                      expiredProducts: state.expiredProducts,
                      onDelete: (id) => ref
                          .read(inventoryProvider.notifier)
                          .deleteExpiredProduct(id),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// NotifList

class NotifList extends StatelessWidget {
  final List<AppNotification> notifications;
  final String emptyMessage;
  final void Function(int id) onDelete;

  const NotifList({
    super.key,
    required this.notifications,
    required this.emptyMessage,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return Center(child: Text(emptyMessage));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notif = notifications[index];
        return NotifCard(
          notification: notif,
          onDelete: () => onDelete(notif.id!),
        );
      },
    );
  }
}

// NotifCard

class NotifCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onDelete;

  const NotifCard({
    super.key,
    required this.notification,
    required this.onDelete,
  });

  // Icon + colour per notification type
  IconData get _icon {
    switch (notification.type) {
      case NotifType.lowStock:
        return Icons.inventory_2_outlined;
      case NotifType.outOfStock:
        return Icons.remove_shopping_cart_outlined;
      case NotifType.expired:
        return Icons.dangerous_outlined;
      case NotifType.expiringSoon:
        return Icons.hourglass_bottom_outlined;
    }
  }

  Color get _accentColor {
    switch (notification.type) {
      case NotifType.lowStock:
        return AppTheme.textOrange;
      case NotifType.outOfStock:
        return AppTheme.textRed;
      case NotifType.expired:
        return AppTheme.error;
      case NotifType.expiringSoon:
        return AppTheme.warning;
    }
  }

  String get _title {
    switch (notification.type) {
      case NotifType.lowStock:
        return 'Low Stock';
      case NotifType.outOfStock:
        return 'Out of Stock';
      case NotifType.expired:
        return 'Product Expired';
      case NotifType.expiringSoon:
        return 'Expiring Soon';
    }
  }

  String get _body {
    switch (notification.type) {
      case NotifType.lowStock:
        return '${notification.productName} is running low. Only ${notification.quantity} are left.';
      case NotifType.outOfStock:
        return '${notification.productName} is out of stock. Please restock.';
      case NotifType.expired:
        return '${notification.productName} expired on ${notification.expiryDate}.';
      case NotifType.expiringSoon:
        return '${notification.quantity} unit(s) of ${notification.productName} will expire on ${notification.expiryDate}.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outline),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, color: _accentColor, size: 22),
          ),
          title: Text(
            _title,
            style: AppTheme.titleSmall.copyWith(color: _accentColor),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(_body, style: AppTheme.bodySmall),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.textRed),
            onPressed: () => _confirmDelete(context),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Notification?'),
        content: const Text('This will permanently remove this notification.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.textRed),
            ),
          ),
        ],
      ),
    );
  }
}

// ExpiredList

class ExpiredList extends StatelessWidget {
  final List<ExpiredProduct> expiredProducts;
  final void Function(int id) onDelete;

  const ExpiredList({
    super.key,
    required this.expiredProducts,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (expiredProducts.isEmpty) {
      return const Center(
        child: Text(
          'No expired products.',
          style: TextStyle(color: AppTheme.textMuted),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: expiredProducts.length,
      itemBuilder: (context, index) {
        final product = expiredProducts[index];
        return ExpiredCard(
          product: product,
          onDelete: () => onDelete(product.id!),
        );
      },
    );
  }
}

// ExpiredCard

class ExpiredCard extends StatelessWidget {
  final ExpiredProduct product;
  final VoidCallback onDelete;

  const ExpiredCard({super.key, required this.product, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderDefault),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.error.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.dangerous_outlined,
              color: AppTheme.error,
              size: 22,
            ),
          ),
          title: Text(
            product.name,
            style: AppTheme.titleSmall.copyWith(color: AppTheme.error),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${product.quantity} item(s) expired on ${product.expiryDate}.',
              style: AppTheme.bodySmall,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.textRed),
            onPressed: () => _confirmDelete(context),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expired Record?'),
        content: const Text(
          'This will permanently remove this expired product record.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.textRed),
            ),
          ),
        ],
      ),
    );
  }
}
