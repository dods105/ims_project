import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../designs/drawer.dart';
import '../../designs/appbar.dart';
import '../../providers/auth_provider.dart';
import '../../providers/purchase_provider.dart';
import '../../database/database_helper.dart';
import '../../models/purchase/transaction_sale.dart';
import '../../models/purchase/transaction_items.dart';
import 'revenue_compute.dart';
import 'history_widgets.dart';
import 'revenue_info.dart';

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
  Map<String, int> _itemCounts = {};
  bool _isLoading = true;

  List<double> _weeklyData = List.filled(7, 0);
  List<double> _monthlyData = List.filled(5, 0);

  static const weeklyLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  static const monthlyLabels = [
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

  // Data - load transaction and bar chart

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      final user = ref.read(authProvider).value;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final transactions = await DatabaseHelper.instance.getTransactionsByUser(
        user.id!,
      );
      final allItemRows = await DatabaseHelper.instance
          .getTransactionItemsByUser(user.id!);

      final Map<String, int> counts = {};
      for (final t in transactions) {
        if (t.id != null) {
          counts[t.id!] = await DatabaseHelper.instance.getItemCount(t.id!);
        }
      }

      _calculateChartData(transactions);
      setState(() {
        _transactions = transactions;
        _allItemRows = allItemRows;
        _itemCounts = counts;
        _isLoading = false;
      });
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

  void _calculateChartData(List<TransactionSale> transactions) {
    final dateToUse = _selectedDate ?? DateTime.now();
    final sow = startOfWeek(dateToUse);
    final eow = sow.add(const Duration(days: 6));
    final startOfMonth = DateTime(dateToUse.year, dateToUse.month, 1);
    final endOfMonth = DateTime(dateToUse.year, dateToUse.month + 1, 0);

    _weeklyData = List.filled(7, 0);
    _monthlyData = List.filled(5, 0);

    for (final trans in transactions) {
      final transDate = DateTime.tryParse(trans.transactedAt);
      if (transDate == null) continue;
      final day = DateTime(transDate.year, transDate.month, transDate.day);

      if (!day.isBefore(sow) && !day.isAfter(eow)) {
        _weeklyData[dayIndex(transDate)] += trans.totalAmount;
      }

      final sm = DateTime(startOfMonth.year, startOfMonth.month, 1);
      final em = DateTime(endOfMonth.year, endOfMonth.month, endOfMonth.day);
      if (!day.isBefore(sm) && !day.isAfter(em)) {
        _monthlyData[((transDate.day - 1) / 7).floor().clamp(0, 4)] +=
            trans.totalAmount;
      }
    }
  }

  Future<void> _loadTransactionItems(String transactionId) async {
    try {
      final items = await DatabaseHelper.instance.getTransactionItems(
        transactionId,
      );
      setState(() => _transactionItems = items);
    } catch (_) {
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
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
        _calculateChartData(_transactions);
      });
    }
  }

  List<TransactionSale> _getFilteredTransactions() {
    return _transactions.where((t) {
      final d = DateTime.tryParse(t.transactedAt);
      if (d == null || _selectedDate == null) return false;
      return d.year == _selectedDate!.year &&
          d.month == _selectedDate!.month &&
          d.day == _selectedDate!.day;
    }).toList();
  }

  //Revenue sheet
  RevenueResult _computeRevenue({required bool weekly}) => computeRevenue(
    weekly: weekly,
    selectedDate: _selectedDate,
    allItemRows: _allItemRows,
  );

  void _showRevenueSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RevenueBreakdownSheet(
        computeRevenue: _computeRevenue,
        weeklyLabels: weeklyLabels,
        monthlyLabels: monthlyLabels,
        selectedDate: _selectedDate,
      ),
    );
  }

  bool _isCurrentBar(int barIndex) {
    final now = DateTime.now();
    if (isWeeklyActive) {
      final sow = startOfWeek(_selectedDate ?? now);
      final eow = sow.add(const Duration(days: 6));
      final today = DateTime(now.year, now.month, now.day);
      if (today.isBefore(sow) || today.isAfter(eow)) return false;
      return barIndex == dayIndex(now);
    } else {
      if (_selectedDate != null &&
          (_selectedDate!.year != now.year ||
              _selectedDate!.month != now.month))
        return false;
      return barIndex == ((now.day - 1) / 7).floor().clamp(0, 4);
    }
  }

  String _formatBarLabel(double value) {
    if (value <= 0) return '';
    if (value >= 1000) {
      final k = value / 1000;
      return k == k.truncateToDouble()
          ? '${k.toInt()}K'
          : '${k.toStringAsFixed(1)}K';
    }
    return value.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(purchaseProvider);
    final cs = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: cs.background,
        appBar: AppBarDesign(page: 'Daily Sales'),
        endDrawer: const AppDrawer(page: '/history'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final filtered = _getFilteredTransactions();
    final grandTotal = filtered.fold(0.0, (s, t) => s + t.totalAmount);
    final weeklyTotal = _weeklyData.fold(0.0, (a, b) => a + b);
    final monthlyTotal = _monthlyData.fold(0.0, (a, b) => a + b);
    final weekRevenue = _computeRevenue(weekly: true).totalRevenue;

    final chartData = isWeeklyActive ? _weeklyData : _monthlyData;
    final labels = isWeeklyActive ? weeklyLabels : monthlyLabels;
    final maxValue = chartData.isEmpty
        ? 1.0
        : chartData.reduce((a, b) => a > b ? a : b);

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
                //Date picker
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                // Summary cards
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 125,
                        height: 125,
                        child: SummaryCard(
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
                        child: SummaryCard(
                          title: "",
                          value: "${filtered.length}",
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
                        child: SummaryCard(
                          title: "",
                          value: "₱${monthlyTotal.toStringAsFixed(0)}",
                          subtitle: "Monthly",
                          icon: Icons.calendar_today,
                          valueColor: Colors.green,
                          color: cs.surface,
                          textColor: cs.onSurface,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 125,
                        height: 125,
                        child: SummaryCard(
                          title: "",
                          value: "₱${weekRevenue.toStringAsFixed(0)}",
                          subtitle: "Revenue",
                          icon: Icons.trending_up,
                          valueColor: Colors.orange[700],
                          color: cs.surface,
                          textColor: cs.onSurface,
                          onTap: _showRevenueSheet,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Chart
                Container(
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
                              HistoryTabButton(
                                text: "Weekly",
                                active: isWeeklyActive,
                                onTap: () =>
                                    setState(() => isWeeklyActive = true),
                              ),
                              HistoryTabButton(
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
                            : "Month total: ₱${monthlyTotal.toStringAsFixed(2)}",
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final totalBars = chartData.length;
                          const spacing = 8.0;
                          const padding = 16.0;
                          final barWidth =
                              ((constraints.maxWidth -
                                          padding -
                                          (totalBars - 1) * spacing) /
                                      totalBars)
                                  .clamp(30.0, isWeeklyActive ? 50.0 : 80.0);

                          return SizedBox(
                            height: 160,
                            width: double.infinity,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                chartData.length,
                                (i) => Padding(
                                  padding: EdgeInsets.only(
                                    right: i < totalBars - 1 ? spacing : 0,
                                  ),
                                  child: HistoryBar(
                                    value: chartData[i],
                                    maxValue: maxValue,
                                    barWidth: barWidth,
                                    label: labels[i],
                                    topLabel: _formatBarLabel(chartData[i]),
                                    isActive: _isCurrentBar(i),
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

                // Transactions
                TransactionList(
                  transactions: filtered,
                  grandTotal: grandTotal,
                  selectedDate: _selectedDate,
                  itemCounts: _itemCounts,
                  transactionItems: _transactionItems,
                  onTapTransaction: _loadTransactionItems,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
