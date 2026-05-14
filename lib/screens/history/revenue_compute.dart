// Week and month from seleted dae
//revenue models, and the revenue computation logic -------- delete incase ayaw ni sir

// Returns the Sunday that starts the week containing [date].
DateTime startOfWeek(DateTime date) {
  final daysFromSunday = date.weekday % 7;
  return DateTime(
    date.year,
    date.month,
    date.day,
  ).subtract(Duration(days: daysFromSunday));
}

int dayIndex(DateTime date) => date.weekday % 7;

// Revenue models

class NoCostItem {
  final String name;
  final int qty;
  final double sales;
  const NoCostItem({
    required this.name,
    required this.qty,
    required this.sales,
  });
}

class RevenueResult {
  final List<double> revenueByBucket;
  final List<NoCostItem> noCostItems;
  final double totalRevenue;

  const RevenueResult({
    required this.revenueByBucket,
    required this.noCostItems,
    required this.totalRevenue,
  });
}

// Revenue computation

// [weekly]       true → Sun-Sat week of [selectedDate] false → full calendar month (toggle)
// [allItemRows]  result of DatabaseHelper.getTransactionItemsByUser().
// [selectedDate] the date the user picked
RevenueResult computeRevenue({
  required bool weekly,
  required DateTime? selectedDate,
  required List<Map<String, dynamic>> allItemRows,
}) {
  final dateToUse = selectedDate ?? DateTime.now();

  final DateTime rangeStart;
  final DateTime rangeEnd;
  int Function(DateTime) bucketOf;

  if (weekly) {
    rangeStart = startOfWeek(dateToUse);
    rangeEnd = rangeStart.add(const Duration(days: 6));
    bucketOf = (d) => dayIndex(d); // Sun=0 … Sat=6
  } else {
    rangeStart = DateTime(dateToUse.year, dateToUse.month, 1);
    final eom = DateTime(dateToUse.year, dateToUse.month + 1, 0);
    rangeEnd = DateTime(eom.year, eom.month, eom.day);
    bucketOf = (d) => ((d.day - 1) / 7).floor().clamp(0, 4);
  }

  final int bucketCount = weekly ? 7 : 5;
  final revenueByBucket = List<double>.filled(bucketCount, 0);
  final Map<String, NoCostItem> noCostMap = {};
  double totalRevenue = 0;

  for (final row in allItemRows) {
    final transactedAt = DateTime.tryParse(row['transacted_at'] ?? '');
    if (transactedAt == null) continue;

    final day = DateTime(
      transactedAt.year,
      transactedAt.month,
      transactedAt.day,
    );
    if (day.isBefore(rangeStart) || day.isAfter(rangeEnd)) continue;

    final qty = (row['quantity'] as num).toInt();
    final unitPrice = (row['unit_price'] as num).toDouble();
    final originalPrice = row['original_price'] != null
        ? (row['original_price'] as num).toDouble()
        : null;
    final subtotal = (row['subtotal'] as num).toDouble();
    final name = row['product_name'] as String;

    if (originalPrice != null) {
      final rev = (unitPrice - originalPrice) * qty;
      revenueByBucket[bucketOf(transactedAt)] += rev;
      totalRevenue += rev;
    } else {
      noCostMap.update(
        name,
        (e) =>
            NoCostItem(name: name, qty: e.qty + qty, sales: e.sales + subtotal),
        ifAbsent: () => NoCostItem(name: name, qty: qty, sales: subtotal),
      );
    }
  }

  return RevenueResult(
    revenueByBucket: revenueByBucket,
    noCostItems: noCostMap.values.toList(),
    totalRevenue: totalRevenue,
  );
}
