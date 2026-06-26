import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/purchase_provider.dart';
import '../designs/themes.dart';

// Shows the receipt as a bottom sheet after a purchase is confirmed.
class ShowReceiptBottomSheet {
  ShowReceiptBottomSheet(
    BuildContext context,
    String transactionId,
    List<dynamic> items,
    double cashPaid,
    double totalAmount,
    String dateTime,
    String? customerName,
    String? customerAddress,
    bool drag,
    ColorScheme cs,
  ) {
    final change = cashPaid - totalAmount;

    showModalBottomSheet(
      context: context,
      enableDrag: drag,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        width: double.infinity,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Receipt content
            Text(
              'DIGITAL RECEIPT',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),

            SizedBox(height: 15),

            //the receipt card box and scrollable if item list is too long to fit.
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.secondary.withOpacity(0.8)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 15),

                      // Transaction details
                      //top section are receipt number, date/time, and customer info if it was provided (both are optional fields).
                      Column(
                        children: [
                          _buildDetailRow('Receipt No.', transactionId),
                          SizedBox(height: 8),
                          _buildDetailRow('Date', _formatDate(dateTime)),
                          SizedBox(height: 8),
                          _buildDetailRow('Time', _formatTime(dateTime)),
                          if (customerName != null &&
                              customerName.isNotEmpty) ...[
                            SizedBox(height: 8),
                            _buildDetailRow('Customer Name', customerName),
                          ],
                          if (customerAddress != null &&
                              customerAddress.isNotEmpty) ...[
                            SizedBox(height: 8),
                            _buildDetailRow(
                              'Customer Address',
                              customerAddress,
                            ),
                          ],
                        ],
                      ),

                      Divider(),

                      // Items section
                      // list of items purchased, one row each
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ITEMS',
                            style: AppTheme.titleSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          ...items.map((item) => _buildItemRow(item)),
                        ],
                      ),

                      Divider(),

                      // Payment summary
                      Column(
                        children: [
                          SizedBox(height: 8),

                          _buildPaymentRow(
                            'TOTAL',
                            totalAmount,
                            fontSize: 18,
                            isBold: true,
                            color: cs.primary,
                          ),
                          _buildPaymentRow('Cash Paid', cashPaid),
                          Divider(),
                          _buildPaymentRow('Change', change, isBold: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Close button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,

                  backgroundColor: cs.primary,
                ),
                child: Text(
                  'Close',
                  style: AppTheme.titleMedium.copyWith(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildItemRow(item) {
    final itemName = item.runtimeType == PurchaseItem
        ? item.product.name
        : item.name;
    final quantity = item.quantity;
    final subtotal = item.subtotal;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              itemName,
              style: AppTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              'x$quantity',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textMuted),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              '₱${subtotal.toStringAsFixed(2)}',
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(
    String label,
    double value, {
    double fontSize = 14,
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,

            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '₱${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: fontSize,
            color: color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateTime) {
    try {
      final date = DateTime.parse(dateTime);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateTime.substring(0, 10);
    }
  }

  String _formatTime(String dateTime) {
    try {
      final date = DateTime.parse(dateTime);
      return DateFormat('hh:mm a').format(date);
    } catch (e) {
      return dateTime.substring(11, 16);
    }
  }
}
