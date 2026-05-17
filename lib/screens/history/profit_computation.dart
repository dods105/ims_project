import '../../models/purchase/transaction_sale.dart';
import '../../models/purchase/transaction_items.dart';

/// Holds a breakdown of sales and profit for a given period.
class ProfitSummary {
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

  static const ProfitSummary empty = ProfitSummary(
    totalSales: 0,
    totalProfit: 0,
    dailySales: [0, 0, 0, 0, 0, 0, 0],
    dailyProfit: [0, 0, 0, 0, 0, 0, 0],
    weeklySales: [0, 0, 0, 0, 0],
    weeklyProfit: [0, 0, 0, 0, 0],
  );
}

class ProfitComputation {
  ProfitComputation._();

  /// Computes [ProfitSummary] for the week and month that [selectedDate] falls in.
  ///
  /// [transactions]     – all transactions for the user.
  /// [allItems]         – flat list of every transaction item (with transacted_at attached
  ///                      from the JOIN query [DatabaseHelper.getTransactionItemsByUser]).
  ///                      Each map must contain the keys that [TransactionItems.fromMap]
  ///                      expects, plus `transacted_at` (ISO datetime string).
  static ProfitSummary compute({
    required DateTime selectedDate,
    required List<TransactionSale> transactions,
    required List<Map<String, dynamic>> allItems,
  }) {
    // ── week boundaries (Sun–Sat) ──────────────────────────────────────────
    // weekday: Mon=1 … Sun=7  → days since last Sunday
    final daysSinceSunday = selectedDate.weekday % 7; // Sun=0, Mon=1 … Sat=6
    final weekStart = _dateOnly(
      selectedDate.subtract(Duration(days: daysSinceSunday)),
    );
    final weekEnd = weekStart.add(const Duration(days: 6));

    // ── month boundaries ───────────────────────────────────────────────────
    final monthStart = DateTime(selectedDate.year, selectedDate.month, 1);
    final monthEnd = DateTime(selectedDate.year, selectedDate.month + 1, 0);

    // ── accumulators ──────────────────────────────────────────────────────
    final dailySales = List<double>.filled(7, 0); // index = daysSinceSunday
    final dailyProfit = List<double>.filled(7, 0);
    final weeklySales = List<double>.filled(5, 0);
    final weeklyProfit = List<double>.filled(5, 0);

    double totalSales = 0;
    double totalProfit = 0;

    // ── group items by transactionId for quick lookup ─────────────────────
    final Map<String, List<Map<String, dynamic>>> itemsByTxn = {};
    for (final row in allItems) {
      final tid = row['transaction_id'] as String? ?? '';
      itemsByTxn.putIfAbsent(tid, () => []).add(row);
    }

    for (final txn in transactions) {
      final dt = DateTime.tryParse(txn.transactedAt);
      if (dt == null) continue;
      final d = _dateOnly(dt);

      // ── week accumulation ─────────────────────────────────────────────
      if (!d.isBefore(weekStart) && !d.isAfter(weekEnd)) {
        final dayIdx = dt.weekday % 7; // Sun=0 … Sat=6
        dailySales[dayIdx] += txn.totalAmount;

        // profit from items
        final profit = _profitForTxn(txn.id, itemsByTxn);
        dailyProfit[dayIdx] += profit;
      }

      // ── month accumulation ────────────────────────────────────────────
      if (!d.isBefore(monthStart) && !d.isAfter(monthEnd)) {
        final weekIdx = ((dt.day - 1) / 7).floor().clamp(0, 4);
        weeklySales[weekIdx] += txn.totalAmount;

        final profit = _profitForTxn(txn.id, itemsByTxn);
        weeklyProfit[weekIdx] += profit;
        totalSales += txn.totalAmount;
        totalProfit += profit;
      }
    }

    return ProfitSummary(
      totalSales: totalSales,
      totalProfit: totalProfit,
      dailySales: dailySales,
      dailyProfit: dailyProfit,
      weeklySales: weeklySales,
      weeklyProfit: weeklyProfit,
    );
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  /// Sums (unitPrice − originalPrice) × quantity for every item in [txnId].
  /// Items without originalPrice contribute 0 profit (unknown cost).
  static double _profitForTxn(
    String? txnId,
    Map<String, List<Map<String, dynamic>>> itemsByTxn,
  ) {
    if (txnId == null) return 0;
    final rows = itemsByTxn[txnId] ?? [];
    double profit = 0;
    for (final row in rows) {
      final item = TransactionItems.fromMap(row);
      profit += item.revenue ?? 0;
    }
    return profit;
  }
}
