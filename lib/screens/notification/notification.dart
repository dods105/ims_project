import 'package:flutter_application_1/models/notifications/notification_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../designs/drawer.dart';
import '../../designs/themes.dart';
import '../../designs/appbar.dart';
import '../../models/products/expired_product.dart';
import '../../providers/display_provider.dart';
import '../../providers/inventoryProvider.dart';

class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final display = ref.watch(displaySettingsProvider);
    final cs = Theme.of(context).colorScheme;
    final inventoryAsync = ref.watch(inventoryProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBarDesign(page: 'Notification'),
        endDrawer: const AppDrawer(page: '/notification'),
        body: Column(
          children: [
            Material(
              color: cs.secondaryContainer,
              child: TabBar(
                tabs: [
                  Tab(
                    child: Text(
                      'Today',
                      style: TextStyle(color: cs.surfaceVariant),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'All',
                      style: TextStyle(color: cs.surfaceVariant),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Expired Products',
                      style: TextStyle(color: cs.surfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: inventoryAsync.when(
                loading: () => Center(child: CircularProgressIndicator()),
                error: (e, st) =>
                    Center(child: Text('Error loading notifications')),
                data: (state) => TabBarView(
                  children: [
                    // Today's notifications
                    NotifList(
                      notifications: state.expiringSoon,
                      emptyMessage: 'No Notifications.',
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
                    // Expired products notifications
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

class NotifCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onDelete;

  const NotifCard({
    super.key,
    required this.notification,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            ListTile(
              title: Wrap(
                alignment: WrapAlignment.start,
                children: [
                  Text(
                    notification.productName,
                    style: TextStyle(
                      color: cs.secondaryContainer,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${notification.quantity} items are about to expire on',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w100,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${notification.expiryDate} day(s).',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 14,
                          fontWeight: FontWeight(700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _confirmDelete(context),
              ),
            ),
          ],
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
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

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
      return Center(child: Text('No expired products.'));
    }
    return ListView.builder(
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

class ExpiredCard extends StatelessWidget {
  final ExpiredProduct product;
  final VoidCallback onDelete;

  const ExpiredCard({super.key, required this.product, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          ListTile(
            title: Wrap(
              alignment: WrapAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    color: cs.secondaryContainer,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${product.quantity} items have expired on',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w100,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${product.expiryDate}.',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 14,
                        fontWeight: FontWeight(700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDelete(context),
            ),
          ),
        ],
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
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
