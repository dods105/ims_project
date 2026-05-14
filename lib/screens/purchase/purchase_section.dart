import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../designs/appbar.dart';
import '../../designs/barcode_scanner_page.dart';
import '../../designs/drawer.dart';
import '../../designs/themes.dart';
import '../../models/products/products.dart';
import '../../providers/inventoryProvider.dart';
import '../../providers/purchase_provider.dart';
import 'listof_purchase.dart';

class PurchaseSection extends ConsumerStatefulWidget {
  const PurchaseSection({super.key});

  @override
  ConsumerState<PurchaseSection> createState() => PurchaseSectionState();
}

class PurchaseSectionState extends ConsumerState<PurchaseSection> {
  final TextEditingController _searchController = TextEditingController();
  final Map<int, TextEditingController> _quantityControllers = {};
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    for (final c in _quantityControllers.values) {
      c.dispose();
    }
    _quantityControllers.clear();
    _searchController.dispose();
    super.dispose();
  }

  TextEditingController _qtyControllerFor(int productId, int initialQty) {
    return _quantityControllers.putIfAbsent(
      productId,
      () => TextEditingController(text: '$initialQty'),
    );
  }

  void _removeQtyController(int productId) {
    _quantityControllers.remove(productId)?.dispose();
  }

  void _setQuantity(Product product, int qty) {
    final clamped = qty.clamp(1, product.quantity);
    ref.read(purchaseProvider.notifier).updateQuantity(product.id!, clamped);
    final c = _quantityControllers[product.id!];
    if (c != null && c.text != '$clamped') {
      c.text = '$clamped';
    }
  }

  void _onQtyTextChanged(Product product, String raw) {
    if (raw.isEmpty) return;
    final parsed = int.tryParse(raw);
    if (parsed == null) return;
    final clamped = parsed.clamp(1, product.quantity);
    if (clamped != parsed) {
      final c = _quantityControllers[product.id!]!;
      c.text = '$clamped';
      c.selection = TextSelection.collapsed(offset: c.text.length);
    }
    ref.read(purchaseProvider.notifier).updateQuantity(product.id!, clamped);
  }

  List<Product> _filterProducts(List<Product> products) {
    if (_query.isEmpty) return products;
    return products.where((p) {
      return p.name.toLowerCase().contains(_query) ||
          (p.barcode ?? '').toLowerCase().contains(_query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final inventoryState = ref.watch(inventoryProvider);
    final purchaseState = ref.watch(purchaseProvider);
    final purchaseNotifier = ref.read(purchaseProvider.notifier);

    return Scaffold(
      backgroundColor: cs.background,
      appBar: const AppBarDesign(page: 'Purchase'),
      endDrawer: const AppDrawer(page: '/purchase'),

      body: Column(
        children: [
          const SizedBox(height: 16),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                            await Future.delayed(
                              const Duration(milliseconds: 150),
                            );
                            if (!context.mounted) return;
                            final scanned = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const BarcodeScannerPage(),
                              ),
                            );
                            if (!context.mounted) return;
                            if (scanned != null) {
                              _searchController.text = scanned;
                            }
                          },
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
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Column headers
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Product Name',
                    style: AppTheme.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Price',
                    style: AppTheme.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Stock',
                    style: AppTheme.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    'Sell',
                    style: AppTheme.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Product list
          Expanded(
            child: inventoryState.when(
              data: (data) {
                final products = _filterProducts(data.products);

                if (data.products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          'No products available',
                          style: AppTheme.titleMedium.copyWith(),
                        ),
                      ],
                    ),
                  );
                }

                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: AppTheme.textMuted,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: AppTheme.titleMedium.copyWith(
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final isSelected = purchaseState.items.containsKey(
                      product.id,
                    );
                    final lineQty = isSelected
                        ? purchaseState.items[product.id!]!.quantity
                        : 1;
                    final qtyCtrl = isSelected
                        ? _qtyControllerFor(product.id!, lineQty)
                        : null;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? cs.primary : cs.outline,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  child: Text(
                                    product.name,
                                    style: AppTheme.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '₱${product.sellingPrice.toStringAsFixed(2)}',
                                  style: AppTheme.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '${product.quantity}',
                                  style: AppTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(
                                width: 52,
                                child: Center(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Checkbox(
                                      value: isSelected,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),

                                      onChanged: product.quantity <= 0
                                          ? null
                                          : (bool? value) {
                                              if (value == true) {
                                                purchaseNotifier.addProduct(
                                                  product,
                                                  1,
                                                );
                                                _qtyControllerFor(
                                                  product.id!,
                                                  1,
                                                );
                                              } else {
                                                purchaseNotifier.removeProduct(
                                                  product.id!,
                                                );
                                                _removeQtyController(
                                                  product.id!,
                                                );
                                              }
                                              setState(() {});
                                            },
                                      activeColor: AppTheme.brandBlue,
                                      checkColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (isSelected && qtyCtrl != null) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: cs.outline,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: cs.outlineVariant),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Quantity',
                                          style: AppTheme.bodyMedium.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          onPressed: lineQty > 1
                                              ? () {
                                                  _setQuantity(
                                                    product,
                                                    lineQty - 1,
                                                  );
                                                  setState(() {});
                                                }
                                              : null,
                                          icon: Icon(
                                            Icons.remove_circle_outline,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 56,
                                          child: TextField(
                                            controller: qtyCtrl,
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.center,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                            ],
                                            style: AppTheme.bodyMedium.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                            decoration: InputDecoration(
                                              isDense: true,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                    horizontal: 6,
                                                  ),
                                              filled: true,
                                              fillColor: cs.surface,
                                            ),

                                            onChanged: (v) {
                                              _onQtyTextChanged(product, v);
                                              setState(() {});
                                            },
                                            onEditingComplete: () {
                                              final s = qtyCtrl.text.trim();
                                              if (s.isEmpty ||
                                                  int.tryParse(s) == null) {
                                                _setQuantity(product, 1);
                                                setState(() {});
                                              }
                                            },
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: lineQty < product.quantity
                                              ? () {
                                                  _setQuantity(
                                                    product,
                                                    lineQty + 1,
                                                  );
                                                  setState(() {});
                                                }
                                              : null,
                                          icon: Icon(Icons.add_circle_outline),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Text(
                                          'Total Price',
                                          style: AppTheme.bodyMedium.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: cs.surface,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            '₱${(product.sellingPrice * lineQty).toStringAsFixed(2)}',
                                            style: AppTheme.bodyMedium.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.brandBlue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),

          // Bottom bar (total, item count, confirm)
          Container(
            color: cs.surface,

            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SafeArea(
                top: false,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Total: ₱${purchaseState.totalPrice.toStringAsFixed(2)}',
                            style: AppTheme.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'No. of Items: ${purchaseState.totalItems}',
                            style: AppTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: purchaseState.items.isEmpty
                          ? null
                          : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ListofPurchase(),
                              ),
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.brandBlue,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: cs.outline,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Confirm',
                        style: AppTheme.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
