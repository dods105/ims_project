import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../designs/appbar.dart';
import '../../designs/drawer.dart';
import '../../designs/themes.dart';
import '../../models/notifications/notification_model.dart';
import '../../models/products/expired_product.dart';
import '../../providers/inventoryProvider.dart';

class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(inventoryProvider);
    final cs = Theme.of(context).colorScheme;

    return inventoryAsync.when(
      loading: () => Scaffold(
        backgroundColor: cs.background,
        appBar: AppBarDesign(page: 'Notifications'),
        endDrawer: AppDrawer(page: '/notification'),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: cs.background,
        appBar: AppBarDesign(page: 'Notifications'),
        endDrawer: AppDrawer(page: '/notification'),
        body: Center(child: Text('Error loading notifications')),
      ),
      data: (state) {
        final tabs = [
          _TabInfo(
            label: 'Expiring',

            color: AppTheme.warning,
            count: state.expiringSoon.length,
          ),
          _TabInfo(
            label: 'Stock',

            color: AppTheme.textOrange,
            count: state.lowStockNotifications.length,
          ),
          _TabInfo(
            label: 'All',

            color: cs.primary,
            count: state.notifications.length,
          ),
          _TabInfo(
            label: 'Expired',

            color: AppTheme.error,
            count: state.expiredProducts.length,
          ),
        ];

        return DefaultTabController(
          length: tabs.length,
          child: Scaffold(
            backgroundColor: cs.background,
            appBar: AppBarDesign(page: 'Notifications'),
            endDrawer: AppDrawer(page: '/notification'),
            body: Column(
              children: [
                // ── Custom tab bar ─────────────────────────────────────
                Container(
                  color: cs.surface,
                  padding: EdgeInsets.fromLTRB(12, 10, 12, 0),
                  child: Column(
                    children: [
                      // Sort + unread row

                      // Tab row
                      TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        dividerColor: Colors.transparent,
                        indicator: BoxDecoration(
                          color: cs.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        labelColor: cs.onPrimary,
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelPadding: EdgeInsets.symmetric(horizontal: 4),
                        tabs: tabs.map((t) => _StyledTab(info: t)).toList(),
                      ),
                      SizedBox(height: 4),
                    ],
                  ),
                ),

                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: Row(
                    children: [
                      // Unread badge

                      // Sort toggle
                      GestureDetector(
                        onTap: () => ref
                            .read(inventoryProvider.notifier)
                            .toggleSortOrder(),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: cs.primary.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                state.sortOrder == NotifSortOrder.newestFirst
                                    ? Icons.arrow_downward_rounded
                                    : Icons.arrow_upward_rounded,
                                size: 14,
                                color: cs.primary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                state.sortOrder == NotifSortOrder.newestFirst
                                    ? 'Newest first'
                                    : 'Oldest first',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: cs.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                // Tab content
                Expanded(
                  child: TabBarView(
                    children: [
                      // expring soon tab
                      NotifList(
                        notifications: state.expiringSoon,
                        emptyMessage: 'No products expiring soon.',

                        onDelete: (id, {NotifType? type}) => _confirmDelete(
                          context: context,
                          ref: ref,
                          id: id,
                          type: type ?? NotifType.expiringSoon,
                        ),
                      ),

                      // low stocks notifications tab
                      NotifList(
                        notifications: state.lowStockNotifications,
                        emptyMessage: 'All products are sufficiently stocked.',

                        onDelete: (id, {NotifType? type}) => _confirmDelete(
                          context: context,
                          ref: ref,
                          id: id,
                          type: type ?? NotifType.lowStock,
                        ),
                      ),

                      //all notications tab
                      NotifList(
                        notifications: state.notifications,
                        emptyMessage: 'No notifications.',

                        onDelete: (id, {NotifType? type}) => _confirmDelete(
                          context: context,
                          ref: ref,
                          id: id,
                          type: type ?? NotifType.expiringSoon,
                        ),
                      ),

                      //expured notifications tab
                      ExpiredList(
                        expiredProducts: state.expiredProducts,
                        onDelete: (id) => _confirmDeleteExpired(
                          context: context,
                          ref: ref,
                          id: id,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Delete dialogs ──────────────────────────────────────────────────────────

  void _confirmDelete({
    required BuildContext context,
    required WidgetRef ref,
    required int id,
    required NotifType type,
  }) {
    final isCascade = type == NotifType.expired || type == NotifType.outOfStock;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Notification?'),
        content: Text(
          isCascade
              ? type == NotifType.expired
                    ? 'This will also delete the expired product record linked to this notification.'
                    : 'This will also delete the out-of-stock product from your inventory.'
              : 'This will permanently remove this notification.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(inventoryProvider.notifier).deleteNotification(id);
            },
            child: Text(
              'Delete',
              style: TextStyle(
                color: isCascade ? AppTheme.error : AppTheme.textRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteExpired({
    required BuildContext context,
    required WidgetRef ref,
    required int id,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Expired Record?'),
        content: Text(
          'This will permanently remove this expired product record and its notification.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(inventoryProvider.notifier).deleteExpiredProduct(id);
            },
            child: Text('Delete', style: TextStyle(color: AppTheme.textRed)),
          ),
        ],
      ),
    );
  }
}

// ─── Tab info model ───────────────────────────────────────────────────────────

class _TabInfo {
  final String label;

  final Color color;
  int count;
  _TabInfo({required this.label, required this.color, required this.count});
}

// ─── Styled tab widget ────────────────────────────────────────────────────────

class _StyledTab extends StatelessWidget {
  final _TabInfo info;
  _StyledTab({required this.info});

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              info.label,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            ...[
              SizedBox(width: 5),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${info.count}',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── NotifList ────────────────────────────────────────────────────────────────

class NotifList extends StatelessWidget {
  final List<AppNotification> notifications;
  final String emptyMessage;

  final void Function(int id, {NotifType? type}) onDelete;

  const NotifList({
    super.key,
    required this.notifications,
    required this.emptyMessage,

    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 12),
            Text(emptyMessage, style: TextStyle(color: AppTheme.textMuted)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(10),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notif = notifications[index];
        return Column(
          children: [
            NotifCard(
              notification: notif,
              onDelete: () => onDelete(notif.id!, type: notif.type),
            ),
            SizedBox(height: 10),
          ],
        );
      },
    );
  }
}

// ─── NotifCard ────────────────────────────────────────────────────────────────

class NotifCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onDelete;

  NotifCard({super.key, required this.notification, required this.onDelete});

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
        return '${notification.productName} is running low. Only ${notification.quantity} left.';
      case NotifType.outOfStock:
        return '${notification.productName} is out of stock. Please restock.';
      case NotifType.expired:
        return '${notification.productName} expired on ${notification.expiryDate}.';
      case NotifType.expiringSoon:
        return '${notification.quantity} unit(s) of ${notification.productName} will expire on ${notification.expiryDate}.';
    }
  }

  String _formatDate(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    return DateFormat('MMM d, yyyy • h:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),

      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline, width: 1.5),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.fromLTRB(14, 5, 8, 5),
            leading: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _accentColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, color: _accentColor, size: 20),
            ),
            title: Row(
              children: [
                Text(
                  _title,
                  style: AppTheme.titleSmall.copyWith(
                    color: _accentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 3),
              child: Text(_body, style: AppTheme.bodySmall),
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: AppTheme.textRed,
                size: 20,
              ),
              onPressed: onDelete,
            ),
          ),
          //date notification created
          Padding(
            padding: EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_outlined,
                  size: 12,
                  color: Colors.grey[400],
                ),
                SizedBox(width: 4),
                Text(
                  _formatDate(notification.createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ExpiredList ──────────────────────────────────────────────────────────────

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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 12),
            Text(
              'No expired products.',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8),
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

// ─── ExpiredCard ──────────────────────────────────────────────────────────────

class ExpiredCard extends StatelessWidget {
  final ExpiredProduct product;
  final VoidCallback onDelete;

  ExpiredCard({super.key, required this.product, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.error.withOpacity(0.35),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.fromLTRB(14, 10, 8, 4),
              leading: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.dangerous_outlined,
                  color: AppTheme.error,
                  size: 20,
                ),
              ),
              title: Text(
                product.name,
                style: AppTheme.titleSmall.copyWith(
                  color: AppTheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Padding(
                padding: EdgeInsets.only(top: 3),
                child: Text(
                  '${product.quantity} item(s) expired on ${product.expiryDate}.',
                  style: AppTheme.bodySmall,
                ),
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: AppTheme.textRed,
                  size: 20,
                ),
                onPressed: onDelete,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Row(
                children: [
                  Icon(
                    Icons.move_to_inbox_outlined,
                    size: 12,
                    color: Colors.grey[400],
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Moved ${product.movedAt}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
