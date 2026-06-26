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
import 'profit_computation.dart';

enum _ProfitView { weekly, monthly }

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  bool isWeeklyActive = true;

  List<TransactionSale> _transactions = [];
  List<TransactionItems> _transactionItems = [];
  List<Map<String, dynamic>> _allItemRows = [];
  bool _isLoading = true;
  Map<String, int> _itemCounts = {};
  ProfitSummary _profit = ProfitSummary.empty;

  // Weekly
  // Sun=0 to Sat=6  Monthly: Week1 to Week5
  List<double> _weeklyData = List.filled(7, 0);
  List<double> _monthlyData = List.filled(5, 0);

  // Labels for the bar chart
  final List<String> weeklyLabels = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];
  final List<String> monthlyLabels = [
    'Week 1',
    'Week 2',
    'Week 3',
    'Week 4',
    'Week 5',
  ];

  //date picker
  DateTime? _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      final user = ref.read(authProvider).value;
      if (user != null) {
        final transactions = await DatabaseHelper.instance
            .getTransactionsByUser(user.id!);

        final Map<String, int> counts = await DatabaseHelper.instance
            .getItemCountsForUser(user.id!);

        final allItemRows = await DatabaseHelper.instance
            .getTransactionItemsByUser(user.id!);

        _calculateChartData(transactions);
        _calculateProfit(transactions, allItemRows);

        setState(() {
          _transactions = transactions;
          _itemCounts = counts;
          _allItemRows = allItemRows;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading transactions: $e');
      setState(() => _isLoading = false);
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

  //bar chart data for sales calculation
  void _calculateChartData(List<TransactionSale> transactions) {
    final dateToUse = _selectedDate ?? DateTime.now();

    // Week: Sunday ti Saturday
    final daysSinceSunday = dateToUse.weekday % 7; // Sun=0, Mon=1, Sat=6
    final weekStart = DateTime(
      dateToUse.year,
      dateToUse.month,
      dateToUse.day,
    ).subtract(Duration(days: daysSinceSunday));
    final weekEnd = weekStart.add(const Duration(days: 6));

    // Month
    final monthStart = DateTime(dateToUse.year, dateToUse.month, 1);
    final monthEnd = DateTime(dateToUse.year, dateToUse.month + 1, 0);

    _weeklyData = List.filled(7, 0);
    _monthlyData = List.filled(5, 0);

    for (final trans in transactions) {
      final transDate = DateTime.tryParse(trans.transactedAt);
      if (transDate == null) continue;
      final d = DateTime(transDate.year, transDate.month, transDate.day);

      // weekly (Sun–Sat)
      if (!d.isBefore(weekStart) && !d.isAfter(weekEnd)) {
        final dayIdx = transDate.weekday % 7;
        _weeklyData[dayIdx] += trans.totalAmount;
      }

      // monthly
      if (!d.isBefore(monthStart) && !d.isAfter(monthEnd)) {
        final weekIdx = ((transDate.day - 1) / 7).floor().clamp(0, 4);
        _monthlyData[weekIdx] += trans.totalAmount;
      }
    }
  }

  void _calculateProfit(
    List<TransactionSale> transactions,
    List<Map<String, dynamic>> allItemRows,
  ) {
    _profit = ProfitComputation.compute(
      selectedDate: _selectedDate ?? DateTime.now(),
      transactions: transactions,
      allItems: allItemRows,
    );
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
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _calculateChartData(_transactions);
        _calculateProfit(_transactions, _allItemRows);
      });
    }
  }

  List<TransactionSale> _getFilteredTransactions() {
    final date = _selectedDate ?? DateTime.now();
    return _transactions.where((t) {
      final transDate = DateTime.tryParse(t.transactedAt);
      if (transDate == null) return false;
      return transDate.year == date.year &&
          transDate.month == date.month &&
          transDate.day == date.day;
    }).toList();
  }

  //current day/week for barchart
  //highlight to blue
  bool _isCurrentBar(int barIndex) {
    final now = DateTime.now();
    final sel = _selectedDate ?? now;
    if (isWeeklyActive) {
      //is the selected date in the same week as today?
      final daysSinceSundayNow = now.weekday % 7;
      final currentWeekStart = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: daysSinceSundayNow));
      final daysSinceSundaySel = sel.weekday % 7;
      final selWeekStart = DateTime(
        sel.year,
        sel.month,
        sel.day,
      ).subtract(Duration(days: daysSinceSundaySel));
      if (currentWeekStart != selWeekStart) return false;
      return barIndex == now.weekday % 7;
    } else {
      //same month?
      if (sel.year != now.year || sel.month != now.month) return false;
      return barIndex == ((now.day - 1) / 7).floor().clamp(0, 4);
    }
  }

  //if sales is 1000+, make it K
  //sales is million, make it M
  String _formatBarLabel(double value) {
    if (value <= 0) return '';
    if (value >= 1000000) {
      final m = value / 1000000;
      return m == m.truncateToDouble()
          ? '${m.toInt()}M'
          : '${m.toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      final k = value / 1000;
      return k == k.truncateToDouble()
          ? '${k.toInt()}K'
          : '${k.toStringAsFixed(1)}K';
    }
    return value.toInt().toString();
  }

  //Profit bottom-sheet
  //ui for profit when clicked
  void _showProfitSheet(ColorScheme cs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProfitSheet(
        selectedDate: _selectedDate ?? DateTime.now(),
        profit: _profit,
        cs: cs,
      ),
    );
  }

  //transactio list with tapping to open receipt
  //and grand total saless
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
                const Icon(Icons.receipt_long, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'No transactions found',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
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
                            trans.id ?? '',
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
                                : '',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 6),
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
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
    VoidCallback? onTap,
  }) {
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
                  fontSize: 18,
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
        Text(
          topLabel,
          style: TextStyle(
            fontSize: 11,
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
        SizedBox(
          width: barWidth,
          child: Text(
            label,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey,
              fontSize: isWeeklyActive ? 11 : 11,
              fontWeight: isWeeklyActive ? FontWeight.normal : FontWeight.w500,
            ),
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
    final weeklyTotal = _weeklyData.fold(0.0, (a, b) => a + b);
    final selectedMonthTotal = _monthlyData.fold(0.0, (a, b) => a + b);

    // Which chart data to show
    final chartData = isWeeklyActive ? _weeklyData : _monthlyData;
    final maxValue = chartData.isEmpty
        ? 1.0
        : chartData.reduce((a, b) => a > b ? a : b);

    // Profit for the selected date specifically (day index within its week).
    final selDate = _selectedDate ?? DateTime.now();
    final selDayIdx = selDate.weekday % 7; // Sun=0 … Sat=6
    final selectedDateProfit = _profit.dailyProfit[selDayIdx];

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
                // Date row
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

                //summary cards
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Sales
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
                      // Transactions
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
                      // Monthly
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
                      const SizedBox(width: 12),
                      // Profit (tap > opens W/M breakdown)
                      SizedBox(
                        width: 125,
                        height: 125,
                        child: _summaryCard(
                          title: _selectedDate != null
                              ? DateFormat('MMM d').format(_selectedDate!)
                              : 'Today',
                          value: "₱${selectedDateProfit.toStringAsFixed(0)}",
                          subtitle: "Profit",
                          icon: Icons.trending_up,
                          valueColor: Colors.teal,
                          color: cs.surface,
                          textColor: cs.onSurface,
                          onTap: () => _showProfitSheet(cs),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Bar chart container
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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

                        Text(
                          isWeeklyActive
                              ? "Week total: ₱${weeklyTotal.toStringAsFixed(2)}"
                              : "Month total: ₱${selectedMonthTotal.toStringAsFixed(2)}",
                        ),

                        const SizedBox(height: 16),

                        // makes bar chardt data fit dynamically
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final totalBars = chartData.length;
                            const spacing = 8.0;
                            const sidePadding = 0.0;
                            final totalSpacing = (totalBars - 1) * spacing;
                            final barWidth =
                                ((constraints.maxWidth -
                                            sidePadding -
                                            totalSpacing) /
                                        totalBars)
                                    .clamp(20.0, isWeeklyActive ? 60.0 : 90.0);

                            return SizedBox(
                              height: 160,
                              width: double.infinity,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(
                                  totalBars,
                                  (index) => _buildBarWithWidth(
                                    index,
                                    chartData[index],
                                    maxValue == 0 ? 1 : maxValue,
                                    barWidth,
                                    cs,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                //transactions list and grand total
                ..._buildTransactions(filteredTransactions, grandTotal, cs),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//data sheet for profit
//both weekly and monthly
class _ProfitSheet extends StatefulWidget {
  final DateTime selectedDate;
  final ProfitSummary profit;
  final ColorScheme cs;

  const _ProfitSheet({
    required this.selectedDate,
    required this.profit,
    required this.cs,
  });

  @override
  State<_ProfitSheet> createState() => _ProfitSheetState();
}

class _ProfitSheetState extends State<_ProfitSheet> {
  _ProfitView _view = _ProfitView.weekly;

  static const List<String> _dayLabels = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];
  static const List<String> _weekLabels = [
    'Week 1',
    'Week 2',
    'Week 3',
    'Week 4',
    'Week 5',
  ];

  String monthTotal(double v) => v == 0 ? '' : '₱${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final cs = widget.cs;
    final isWeekly = _view == _ProfitView.weekly;

    final rowLabels = isWeekly ? _dayLabels : _weekLabels;
    final salesData = isWeekly ? _buildDailySales() : widget.profit.weeklySales;
    final profitData = isWeekly
        ? widget.profit.dailyProfit.toList()
        : widget.profit.weeklyProfit.toList();

    final totalSales = salesData.fold(0.0, (a, b) => a + b);
    final totalProfit = profitData.fold(0.0, (a, b) => a + b);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // title and W/M toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isWeekly ? "Weekly Profit" : "Monthly Profit",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _sheetTab(
                      label: 'W',
                      active: isWeekly,
                      cs: cs,
                      onTap: () {
                        setState(() => _view = _ProfitView.weekly);
                      },
                    ),
                    _sheetTab(
                      label: 'M',
                      active: !isWeekly,
                      cs: cs,
                      onTap: () {
                        setState(() => _view = _ProfitView.monthly);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          //table header
          _tableRow(
            label: 'Day',
            sales: 'Sales',
            profit: 'Profit',
            isHeader: true,
            cs: cs,
          ),

          //table rows
          //weekly and monthly sales and profit
          ...List.generate(rowLabels.length, (i) {
            return _tableRow(
              label: rowLabels[i],
              sales: monthTotal(salesData[i]),
              profit: monthTotal(profitData[i]),
              isHeader: false,
              cs: cs,
            );
          }),

          // Totals for sales and profit both weekly/monthly
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: _tableRow(
              label: 'Total:',
              sales: monthTotal(totalSales),
              profit: monthTotal(totalProfit),
              isHeader: false,
              isTotal: true,
              cs: cs,
            ),
          ),

          const SizedBox(height: 20),

          // Close button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Close',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<double> _buildDailySales() => widget.profit.dailySales.toList();

  Widget _sheetTab({
    required String label,
    required bool active,
    required ColorScheme cs,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? cs.primary : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // table data for the revenue
  Widget _tableRow({
    required String label,
    required String sales,
    required String profit,
    required bool isHeader,
    bool isTotal = false,
    required ColorScheme cs,
  }) {
    final bg = isHeader
        ? cs.primary
        : isTotal
        ? Colors.transparent
        : null;
    final textColor = isHeader ? Colors.white : null;
    final labelStyle = TextStyle(
      color: isTotal ? cs.primary : textColor,
      fontWeight: (isHeader || isTotal) ? FontWeight.bold : FontWeight.normal,
      fontSize: isTotal ? 13 : 13,
    );
    final cellStyle = TextStyle(
      color: isTotal ? cs.primary : textColor,
      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
      fontSize: 13,
    );

    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(label, style: labelStyle)),
          Expanded(
            flex: 3,
            child: Text(sales, textAlign: TextAlign.center, style: cellStyle),
          ),
          Expanded(
            flex: 3,
            child: Text(profit, textAlign: TextAlign.center, style: cellStyle),
          ),
        ],
      ),
    );
  }
}
