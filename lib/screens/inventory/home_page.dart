import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../designs/appbar.dart';
import '../../designs/barcode_scanner_page.dart';
import '../../designs/drawer.dart';
import '../../designs/themes.dart';
import '../../models/products/products.dart';
import '../../providers/inventoryProvider.dart';
import 'edit_form.dart';

// Sort options
enum _SortMode { nameAZ, stockHighLow, expiryNearFar, groupByType }

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  _SortMode _sortMode = _SortMode.nameAZ;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filtering + sorting
  List<Product> _apply(List<Product> products) {
    var list = _query.isEmpty
        ? List<Product>.from(products)
        : products.where((p) {
            return p.name.toLowerCase().contains(_query) ||
                (p.barcode ?? '').toLowerCase().contains(_query);
          }).toList();

    switch (_sortMode) {
      case _SortMode.nameAZ:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case _SortMode.stockHighLow:
        list.sort((a, b) => b.quantity.compareTo(a.quantity));
        break;
      case _SortMode.expiryNearFar:
        list.sort((a, b) {
          if (a.expiryDate == null && b.expiryDate == null) return 0;
          if (a.expiryDate == null) return 1;
          if (b.expiryDate == null) return -1;
          return a.expiryDate!.compareTo(b.expiryDate!);
        });
        break;
      case _SortMode.groupByType:
        list.sort((a, b) {
          final ta = a.productType ?? '';
          final tb = b.productType ?? '';
          final cmp = ta.compareTo(tb);
          return cmp != 0 ? cmp : a.name.compareTo(b.name);
        });
        break;
    }
    return list;
  }

  // Stock color
  Color _stockColor(int qty) {
    if (qty == 0) return AppTheme.textRed;
    if (qty <= 5) return AppTheme.textOrange;
    if (qty < 12) return AppTheme.warning;
    return AppTheme.textGreen;
  }

  // Delete confirm dialog
  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product?'),
        content: Text('Remove "${product.name}" from inventory?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(inventoryProvider.notifier).deleteProduct(product.id!);
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

  @override
  Widget build(BuildContext context) {
    final inventoryAsync = ref.watch(inventoryProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBarDesign(page: 'INVENTORY'),
      endDrawer: const AppDrawer(page: '/inventory'),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outline),
              ),
              child: TextField(
                textAlignVertical: TextAlignVertical.center,
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name or barcode…',
                  prefixIcon: Icon(Icons.search, color: AppTheme.textMuted),
                  suffixIcon: GestureDetector(
                    onTap: () async {
                      await Future.delayed(const Duration(milliseconds: 150));
                      final scanned = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BarcodeScannerPage(),
                        ),
                      );
                      if (scanned != null) {
                        _searchController.text = scanned;
                      }
                    },
                    child: const Icon(Icons.qr_code_scanner),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Column headers + sort popup
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 8, 6),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('NAME', style: AppTheme.titleSmall),
                ),
                Expanded(
                  flex: 2,
                  child: Text('STOCKS', style: AppTheme.titleSmall),
                ),
                Expanded(
                  flex: 2,
                  child: Text('PRICE', style: AppTheme.titleSmall),
                ),
                // ort popup menu
                PopupMenuButton<_SortMode>(
                  icon: Icon(
                    Icons.filter_list,
                    color: _sortMode != _SortMode.nameAZ
                        ? AppTheme.brandBlue
                        : null,
                  ),
                  tooltip: 'Sort',
                  color: cs.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (mode) => setState(() => _sortMode = mode),
                  itemBuilder: (_) => [
                    _sortItem(
                      _SortMode.nameAZ,
                      'Alphabetical (A–Z)',
                      Icons.sort_by_alpha,
                    ),
                    _sortItem(
                      _SortMode.stockHighLow,
                      'Stock (High → Low)',
                      Icons.inventory_2_outlined,
                    ),
                    _sortItem(
                      _SortMode.expiryNearFar,
                      'Expiry (Nearest first)',
                      Icons.calendar_today_outlined,
                    ),
                    _sortItem(
                      _SortMode.groupByType,
                      'Group by Type',
                      Icons.category_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Product list
          Expanded(
            child: inventoryAsync.when(
              data: (data) {
                final products = _apply(data.products);

                if (data.products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: AppTheme.textMuted,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No products yet',
                          style: AppTheme.bodyLarge.copyWith(
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (products.isEmpty) {
                  return Center(
                    child: Text(
                      'No results for "$_query"',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textMuted,
                      ),
                    ),
                  );
                }

                // Group-by-type dividers
                if (_sortMode == _SortMode.groupByType) {
                  final groups = <String, List<Product>>{};
                  for (final p in products) {
                    groups
                        .putIfAbsent(p.productType ?? 'Uncategorized', () => [])
                        .add(p);
                  }
                  return ListView(
                    padding: const EdgeInsets.only(bottom: 20),
                    children: groups.entries.expand((entry) {
                      return [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                          child: Text(
                            entry.key,
                            style: AppTheme.titleSmall.copyWith(
                              color: AppTheme.brandBlue,
                            ),
                          ),
                        ),
                        ...entry.value.map((p) => _productTile(p, cs)),
                      ];
                    }).toList(),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: products.length,
                  itemBuilder: (_, i) => _productTile(products[i], cs),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  // Helper: sort menu item with active checkmark
  PopupMenuItem<_SortMode> _sortItem(
    _SortMode mode,
    String label,
    IconData icon,
  ) {
    final isActive = _sortMode == mode;
    return PopupMenuItem<_SortMode>(
      value: mode,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isActive ? AppTheme.brandBlue : AppTheme.textMuted,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: isActive ? null : AppTheme.textMuted),
            ),
          ),
          if (isActive) Icon(Icons.check, size: 16, color: AppTheme.brandBlue),
        ],
      ),
    );
  }

  Widget _productTile(Product product, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  product.name,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.bodyMedium,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '${product.quantity}',
                  style: AppTheme.bodyMedium.copyWith(
                    color: _stockColor(product.quantity),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '₱${product.sellingPrice.toStringAsFixed(2)}',
                  style: AppTheme.bodyMedium,
                ),
              ),

              // ── Product action popup menu ────────────────────────────
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 18),
                tooltip: 'Options',
                color: cs.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProductPage(product: product),
                      ),
                    );
                  } else if (value == 'delete') {
                    _confirmDelete(product);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: AppTheme.textMuted,
                        ),
                        const SizedBox(width: 10),
                        const Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: AppTheme.textRed,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Delete',
                          style: TextStyle(color: AppTheme.textRed),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
