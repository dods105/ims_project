import '../../models/purchase/transaction_sale.dart';
import '../../models/purchase/transaction_items.dart';

// ============================================================================
// OVERALL FUNCTIONALITY OF THE CLASS:
// 'ProfitSummary' is a plain data object (model) that structures and holds
// calculations for sales totals, net profits, daily performance, and weekly
// distributions over a designated timeframe.
// ============================================================================
class ProfitSummary {
  // VARIABLES
  // totalSales / totalProfit: Absolute currency tallies for revenue and net gains.
  // dailySales / dailyProfit: Fixed lists indexing calculations from Sunday to Saturday.
  // weeklySales / weeklyProfit: Fixed lists tracking financial performance per calendar week.
  final double totalSales;
  final double totalProfit;
  final List<double> dailySales; // Sun=0 … Sat=6
  final List<double> dailyProfit; // Sun=0 … Sat=6
  final List<double> weeklySales; // Week1…Week5
  final List<double> weeklyProfit; // Week1…Week5

  const ProfitSummary({
    required this.totalSales,
    required this.totalProfit,
    required this.dailySales,
    required this.dailyProfit,
    required this.weeklySales,
    required this.weeklyProfit,
  });

  // VARIABLE (Fallback Constant State)
  // A clean, zeroed-out instance used as an empty state representation.
  static const ProfitSummary empty = ProfitSummary(
    totalSales: 0,
    totalProfit: 0,
    dailySales: [0, 0, 0, 0, 0, 0, 0],
    dailyProfit: [0, 0, 0, 0, 0, 0, 0],
    weeklySales: [0, 0, 0, 0, 0],
    weeklyProfit: [0, 0, 0, 0, 0],
  );
}

// ============================================================================
// OVERALL FUNCTIONALITY OF THE CLASS:
// 'ProfitComputation' serves as a utility processor class containing logic
// to map datasets together and aggregate finances across specific date windows.
// ============================================================================
class ProfitComputation {
  // Private constructor prevents class instantiation.
  ProfitComputation._();

  // FUNCTION (Core Business Logic Processor)
  // Maps individual data structures, computes relative weekly/monthly windows,
  // and aggregates items into a final calculated summary matrix.
  static ProfitSummary compute({
    required DateTime selectedDate,
    required List<TransactionSale> transactions,
    required List<Map<String, dynamic>> allItems,
  }) {
    // VARIABLES (Date Boundaries Calculation)
    // Computes relative timeline thresholds starting exactly from Sunday up to Saturday.
    final daysSinceSunday = selectedDate.weekday % 7; // Sun=0, Mon=1 … Sat=6
    final weekStart = _dateOnly(
      selectedDate.subtract(Duration(days: daysSinceSunday)),
    );
    final weekEnd = weekStart.add(const Duration(days: 6));

    // VARIABLES (Month Boundaries Calculation)
    // Extracts calendar limit bounds capturing day one to the last active calendar day.
    final monthStart = DateTime(selectedDate.year, selectedDate.month, 1);
    final monthEnd = DateTime(selectedDate.year, selectedDate.month + 1, 0);

    // VARIABLES (Accumulator Matrices)
    // Pre-allocated array sets utilized for tracking daily index metrics.
    final dailySales = List<double>.filled(7, 0);
    final dailyProfit = List<double>.filled(7, 0);
    final weeklySales = List<double>.filled(5, 0);
    final weeklyProfit = List<double>.filled(5, 0);

    double totalSales = 0;
    double totalProfit = 0;

    // VARIABLES / MAP CONFIGURATION
    // Groups granular item objects contextually by an mapped master sequence identifier string.
    final Map<String, List<Map<String, dynamic>>> itemsByTxn = {};
    for (final row in allItems) {
      final tid = row['transaction_id'] as String? ?? '';
      itemsByTxn.putIfAbsent(tid, () => []).add(row);
    }
    // IF-ELSE / ITERATION LOOP
    // Loops through all sales transactions to cross-examine and calculate dates.
    for (final txn in transactions) {
      final dt = DateTime.tryParse(txn.transactedAt);
      // IF STATEMENT
      // Ignores the record and continues if the date format is corrupted.
      if (dt == null) continue;
      final d = _dateOnly(dt);

      // WEEK ACCUMULATION & BOUNDARY CHECK
      // IF STATEMENT: Validates if transaction falls within the computed week.
      if (!d.isBefore(weekStart) && !d.isAfter(weekEnd)) {
        final dayIdx = dt.weekday % 7; // Sun=0 … Sat=6
        dailySales[dayIdx] += txn.totalAmount;

        // FUNCTION CALL
        // Retrieves profit metrics linked directly to this transaction ID.
        final profit = _profitForTxn(txn.id, itemsByTxn);
        dailyProfit[dayIdx] += profit;
      }

      // MONTH ACCUMULATION & BOUNDARY CHECK
      // IF STATEMENT: Validates if transaction falls within the active calendar month.
      if (!d.isBefore(monthStart) && !d.isAfter(monthEnd)) {
        final weekIdx = ((dt.day - 1) / 7).floor().clamp(0, 4);
        weeklySales[weekIdx] += txn.totalAmount;

        final profit = _profitForTxn(txn.id, itemsByTxn);
        weeklyProfit[weekIdx] += profit;
        totalSales += txn.totalAmount;
        totalProfit += profit;
      }
    }

    // Return the final aggregated instance data object.
    return ProfitSummary(
      totalSales: totalSales,
      totalProfit: totalProfit,
      dailySales: dailySales,
      dailyProfit: dailyProfit,
      weeklySales: weeklySales,
      weeklyProfit: weeklyProfit,
    );
  }

  // HELPER FUNCTION
  // Clears timestamp records to extract pure date entities for comparison.
  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  // FUNCTION (Granular Profit Accumulator)
  // Computes exact net returns for a specific transaction key.
  static double _profitForTxn(
    String? txnId,
    Map<String, List<Map<String, dynamic>>> itemsByTxn,
  ) {
    // IF STATEMENT
    // Validates key presence; returns zero if the identifier reference is empty.
    if (txnId == null) return 0;
    final rows = itemsByTxn[txnId] ?? [];
    double profit = 0;

    // ITERATION LOOP
    // Converts rows into structured data objects and adds up cumulative revenue.
    for (final row in rows) {
      final item = TransactionItems.fromMap(row);
      profit += item.revenue ?? 0;
    }
    return profit;
  }
}
