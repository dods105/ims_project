import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../designs/appbar.dart';
import '../../designs/drawer.dart';
import '../../designs/themes.dart';
import '../../models/notifications/notification_model.dart';
import '../../models/products/expired_product.dart';
import '../../providers/inventoryProvider.dart';

// ============================================================================
// OVERALL FUNCTIONALITY OF THE CLASS:
// The 'NotificationPage' is a UI component that displays various types of 
// inventory notifications (Expiring, Low Stock, All, and Expired). 
// It utilizes Riverpod for reactive state management, enabling automatic 
// data updates, and supports sorting (newest/oldest) and item deletion.
// ============================================================================
class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // VARIABLES
    // inventoryAsync: Watches the asynchronous inventory state from Riverpod.
    // cs: Provides access to the theme's ColorScheme for consistent UI styling.
    final inventoryAsync = ref.watch(inventoryProvider);
    final cs = Theme.of(context).colorScheme;

    // WIDGET (Asynchronous Data Handler)
    // Manages the view state based on three conditions: Loading, Error, or Data.
    return inventoryAsync.when(
      loading: () => Scaffold(
        backgroundColor: cs.background,
        appBar: AppBarDesign(page: 'Notifications'),
        endDrawer: AppDrawer(page: '/notification'),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: cs.background,
        appBar: AppBarDesign(page: 'Notifications'),
        endDrawer: AppDrawer(page: '/notification'),
        body: const Center(child: Text('Error loading notifications')),
      ),
      data: (state) {
        // SORTING FUNCTIONALITY
        // Arranges expired items dynamically based on the 'movedAt' timestamp.
        final sortedExpired = List<ExpiredProduct>.from(state.expiredProducts)
          ..sort((a, b) {
            final cmp = a.movedAt.compareTo(b.movedAt);
            // IF-ELSE STATEMENT
            // If sortOrder is set to newestFirst, reverse the comparison results.
            return state.sortOrder == NotifSortOrder.newestFirst ? -cmp : cmp;
          });
 // VARIABLES (Tab Configuration)
        // Configuration list for tabs containing labels, colors, and current item counts.
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
            count: sortedExpired.length,
          ),
        ];

        // WIDGETS (Main Layout Structure)
        // Uses DefaultTabController to sync tab switching with screen content views.
        return DefaultTabController(
          length: tabs.length,
          child: Scaffold(
            backgroundColor: cs.background,
            appBar: AppBarDesign(page: 'Notifications'),
            endDrawer: AppDrawer(page: '/notification'),
            body: Column(
              children: [
                // WIDGET (Custom Tab Bar Container)
                // A horizontally scrollable menu row matching the defined tabs list.
                Container(
                  color: cs.surface,
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                  child: Column(
                    children: [
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
                        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                        tabs: tabs.map((t) => _StyledTab(info: t)).toList(),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
                     const SizedBox(height: 20),

                // WIDGET (Sort Toggle Button Layout)
                // Clickable structural area handling list order modifications.
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        // FUNCTIONALITY ON TAP
                        // Calls the underlying notifier to cycle through sorting options.
                        onTap: () => ref
                            .read(inventoryProvider.notifier)
                            .toggleSortOrder(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
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
                              // WIDGET / IF-ELSE (Dynamic Icon & Text)
                              // Displays the correct icon arrow and text direction based on state.
                              Icon(
                                state.sortOrder == NotifSortOrder.newestFirst
                                    ? Icons.arrow_downward_rounded
                                    : Icons.arrow_upward_rounded,
                                size: 14,
                                color: cs.primary,
                              ),
                              const SizedBox(width: 4),
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
                const SizedBox(height: 10), // WIDGET (Tab Content View)
                // Renders the specific lists tied directly to the active tab category.
                Expanded(
                  child: TabBarView(
                    children: [
                      // Tab 1: Expiring soon list (Deletion disabled)
                      NotifList(
                        notifications: state.expiringSoon,
                        emptyMessage: 'No products expiring soon.',
                        onDelete: null,
                      ),

                      // Tab 2: Low stock list (Deletion disabled)
                      NotifList(
                        notifications: state.lowStockNotifications,
                        emptyMessage: 'All products are sufficiently stocked.',
                        onDelete: null,
                      ),

                      // Tab 3: Combined notifications list
                      NotifList(
                        notifications: state.notifications,
                        emptyMessage: 'No notifications.',
                        onDelete: (id, {NotifType? type}) {
                          final t = type ?? NotifType.lowStock;
                          // IF-ELSE STATEMENT
                          // Restricts item deletion; only outOfStock or expired types are allowed.
                          if (t == NotifType.outOfStock ||
                              t == NotifType.expired) {
                            _confirmDelete(
                              context: context,
                              ref: ref,
                              id: id,
                              type: t,
                            );
                          }
                        },
                      ),

                      // Tab 4: Expired products list (Deletion active via specific confirm modal)
                      ExpiredList(
                        expiredProducts: sortedExpired,
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
  } // FUNCTION (Confirmation Dialog Trigger)
  // Generates and manages modal delete verification prompts contextually.
  void _confirmDelete({
    required BuildContext context,
    required WidgetRef ref,
    required int id,
    required NotifType type,
  }) {
    // VARIABLE
    // Condition flag checking if the target entity falls under an expired classification.
    final isExpired = type == NotifType.expired;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Notification?'),
        // IF-ELSE STATEMENT
        // Customizes dialogue warnings depending on whether the asset type is expired.
        content: Text(
          isExpired
              ? 'This will also delete the expired product record and all related notifications.'
              : 'This will also delete the out-of-stock product from your inventory and all related notifications.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            // FUNCTIONALITY ON PRESS
            // Closes context wrapper view and requests notifier package deletion.
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(inventoryProvider.notifier).deleteNotification(id);
            },
            child: Text('Delete', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }

  // FUNCTION (Expired Notification Confirmation)
  // Shows a separate verification dialogue box specifically for expired data layouts.
  void _confirmDeleteExpired({
    required BuildContext context,
    required WidgetRef ref,
    required int id,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expired Record?'),
        content: const Text(
          'This will permanently remove this expired product record and its notification.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
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
}// DATA MODEL CLASS (Tab Information Structure)
// Blueprint tracking properties for tab title, selection colors, and badge item counts.
class _TabInfo {
  final String label;
  final Color color;
  final int count;
  const _TabInfo({
    required this.label,
    required this.color,
    required this.count,
  });
}

// WIDGET (Styled individual tab item layout view)
// Handles display parameters for header button tags using specific spacing constraints.
class _StyledTab extends StatelessWidget {
  final _TabInfo info;
  const _StyledTab({required this.info});

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              info.label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${info.count}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// WIDGET (Notification List Renderer)
// Structural controller rendering conditional layouts for dynamic collections.
class NotifList extends StatelessWidget {
  final List<AppNotification> notifications;
  final String emptyMessage;

  // VARIABLES (Function Pointers)
  // Conditional deletion handlers applied globally across the list container.
  final void Function(int id, {NotifType? type})? onDelete;

  const NotifList({
    super.key,
    required this.notifications,
    required this.emptyMessage,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // IF-ELSE STATEMENT
    // Validates list sizing; falls back to an empty placeholder view when count is zero.
    if (notifications.isEmpty) {
      return Center(
        child: Text(emptyMessage, style: TextStyle(color: AppTheme.textMuted)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notif = notifications[index];
        // VARIABLE / IF-ELSE LOGIC
        // Enforces action validation rules; item deletion is restricted by type parameters.
        final isDeletable =
            onDelete != null &&
            (notif.type == NotifType.outOfStock ||
                notif.type == NotifType.expired);

        return Column(
          children: [
            NotifCard(
              notification: notif,
              onDelete: isDeletable
                  ? () => onDelete!(notif.id!, type: notif.type)
                  : null,
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }
}// WIDGET (Notification Card Container layout view)
// Renders the specific styling rules for card cells within active lists.
class NotifCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onDelete;

  const NotifCard({
    super.key,
    required this.notification,
    required this.onDelete,
  });

  // FUNCTIONS (Dynamic Property Getters)
  // Resolves styling profiles based on the object type flag.
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
    return DateFormat('MMM d, yyyy').format(dt);
  } @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline, width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(14, 5, 8, 5),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _accentColor.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(_icon, color: _accentColor, size: 20),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDate(notification.createdAt),
              style: TextStyle(fontSize: 11, color: Colors.grey[400]),
            ),
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
          padding: const EdgeInsets.only(top: 3),
          child: Text(_body, style: AppTheme.bodySmall),
        ),
        // WIDGET / IF-ELSE LOGIC
        // Toggles action item buttons dynamically based on verification states.
        trailing: onDelete != null
            ? IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: AppTheme.textRed,
                  size: 20,
                ),
                onPressed: onDelete,
              )
            : null,
      ),
    );
  }
}

// WIDGET (Expired Products List Renderer)
// Dedicated list layout that handles formatting and displaying history logs for expired items.
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
    // IF-ELSE STATEMENT
    // Returns a clear visual message if the list contains no logs.
    if (expiredProducts.isEmpty) {
      return Center(
        child: Text(
          'No expired products.',
          style: TextStyle(color: AppTheme.textMuted),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('NAME', style: AppTheme.titleSmall),
              ),
              Expanded(flex: 1, child: Text('QTY', style: AppTheme.titleSmall)),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Text('EXPIRY', style: AppTheme.titleSmall),
              ),
              // Space for the delete icon column
              const SizedBox(width: 40),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 20),
            itemCount: expiredProducts.length,
            itemBuilder: (context, index) {
              final product = expiredProducts[index];
              return _ExpiredTile(
                product: product,
                onDelete: () => onDelete(product.id!),
              );
            },
          ),
        ),
      ],
    );
  }
}// WIDGET (Expired Product Individual Tile View)
// Formats individual rows representing a single expired item layout cell.
class _ExpiredTile extends StatelessWidget {
  final ExpiredProduct product;
  final VoidCallback onDelete;

  const _ExpiredTile({required this.product, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      // FUNCTIONALITY ON TAP
      // Displays an information spreadsheet view overlay modal on interaction.
      onTap: () => _showInfoSheet(context, cs),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Material(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.error.withOpacity(0.30),
                width: 1.2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Row(
                children: [
                  // Text Layout: Item Name Display
                  Expanded(
                    flex: 3,
                    child: Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: AppTheme.bodyMedium,
                    ),
                  ),

                  // Text Layout: Item Quantity Display
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(
                        '${product.quantity}',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textRed.withOpacity(0.7),
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Text Layout: Item Expiry Date Display
                  Expanded(
                    flex: 2,
                    child: Text(
                      product.expiryDate,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  
                  // Action Item Button: Triggers item record deletion
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.delete_outline,
                      color: AppTheme.textRed,
                      size: 20,
                    ),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} // FUNCTION (Bottom Info Sheet Presenter)
  // Displays a dynamic modal overlay layout block from the bottom of the active view context.
  void _showInfoSheet(BuildContext context, ColorScheme cs) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ExpiredInfoSheet(product: product, cs: cs),
    );
  }
} // _ExpiredInfoSheet
// Read-only detail view shown when a user taps an expired product tile.
//might delete later. dont put comments here

class _ExpiredInfoSheet extends StatelessWidget {
  final ExpiredProduct product;
  final ColorScheme cs;

  const _ExpiredInfoSheet({required this.product, required this.cs});

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textMuted),
            ),
          ),
          Expanded(child: Text(value, style: AppTheme.bodyMedium)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'EXPIRED PRODUCT',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.brandBlueDeep,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 8),
          _row('Product Name', product.name),
          _row('Quantity', '${product.quantity} item(s)'),
          _row('Expiry Date', product.expiryDate),
        ],
      ),
    );
  }
}