import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../designs/themes.dart';
import '../../providers/purchase_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/inventoryProvider.dart';
import '../../database/database_helper.dart';
import '../../models/purchase/transaction_sale.dart';
import '../../models/purchase/transaction_items.dart';
import '../../models/products/products.dart';
import '../../designs/receipt.dart';

class ListofPurchase extends ConsumerStatefulWidget {
  const ListofPurchase({super.key});

  @override
  ConsumerState<ListofPurchase> createState() => _ListofPurchaseState();
}

class _ListofPurchaseState extends ConsumerState<ListofPurchase> {
  static const double _barcodeColWidth = 92;
  static const double _qtyColWidth = 36;
  static const double _priceColWidth = 82;

  String? transactionId;
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerAddressController =
      TextEditingController();
  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _changeController = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadTransactionId();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerAddressController.dispose();
    _cashController.dispose();
    _changeController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactionId() async {
    final user = ref.read(authProvider).asData?.value;
    if (user != null) {
      final id = await DatabaseHelper.instance.generateTransactionId(user.id!);
      setState(() {
        transactionId = id;
      });
    }
  }

  void _calculateChange() {
    final purchaseState = ref.read(purchaseProvider);
    final cashText = _cashController.text;
    if (cashText.isNotEmpty) {
      final cash = double.tryParse(cashText) ?? 0;
      final change = cash - purchaseState.totalPrice;
      _changeController.text = change >= 0 ? change.toStringAsFixed(2) : '0.00';
    }
  }

  Future<void> _processCheckout() async {
    final purchaseState = ref.read(purchaseProvider);
    final inventoryNotifier = ref.read(inventoryProvider.notifier);
    final db = DatabaseHelper.instance;
    final cs = Theme.of(context).colorScheme;

    if (purchaseState.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No items to checkout'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final cash = double.tryParse(_cashController.text) ?? 0;
    if (cash < purchaseState.totalPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient cash'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final user = ref.read(authProvider).value;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final transaction = TransactionSale(
        id: transactionId,
        userId: user.id!,
        customerName: _customerNameController.text.isNotEmpty
            ? _customerNameController.text
            : null,
        customerAddress: _customerAddressController.text.isNotEmpty
            ? _customerAddressController.text
            : null,
        amountPayed: cash,
        totalAmount: purchaseState.totalPrice,
        changeAmount: cash - purchaseState.totalPrice,
        transactedAt: DateTime.now().toIso8601String(),
      );

      await db.insertTransaction(transaction);

      for (final item in purchaseState.items.values) {
        // original price snapshot at the moment of sale
        final transactionItem = TransactionItems(
          transactionId: transactionId!,
          productsId: item.product.id!,
          name: item.product.name,
          barcode: item.product.barcode,
          unitPrice: item.product.sellingPrice,
          originalPrice: item.product.originalPrice, // snapshot
          quantity: item.quantity,
          subtotal: item.subtotal,
        );
        await db.insertTransactionItem(transactionItem);

        final updatedProduct = Product(
          id: item.product.id,
          userId: item.product.userId,
          name: item.product.name,
          quantity: item.product.quantity - item.quantity,
          sellingPrice: item.product.sellingPrice,
          originalPrice: item.product.originalPrice,
          productType: item.product.productType,
          expiryDate: item.product.expiryDate,
          barcode: item.product.barcode,
          description: item.product.description,
          imagePath: item.product.imagePath,
        );
        await inventoryNotifier.updateProduct(updatedProduct);
      }

      ref.read(purchaseProvider.notifier).clear();

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/inventory',
          ModalRoute.withName('/'),
        );

        // Show receipt dialog
        ShowReceiptBottomSheet(
          context,
          transactionId!,
          purchaseState.items.values.toList(),
          double.tryParse(_cashController.text) ?? 0,
          purchaseState.totalPrice,
          DateTime.now().toIso8601String(),
          _customerNameController.text,
          _customerAddressController.text,
          false,
          cs,
        );

        // Show snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase completed! Receipt saved'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing purchase: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final purchaseState = ref.watch(purchaseProvider);
    final items = purchaseState.items.values.toList();

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(title: const Text('Purchase Summary'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoCard(transactionId ?? "Generating...", cs),
            const SizedBox(height: 12),
            _buildTableHeader(),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: items.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, color: AppTheme.borderDefault),
              itemBuilder: (context, index) {
                final item = items[index];
                final bc = item.product.barcode ?? "—";
                return Material(
                  color: cs.surface,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: _barcodeColWidth,
                          child: Text(
                            bc,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.bodySmall.copyWith(
                              color: cs.onSurface,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              item.product.name,
                              style: AppTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.w500,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: _qtyColWidth,
                          child: Text(
                            "${item.quantity}",
                            textAlign: TextAlign.center,
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: _priceColWidth,
                          child: Text(
                            "₱${item.subtotal.toStringAsFixed(2)}",
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 50),

            _buildTotalSection(
              purchaseState.totalPrice,
              purchaseState.totalItems,
              cs,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String transId, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                "Transaction: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Text(
                  transId,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.brandBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Divider(),
          Row(
            children: [
              const Text(
                "Customer: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: TextField(
                  controller: _customerNameController,
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: "Enter customer name (optional)",
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                "Address: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: TextField(
                  controller: _customerAddressController,
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: "Enter address (optional)",
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    final headerStyle = AppTheme.titleSmall.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
    );
    return Container(
      color: AppTheme.brandBlue,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Row(
        children: [
          SizedBox(
            width: _barcodeColWidth,
            child: Text(
              "Ref. No.",
              style: headerStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              "Name",
              style: headerStyle,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: _qtyColWidth,
            child: Text("Qty", style: headerStyle, textAlign: TextAlign.center),
          ),
          SizedBox(
            width: _priceColWidth,
            child: Text(
              "Price",
              style: headerStyle,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _underlineFieldDecoration({String? prefix}) {
    return InputDecoration(
      isDense: true,
      prefixText: prefix,
      prefixStyle: AppTheme.bodyMedium.copyWith(
        color: AppTheme.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: AppTheme.grey300),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppTheme.grey300),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppTheme.brandBlue, width: 1.5),
      ),
      contentPadding: const EdgeInsets.only(bottom: 4),
    );
  }

  Widget _buildTotalSection(double total, int totalItems, ColorScheme cs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "TOTAL:",
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "₱${total.toStringAsFixed(2)}",
                      textAlign: TextAlign.right,
                      style: AppTheme.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Divider(height: 1, thickness: 1),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                "NO. OF ITEMS:",
                style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                "$totalItems",
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 88,
                child: Text(
                  "CASH:",
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _cashController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: AppTheme.bodyMedium,
                  onChanged: (_) => _calculateChange(),
                  decoration: _underlineFieldDecoration(prefix: "₱ "),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 88,
                child: Text(
                  "CHANGE:",
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _changeController,
                  readOnly: true,
                  style: AppTheme.bodyMedium,
                  decoration: _underlineFieldDecoration(prefix: "₱ "),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _processCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.brandBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isProcessing
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.primary,
                      ),
                    )
                  : Text(
                      "CHECKOUT",
                      style: AppTheme.titleSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
