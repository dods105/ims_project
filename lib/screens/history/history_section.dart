import 'package:flutter/material.dart';
import 'package:flutter_application_1/designs/receipt.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../designs/drawer.dart';
import '../../designs/appbar.dart';
import '../../providers/auth_provider.dart';
import '../../providers/purchase_provider.dart';
import '../../database/database_helper.dart';
import '../../models/purchase/transaction_sale.dart';
import '../../models/purchase/transaction_items.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  bool isWeeklyActive = true;
  List<TransactionSale> _transactions = [];
  List<TransactionItems> _transactionItems = [];
  bool _isLoading = true;
  Map<String, int> _itemCounts = {};

  // Weekly chart: index 0=Mon … 6=Sun  (weekday 1..7 → index 0..6)
  List<double> _weeklyData = [0, 0, 0, 0, 0, 0, 0];
  // Monthly chart: index 0..4 = Week 1..5
  List<double> _monthlyData = [0, 0, 0, 0, 0];

  final List<String> weeklyLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  final List<String> monthlyLabels = [
    'Week 1',
    'Week 2',
    'Week 3',
    'Week 4',
    'Week 5',
  ];

  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      final user = ref.read(authProvider).value;
      if (user != null) {
        final transactions = await DatabaseHelper.instance
            .getTransactionsByUser(user.id!);

        // Preload item counts for all transactions
        final Map<String, int> counts = {};
        for (final transaction in transactions) {
          if (transaction.id != null) {
            counts[transaction.id!] = await DatabaseHelper.instance
                .getItemCount(transaction.id!);
          }
        }

        _calculateChartData(transactions);
        setState(() {
          _transactions = transactions;
          _itemCounts = counts;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading transactions: $e');
      setState(() => _isLoading = false);
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading transactions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _calculateChartData(List<TransactionSale> transactions) {
    final dateToUse = _selectedDate ?? DateTime.now();

    //  Weekly: Mon-Sun of the chosen date's ISO week
    // weekday: Mon=1 … Sun=7
    final startOfWeek = dateToUse.subtract(
      Duration(days: dateToUse.weekday - 1),
    );
    // endOfWeek is the Sunday (inclusive)
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    // Monthly: full calendar month of chosen date
    final startOfMonth = DateTime(dateToUse.year, dateToUse.month, 1);
    final endOfMonth = DateTime(dateToUse.year, dateToUse.month + 1, 0);

    _weeklyData = [0, 0, 0, 0, 0, 0, 0];
    _monthlyData = [0, 0, 0, 0, 0];

    for (final trans in transactions) {
      final transDate = DateTime.tryParse(trans.transactedAt);
      if (transDate == null) continue;

      final onlyDate = DateTime(transDate.year, transDate.month, transDate.day);

      // Weekly bucket  (Mon=index 0 … Sun=index 6)
      final startOfWeekDate = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day,
      );
      final endOfWeekDate = DateTime(
        endOfWeek.year,
        endOfWeek.month,
        endOfWeek.day,
      );
      if (!onlyDate.isBefore(startOfWeekDate) &&
          !onlyDate.isAfter(endOfWeekDate)) {
        final dayIndex = transDate.weekday - 1; // Mon=0 … Sun=6
        _weeklyData[dayIndex] += trans.totalAmount;
      }

      // Monthly bucket  (week-of-month index 0..4)
      final startOfMonthDate = DateTime(
        startOfMonth.year,
        startOfMonth.month,
        startOfMonth.day,
      );
      final endOfMonthDate = DateTime(
        endOfMonth.year,
        endOfMonth.month,
        endOfMonth.day,
      );
      if (!onlyDate.isBefore(startOfMonthDate) &&
          !onlyDate.isAfter(endOfMonthDate)) {
        final weekIndex = ((transDate.day - 1) / 7).floor().clamp(0, 4);
        _monthlyData[weekIndex] += trans.totalAmount;
      }
    }
  }

  Future<void> _loadTransactionItems(String transactionId) async {
    try {
      final items = await DatabaseHelper.instance.getTransactionItems(
        transactionId,
      );
      setState(() => _transactionItems = items);
    } catch (e) {
      setState(() => _transactionItems = []);
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
        _calculateChartData(_transactions);
      });
    }
  }

  List<TransactionSale> _getFilteredTransactions() {
    return _transactions.where((t) {
      final transDate = DateTime.tryParse(t.transactedAt);
      if (transDate == null || _selectedDate == null) return false;
      return transDate.year == _selectedDate!.year &&
          transDate.month == _selectedDate!.month &&
          transDate.day == _selectedDate!.day;
    }).toList();
  }

  /// Returns true when [barIndex] represents the current day (weekly view)
  /// or current week-of-month (monthly view).
  bool _isCurrentBar(int barIndex) {
    final now = DateTime.now();
    if (isWeeklyActive) {
      // barIndex 0=Mon … 6=Sun; weekday 1=Mon … 7=Sun
      return barIndex == now.weekday - 1;
    } else {
      final currentWeekIndex = ((now.day - 1) / 7).floor().clamp(0, 4);
      return barIndex == currentWeekIndex;
    }
  }

  /// Format a value: ≥1000 → "1.2K", else "123"
  String _formatBarLabel(double value) {
    if (value <= 0) return '';
    if (value >= 1000) {
      final k = value / 1000;
      // Show one decimal only when needed (e.g. 1.2K not 1.0K)
      return k == k.truncateToDouble()
          ? '${k.toInt()}K'
          : '${k.toStringAsFixed(1)}K';
    }
    return value.toInt().toString();
  }

  // UI helpers

  List<Widget> _buildTransactions(
    List<TransactionSale> transactions,
    double grandTotal,
    ColorScheme cs,
  ) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Transactions (${transactions.length})",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            _selectedDate != null
                ? DateFormat('MMM d').format(_selectedDate!)
                : "Today",
          ),
        ],
      ),
      const SizedBox(height: 16),
      if (transactions.isEmpty)
        Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(Icons.receipt_long, size: 48),
                const SizedBox(height: 16),
                Text('No transactions found', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
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
                await _loadTransactionItems(trans.id!);
                ShowReceiptBottomSheet(
                  context,
                  trans.id!,
                  _transactionItems,
                  trans.amountPayed,
                  trans.totalAmount,
                  trans.transactedAt,
                  trans.customerName,
                  trans.customerAddress,
                  true,
                  cs,
                );
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
                          Wrap(
                            spacing: 8,
                            children: [
                              Text(
                                "${_itemCounts[trans.id!] ?? 0} item(s)",
                                style: TextStyle(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
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
    ];
  }

  static Widget _summaryCard({
    required String title,
    required String value,
    required String subtitle,
    Color? color,
    Color? textColor,
    IconData? icon,
    Color? valueColor,
  }) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) Icon(icon, size: 18),
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
    );
  }

  Widget _tabButton({
    required String text,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF2F5BEA) : Colors.transparent,
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

  /// Builds one bar with calculated width to fit container perfectly.
  Widget _buildBarWithWidth(
    int index,
    double value,
    double maxValue,
    double barWidth,
    ColorScheme cs,
  ) {
    const double maxBarHeight = 100.0;
    final double barHeight = maxValue == 0
        ? 5.0
        : (value / maxValue) * maxBarHeight;
    final bool isActive = _isCurrentBar(index);
    final String label = isWeeklyActive
        ? weeklyLabels[index]
        : monthlyLabels[index];
    final String topLabel = _formatBarLabel(value);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Value label on top of bar
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
        Text(
          label,
          style: TextStyle(
            color: Colors.grey,
            fontSize: isWeeklyActive ? 12 : 13,
            fontWeight: isWeeklyActive ? FontWeight.normal : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(purchaseProvider);
    final cs = Theme.of(context).colorScheme;
    final filteredTransactions = _getFilteredTransactions();
    final grandTotal = filteredTransactions.fold(
      0.0,
      (sum, t) => sum + t.totalAmount,
    );

    // Weekly total for the selected date's week
    final weeklyTotal = _weeklyData.fold(0.0, (a, b) => a + b);

    // Monthly total = sum of all weekly buckets for the selected month
    final selectedMonthTotal = _monthlyData.fold(0.0, (a, b) => a + b);

    final chartData = isWeeklyActive ? _weeklyData : _monthlyData;
    final maxValue = chartData.isEmpty
        ? 1.0
        : chartData.reduce((a, b) => a > b ? a : b);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: cs.background,
        appBar: AppBarDesign(page: 'Daily Sales'),
        endDrawer: const AppDrawer(page: '/history'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBarDesign(page: 'Daily Sales'),
      endDrawer: const AppDrawer(page: '/history'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// DATE SECTION
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Viewing",
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedDate != null
                              ? DateFormat(
                                  'EEEE, MMMM d, yyyy',
                                ).format(_selectedDate!)
                              : "Please pick a date",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _selectDate,
                      icon: const Icon(Icons.calendar_month, size: 18),
                      label: const Text("Pick Date"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 17,
                          vertical: 5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                /// STATS CARDS
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 125,
                        height: 125,
                        child: _summaryCard(
                          title: "Total Sales",
                          value: "₱${grandTotal.toStringAsFixed(2)}",
                          subtitle: _selectedDate != null
                              ? DateFormat('MMM d').format(_selectedDate!)
                              : "Today",
                          color: cs.primary,
                          textColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 125,
                        height: 125,
                        child: _summaryCard(
                          title: "",
                          value: "${filteredTransactions.length}",
                          subtitle: "Transactions",
                          icon: Icons.receipt_long,
                          color: cs.surface,
                          textColor: cs.onSurface,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 125,
                        height: 125,
                        child: _summaryCard(
                          title: "",
                          value: "₱${selectedMonthTotal.toStringAsFixed(0)}",
                          subtitle: "Monthly",
                          icon: Icons.calendar_today,
                          valueColor: Colors.green,
                          color: cs.surface,
                          textColor: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /// WEEKLY / MONTHLY OVERVIEW
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row: title + toggle
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        runSpacing: 12,
                        children: [
                          Text(
                            isWeeklyActive
                                ? "Weekly Overview"
                                : "Monthly Overview",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _tabButton(
                                text: "Weekly",
                                active: isWeeklyActive,
                                onTap: () =>
                                    setState(() => isWeeklyActive = true),
                              ),
                              _tabButton(
                                text: "Monthly",
                                active: !isWeeklyActive,
                                onTap: () =>
                                    setState(() => isWeeklyActive = false),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Subtitle: total for the current view
                      Text(
                        isWeeklyActive
                            ? "Week total: ₱${weeklyTotal.toStringAsFixed(2)}"
                            : "Month total: ₱${selectedMonthTotal.toStringAsFixed(2)}",
                      ),

                      const SizedBox(height: 16),

                      // BAR CHART
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final availableWidth = constraints.maxWidth;
                          final totalBars = chartData.length;
                          final padding = 16.0; // Total horizontal padding
                          final spacing = 8.0; // Spacing between bars
                          final totalSpacing = (totalBars - 1) * spacing;
                          final availableBarWidth =
                              (availableWidth - padding - totalSpacing) /
                              totalBars;

                          // Calculate bar width with minimum and maximum constraints
                          final barWidth = availableBarWidth.clamp(
                            30.0,
                            isWeeklyActive ? 50.0 : 80.0,
                          );

                          return SizedBox(
                            height: 160,
                            width: double.infinity,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                chartData.length,
                                (index) => Padding(
                                  padding: EdgeInsets.only(
                                    right: index < totalBars - 1 ? spacing : 0,
                                  ),
                                  child: _buildBarWithWidth(
                                    index,
                                    chartData[index],
                                    maxValue,
                                    barWidth,
                                    cs,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /// TRANSACTIONS & GRAND TOTAL
                ..._buildTransactions(filteredTransactions, grandTotal, cs),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
