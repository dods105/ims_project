import 'dart:io';
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
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _filterProducts(List<Product> products) {
    if (_query.isEmpty) return products;
    return products.where((p) {
      return p.name.toLowerCase().contains(_query) ||
          (p.barcode ?? '').toLowerCase().contains(_query);
    }).toList();
  }

  void _showQuantityModal(
    Product product,
    int initialQty,
    Function(int) onConfirm,
  ) {
    int quantity = initialQty.clamp(1, product.quantity);
    final qtyController = TextEditingController(text: quantity.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void updateQuantity(int newQty) {
              final clamped = newQty.clamp(1, product.quantity);
              if (clamped != quantity) {
                quantity = clamped;
                qtyController.text = quantity.toString();
                setModalState(() {});
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Product info row
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 52,
                            height: 52,
                            color: Theme.of(context).colorScheme.outline,
                            child:
                                product.imagePath != null &&
                                    File(product.imagePath!).existsSync()
                                ? Image.file(
                                    File(product.imagePath!),
                                    fit: BoxFit.cover,
                                  )
                                : Icon(
                                    Icons.photo,
                                    size: 32,
                                    color: AppTheme.textMuted,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: AppTheme.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '₱${product.sellingPrice.toStringAsFixed(2)} per item',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.brandBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Stock: ${product.quantity}',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.brandBlueDeep,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // Quantity row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _QtyButton(
                          icon: Icons.remove,
                          enabled: quantity > 1,
                          onTap: () => updateQuantity(quantity - 1),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 72,
                          child: TextField(
                            controller: qtyController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onChanged: (value) {
                              final parsed = int.tryParse(value);
                              if (parsed == null) return;
                              if (parsed < 1) {
                                updateQuantity(1);
                              } else if (parsed > product.quantity) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Only ${product.quantity} in stock. Quantity set to maximum.',
                                    ),
                                    backgroundColor: Colors.orange[700],
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                updateQuantity(product.quantity);
                              } else {
                                updateQuantity(parsed);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        _QtyButton(
                          icon: Icons.add,
                          enabled: quantity < product.quantity,
                          onTap: () => updateQuantity(quantity + 1),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Subtotal chip
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.brandBlue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtotal',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textMuted,
                            ),
                          ),
                          Text(
                            '₱${(product.sellingPrice * quantity).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.brandBlue,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              onConfirm(quantity);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.brandBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Confirm'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final inventoryState = ref.watch(inventoryProvider);
    final purchaseState = ref.watch(purchaseProvider);
    final purchaseNotifier = ref.read(purchaseProvider.notifier);

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBarDesign(page: 'Purchase'),
      endDrawer: AppDrawer(page: '/purchase'),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  prefixIcon: Icon(Icons.search, color: AppTheme.textMuted),
                  suffixIcon: GestureDetector(
                    onTap: () async {
                      await Future.delayed(const Duration(milliseconds: 150));
                      if (!context.mounted) return;
                      final scanned = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => BarcodeScannerPage()),
                      );
                      if (!context.mounted) return;
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

          // Product list
          Expanded(
            child: inventoryState.when(
              data: (data) {
                final allProducts = _filterProducts(data.products);

                final selectedProducts = <Product>[];
                final availableProducts = <Product>[];
                final outOfStockProducts = <Product>[];

                for (final product in allProducts) {
                  if (purchaseState.items.containsKey(product.id)) {
                    selectedProducts.add(product);
                  } else if (product.quantity <= 0) {
                    outOfStockProducts.add(product);
                  } else {
                    availableProducts.add(product);
                  }
                }

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
                          'No products available',
                          style: AppTheme.titleMedium.copyWith(
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (allProducts.isEmpty) {
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

                return ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  children: [
                    if (selectedProducts.isNotEmpty) ...[
                      _sectionHeader(
                        'SELECTED (${selectedProducts.length})',
                        AppTheme.brandBlue,
                      ),
                      ...selectedProducts.map(
                        (product) => _buildProductTile(
                          product,
                          isSelected: true,
                          selectedQuantity:
                              purchaseState.items[product.id!]?.quantity ?? 1,
                          purchaseNotifier: purchaseNotifier,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    if (availableProducts.isNotEmpty) ...[
                      _sectionHeader(
                        'AVAILABLE (${availableProducts.length})',
                        cs.primary,
                      ),
                      ...availableProducts.map(
                        (product) => _buildProductTile(
                          product,
                          isSelected: false,
                          selectedQuantity: 1,
                          purchaseNotifier: purchaseNotifier,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    if (outOfStockProducts.isNotEmpty) ...[
                      _sectionHeader(
                        'OUT OF STOCK (${outOfStockProducts.length})',
                        cs.primary.withOpacity(0.7),
                      ),
                      ...outOfStockProducts.map(
                        (product) => _buildProductTile(
                          product,
                          isSelected: false,
                          selectedQuantity: 1,
                          purchaseNotifier: purchaseNotifier,
                          isOutOfStock: true,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),

          // Bottom bar
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
                                builder: (_) => ListofPurchase(),
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

  Widget _sectionHeader(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        label,
        style: AppTheme.titleSmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProductTile(
    Product product, {
    required bool isSelected,
    required int selectedQuantity,
    required dynamic purchaseNotifier,
    bool isOutOfStock = false,
  }) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: isOutOfStock
          ? null
          : () {
              final currentQty = isSelected ? selectedQuantity : 1;
              _showQuantityModal(product, currentQty, (int newQuantity) {
                purchaseNotifier.addProduct(product, newQuantity);
                setState(() {});
              });
            },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isOutOfStock
              ? cs.outline
              : (isSelected
                    ? AppTheme.brandBlue.withOpacity(0.04)
                    : cs.surface),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.brandBlue : cs.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: cs.outline,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    product.imagePath != null &&
                        File(product.imagePath!).existsSync()
                    ? Image.file(
                        File(product.imagePath!),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      )
                    : Icon(Icons.photo, size: 40, color: AppTheme.textMuted),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isOutOfStock ? Colors.grey : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    if (!isSelected) ...[
                      Text(
                        isOutOfStock
                            ? 'Out of Stock'
                            : 'Stock: ${product.quantity}',
                        style: AppTheme.bodySmall.copyWith(
                          color: isOutOfStock
                              ? AppTheme.brandBlueDeep
                              : AppTheme.brandBlue,
                          fontWeight: isOutOfStock
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₱${product.sellingPrice.toStringAsFixed(2)}',
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isOutOfStock
                              ? Colors.grey
                              : AppTheme.brandBlue,
                        ),
                      ),
                    ] else
                      Text(
                        'No. of Item: $selectedQuantity\n₱${(product.sellingPrice * selectedQuantity).toStringAsFixed(2)}',
                        style: AppTheme.bodyMedium.copyWith(color: cs.primary),
                      ),
                  ],
                ),
              ),
            ),

            SizedBox(
              width: 52,
              child: Center(
                child: isOutOfStock
                    ? IgnorePointer(
                        child: Checkbox(
                          value: false,
                          onChanged: null,

                          side: BorderSide(
                            color: Colors.grey[400]!,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      )
                    : Checkbox(
                        value: isSelected,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: isSelected
                            ? (_) {
                                purchaseNotifier.removeProduct(product.id!);
                                setState(() {});
                              }
                            : null,
                        activeColor: AppTheme.brandBlue,
                        checkColor: Colors.white,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled
              ? AppTheme.brandBlue.withOpacity(0.12)
              : AppTheme.borderBlue.withOpacity(0.2),
        ),
        child: Icon(
          icon,
          size: 22,
          color: enabled ? AppTheme.brandBlue : Colors.grey,
        ),
      ),
    );
  }
}
