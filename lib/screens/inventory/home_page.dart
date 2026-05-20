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
enum _SortMode {
  nameAZ,
  stockHighLow,
  expiryNearFar,
  groupByType,
  stockLowHigh,
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  _SortMode _sortMode = _SortMode.groupByType;

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
      case _SortMode.stockLowHigh:
        list.sort((a, b) => a.quantity.compareTo(b.quantity));
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
    if (qty <= 10 && qty > 0) return Colors.amber;
    return AppTheme.textGreen;
  }

  @override
  Widget build(BuildContext context) {
    final inventoryAsync = ref.watch(inventoryProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBarDesign(page: 'INVENTORY'),
      endDrawer: AppDrawer(page: '/inventory'),
      body: Column(
        children: [
          SizedBox(height: 16),

          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: cs.outline,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by name or barcode…',
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppTheme.textMuted,
                        ),
                        suffixIcon: GestureDetector(
                          child: Icon(Icons.qr_code_scanner),
                          onTap: () async {
                            await Future.delayed(Duration(milliseconds: 150));
                            if (!context.mounted) return;
                            final scanned = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BarcodeScannerPage(),
                              ),
                            );
                            if (!context.mounted) return;
                            if (scanned != null) {
                              _searchController.text = scanned;
                            }
                          },
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                      ),
                    ),
                  ),
                ),
                PopupMenuButton<_SortMode>(
                  icon: Icon(
                    size: 20,
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
                    _sortItem(_SortMode.nameAZ, 'Alphabetical (A–Z)'),
                    _sortItem(_SortMode.stockHighLow, 'Stock (High → Low)'),
                    _sortItem(_SortMode.stockLowHigh, 'Stock (Low → High)'),
                    _sortItem(
                      _SortMode.expiryNearFar,
                      'Expiry (Nearest Expiration)',
                    ),
                    _sortItem(_SortMode.groupByType, 'Group by Type'),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 12),

          // Column headers + sort popup
          Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('NAME', style: AppTheme.titleSmall),
                ),
                Expanded(
                  flex: 1,
                  child: Text('STOCKS', style: AppTheme.titleSmall),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: Text('PRICE', style: AppTheme.titleSmall),
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
                        SizedBox(height: 16),
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
                    padding: EdgeInsets.only(bottom: 20),
                    children: groups.entries.expand((entry) {
                      return [
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 14, 20, 4),
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
                  padding: EdgeInsets.only(bottom: 20),
                  itemCount: products.length,
                  itemBuilder: (_, i) => _productTile(products[i], cs),
                );
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  // sort menu item with active checkmark
  PopupMenuItem<_SortMode> _sortItem(_SortMode mode, String label) {
    final isActive = _sortMode == mode;
    return PopupMenuItem<_SortMode>(
      value: mode,
      child: Row(
        children: [
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
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder: (_, scrollController) => Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: EditProductPage(
                product: product,
                scrollController: scrollController,
              ),
            ),
          ),
        );
      },
      child: SizedBox(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Material(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
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
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Text(
                            '${product.quantity}',
                            style: AppTheme.bodyMedium.copyWith(
                              color: _stockColor(product.quantity),
                              fontWeight: FontWeight(1000),
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '₱${product.sellingPrice.toStringAsFixed(2)}',
                          style: AppTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text(
                    product.expiryDate == null
                        ? 'No expiration date'
                        : 'Expiration Date: ${product.expiryDate}',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
