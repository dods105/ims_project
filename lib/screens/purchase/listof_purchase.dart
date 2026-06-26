import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../designs/themes.dart';
import '../../providers/purchase_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/inventoryProvider.dart';
import '../../database/database_helper.dart';
import '../../models/purchase/transaction_sale.dart';
import '../../models/purchase/transaction_items.dart';
import '../../designs/receipt.dart';

//the checkout summary screen
//shows everything the user picked
// in PurchaseSection, lets them enter cash paid and optional customer details, then finalizes the sale when they tap Checkout.
class ListofPurchase extends ConsumerStatefulWidget {
  const ListofPurchase({super.key});

  @override
  ConsumerState<ListofPurchase> createState() => _ListofPurchaseState();
}

class _ListofPurchaseState extends ConsumerState<ListofPurchase> {
  // fixed column widths for the item tabl
  static double _barcodeColWidth = 92;
  static double _qtyColWidth = 36;
  static double _priceColWidth = 82;

  String? transactionId;
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerAddressController =
      TextEditingController();
  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _changeController = TextEditingController();
  bool _isProcessing = false; // disables the checkout button while saving

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

  // generates a new transaction ID for receipt, before the user even hits checkout
  Future<void> _loadTransactionId() async {
    final user = ref.read(authProvider).asData?.value;
    if (user != null) {
      final id = await DatabaseHelper.instance.generateTransactionId(user.id!);
      setState(() {
        transactionId = id;
      });
    }
  }

  // recalculates change live as the cashier types in the cash amount
  void _calculateChange() {
    final purchaseState = ref.read(purchaseProvider);
    final cashText = _cashController.text;
    if (cashText.isNotEmpty) {
      final cash = double.tryParse(cashText) ?? 0;
      final change = cash - purchaseState.totalPrice;
      // never show a negative change, just 0 until enough cash is entered
      _changeController.text = change >= 0 ? change.toStringAsFixed(2) : '0.00';
    }
  }

  //validates cash amount, writes the transaction anf items to the DB, refreshes inventory, clears the cart, and shows the receipt
  Future<void> _processCheckout() async {
    final purchaseState = ref.read(purchaseProvider);
    final db = DatabaseHelper.instance;
    final cs = Theme.of(context).colorScheme;

    if (purchaseState.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No items to checkout'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final cash = double.tryParse(_cashController.text) ?? 0;
    if (cash < purchaseState.totalPrice) {
      // covers both "field was empty" and "not enough cash" as message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _cashController.text.trim().isEmpty
                ? 'Please enter the cash amount'
                : 'Cash amount is less than the total (₱${purchaseState.totalPrice.toStringAsFixed(2)})',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final user = ref.read(authProvider).value;
      if (user == null) throw Exception('User not authenticated');

      if (transactionId == null) {
        _loadTransactionId();
      }

      final receiptItems = purchaseState.items.values.toList();
      final receiptTotal = purchaseState.totalPrice;
      final receiptCash = cash;
      final receiptTxnId = transactionId!;
      final receiptCustomer = _customerNameController.text;
      final receiptAddress = _customerAddressController.text;
      final receiptTime = DateTime.now().toIso8601String();

      final transaction = TransactionSale(
        id: receiptTxnId,
        userId: user.id!,
        customerName: receiptCustomer.isNotEmpty ? receiptCustomer : null,
        customerAddress: receiptAddress.isNotEmpty ? receiptAddress : null,
        amountPayed: receiptCash,
        totalAmount: receiptTotal,
        changeAmount: receiptCash - receiptTotal,
        transactedAt: receiptTime,
      );

      final transactionItems = receiptItems
          .map(
            (item) => TransactionItems(
              transactionId: receiptTxnId,
              productsId: item.product.id!,
              name: item.product.name,
              barcode: item.product.barcode,
              unitPrice: item.product.sellingPrice,
              originalPrice: item.product.originalPrice,
              quantity: item.quantity,
              subtotal: item.subtotal,
            ),
          )
          .toList();

      // double-checks stock is still sufficient, deducts inventory, and writes all the line items
      await db.checkoutTransaction(
        transaction: transaction,
        items: transactionItems,
      );

      await ref.read(inventoryProvider.notifier).refresh();

      // empty the cart after purchase
      ref.read(purchaseProvider.notifier).clear();

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/purchase',
          ModalRoute.withName('/'),
        );

        ShowReceiptBottomSheet(
          context,
          receiptTxnId,
          receiptItems,
          receiptCash,
          receiptTotal,
          receiptTime,
          receiptCustomer,
          receiptAddress,
          false,
          cs,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase completed! Receipt saved'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on InsufficientStockException catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Stock Unavailable'),
            content: Text(
              '"${e.productName}" only has ${e.available} unit(s) left, '
              'but ${e.requested} were requested.\n\n'
              'Please update the quantity and try again.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
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
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final purchaseState = ref.watch(purchaseProvider);
    final items = purchaseState.items.values.toList();

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(title: Text('Purchase Summary'), elevation: 0),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoCard(transactionId ?? "Generating...", cs),
            SizedBox(height: 12),
            _buildTableHeader(),

            // list of cart items
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
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
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

                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
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

  // card up top showing the transaction id plus optional customer name/address
  Widget _buildInfoCard(String transId, ColorScheme cs) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
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
          Divider(),
          Row(
            children: [
              Text("Customer: ", style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: TextField(
                  controller: _customerNameController,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: "Enter customer name (optional)",
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Text("Address: ", style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: TextField(
                  controller: _customerAddressController,
                  decoration: InputDecoration(
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

  // header row for the items table bar with column labels
  Widget _buildTableHeader() {
    final headerStyle = AppTheme.titleSmall.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
    );
    return Container(
      color: AppTheme.brandBlue,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Column(
        children: [
          Container(
            width: MediaQuery.widthOf(context),
            decoration: BoxDecoration(
              border: BorderDirectional(
                bottom: BorderSide(color: AppTheme.appBackground),
              ),
            ),
            child: Center(
              child: Text(
                "List of Purchase",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),

          Row(
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
                child: Text(
                  "Qty",
                  style: headerStyle,
                  textAlign: TextAlign.center,
                ),
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
        ],
      ),
    );
  }

  // shared underline style decoration used by the cash/change fields below
  InputDecoration divider({String? prefix}) {
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
      contentPadding: EdgeInsets.only(bottom: 4),
    );
  }

  // total, item count, cash input, change (calculated automatically) and the Checkout button
  Widget _buildTotalSection(double total, int totalItems, ColorScheme cs) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, 18, 16, 16),
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
              SizedBox(width: 12),
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
                    SizedBox(height: 2),
                    Divider(height: 1, thickness: 1),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Text(
                "NO. OF ITEMS:",
                style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w700),
              ),
              Spacer(),
              Text(
                "$totalItems",
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
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
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: AppTheme.bodyMedium,

                  onChanged: (_) => _calculateChange(),
                  decoration: divider(prefix: "₱ "),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
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
                  decoration: divider(prefix: "₱ "),
                ),
              ),
            ],
          ),
          SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _processCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.brandBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 15),
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
