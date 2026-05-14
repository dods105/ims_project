import 'package:flutter/material.dart';
import 'package:flutter_application_1/designs/receipt.dart';
import 'package:intl/intl.dart';
import '../../models/purchase/transaction_sale.dart';
import '../../models/purchase/transaction_items.dart';

//Summary card

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final Color? valueColor;
  final VoidCallback? onTap;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    this.color,
    this.textColor,
    this.icon,
    this.valueColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null)
              Icon(
                icon,
                size: 18,
                color: textColor?.withOpacity(.7) ?? Colors.grey,
              ),
            if (title.isNotEmpty)
              Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor?.withOpacity(.9) ?? Colors.grey,
                  fontSize: 12,
                ),
              ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? textColor ?? Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor?.withOpacity(.9) ?? Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Tab button (Weekly / Monthly toggle)

class HistoryTabButton extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback onTap;

  const HistoryTabButton({
    super.key,
    required this.text,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: active ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

//bar chart

class HistoryBar extends StatelessWidget {
  final double value;
  final double maxValue;
  final double barWidth;
  final String label;
  final String topLabel;
  final bool isActive;

  const HistoryBar({
    super.key,
    required this.value,
    required this.maxValue,
    required this.barWidth,
    required this.label,
    required this.topLabel,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const double maxBarHeight = 100.0;
    final double barHeight = maxValue == 0
        ? 5.0
        : (value / maxValue) * maxBarHeight;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          topLabel,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? cs.primary : cs.secondary,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: barWidth,
          height: barHeight.clamp(5.0, maxBarHeight),
          decoration: BoxDecoration(
            color: isActive ? cs.primary : cs.secondary,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

// Transaction list and grand total

class TransactionList extends StatelessWidget {
  final List<TransactionSale> transactions;
  final double grandTotal;
  final DateTime? selectedDate;
  final Map<String, int> itemCounts;
  final Future<void> Function(String transactionId) onTapTransaction;
  final List<TransactionItems> transactionItems;

  const TransactionList({
    super.key,
    required this.transactions,
    required this.grandTotal,
    required this.selectedDate,
    required this.itemCounts,
    required this.onTapTransaction,
    required this.transactionItems,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Transactions (${transactions.length})",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              selectedDate != null
                  ? DateFormat('MMM d').format(selectedDate!)
                  : "Today",
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Empty state
        if (transactions.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: const [
                  Icon(Icons.receipt_long, size: 48),
                  SizedBox(height: 16),
                  Text('No transactions found', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text(
                    'Try selecting a different date',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final trans = transactions[index];
              final transDate = DateTime.tryParse(trans.transactedAt);

              return GestureDetector(
                onTap: () async {
                  await onTapTransaction(trans.id!);
                  if (context.mounted) {
                    ShowReceiptBottomSheet(
                      context,
                      trans.id!,
                      transactionItems,
                      trans.amountPayed,
                      trans.totalAmount,
                      trans.transactedAt,
                      trans.customerName,
                      trans.customerAddress,
                      true,
                      cs,
                    );
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: cs.primary.withOpacity(0.1),
                        child: Icon(Icons.payments_outlined, color: cs.primary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trans.id ?? "",
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              transDate != null
                                  ? DateFormat('hh:mm a').format(transDate)
                                  : "",
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "${itemCounts[trans.id!] ?? 0} item(s)",
                              style: TextStyle(
                                color: cs.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "₱${trans.totalAmount.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: cs.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.receipt_long, size: 14),
                              SizedBox(width: 4),
                              Text("Receipt", style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

        const SizedBox(height: 10),

        // Grand total
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  "GRAND TOTAL",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "₱${grandTotal.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
