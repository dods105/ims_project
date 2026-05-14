import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'revenue_compute.dart';

class RevenueBreakdownSheet extends StatefulWidget {
  final RevenueResult Function({required bool weekly}) computeRevenue;
  final List<String> weeklyLabels;
  final List<String> monthlyLabels;
  final DateTime? selectedDate;

  const RevenueBreakdownSheet({
    super.key,
    required this.computeRevenue,
    required this.weeklyLabels,
    required this.monthlyLabels,
    required this.selectedDate,
  });

  @override
  State<RevenueBreakdownSheet> createState() => _RevenueBreakdownSheetState();
}

class _RevenueBreakdownSheetState extends State<RevenueBreakdownSheet> {
  bool _weekly = true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final result = widget.computeRevenue(weekly: _weekly);
    final labels = _weekly ? widget.weeklyLabels : widget.monthlyLabels;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, sc) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            // Weekly/Monthly toggle
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Revenue Breakdown",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  _ToggleGroup(
                    weekly: _weekly,
                    onWeekly: () => setState(() => _weekly = true),
                    onMonthly: () => setState(() => _weekly = false),
                  ),
                ],
              ),
            ),

            //date subtitle
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.selectedDate != null
                      ? _weekly
                            ? "Week of ${DateFormat('MMM d').format(widget.selectedDate!)}"
                            : DateFormat(
                                'MMMM yyyy',
                              ).format(widget.selectedDate!)
                      : '',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: ListView(
                controller: sc,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  //revenue rows
                  ...List.generate(labels.length, (i) {
                    final rev = result.revenueByBucket[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 60,
                            child: Text(
                              labels[i],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: result.totalRevenue == 0
                                  ? 0
                                  : (rev / result.totalRevenue).clamp(0.0, 1.0),
                              backgroundColor: cs.primary.withOpacity(0.1),
                              color: cs.primary,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 80,
                            child: Text(
                              rev > 0 ? "₱${rev.toStringAsFixed(2)}" : "—",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: rev > 0
                                    ? Colors.orange[700]
                                    : Colors.grey[400],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const Divider(height: 28),

                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Revenue",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        "₱${result.totalRevenue.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),

                  // No-cost items (no original price)
                  if (result.noCostItems.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Icon(Icons.info_outline, size: 16, color: Colors.grey),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "Items sold without a original price. Revenue is unknown for these:",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...result.noCostItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.circle,
                              size: 6,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: cs.onSurface,
                                ),
                              ),
                            ),
                            Text(
                              "x${item.qty}",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              "₱${item.sales.toStringAsFixed(2)} sales",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//toggle widget

class _ToggleGroup extends StatelessWidget {
  final bool weekly;
  final VoidCallback onWeekly;
  final VoidCallback onMonthly;

  const _ToggleGroup({
    required this.weekly,
    required this.onWeekly,
    required this.onMonthly,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Pill(label: "W", active: weekly, cs: cs, onTap: onWeekly),
          _Pill(label: "M", active: !weekly, cs: cs, onTap: onMonthly),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool active;
  final ColorScheme cs;
  final VoidCallback onTap;

  const _Pill({
    required this.label,
    required this.active,
    required this.cs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.grey,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
