import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../designs/drawer.dart';
import '../../designs/appbar.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {

  bool isWeeklyActive = true;
  
  // Monthly: BarChart Sample
  final List<double> monthlyData = [400, 300, 450, 350, 500, 420, 380];

  final List<String> monthlyLabels = [
    "Week 1",
    "Week 2",
    "Week 3",
    "Week 4",
    "Week 5",
    "Week 6",
    "Week 7",
  ];

  // Weekly: BarChart Sample
  final List<double> weeklyData = [80, 60, 40, 70, 50, 30, 90];

  final List<String> weeklyLabels = [
    "Sun",
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
  ];

  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked; // store as DateTime
        _dateController.text = DateFormat(
          'yyyy-MM-dd',
        ).format(picked); // optional
      });
    }
  }

  List<Widget> _buildTransactions(List<Map<String, String>> transactions) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            "Transactions (7)",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text("Apr 12", style: TextStyle(color: Colors.grey)),
        ],
      ),
      const SizedBox(height: 16),
      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final item = transactions[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F6FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.payments_outlined,
                    color: Color(0xFF2F5BEA),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["id"]!,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item["time"]!,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: [
                          const Text(
                            "Cash",
                            style: TextStyle(
                              color: Color(0xFF2F5BEA),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            item["items"]!,
                            style: const TextStyle(
                              color: Colors.grey,
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
                      item["amount"]!,
                      style: const TextStyle(
                        color: Color(0xFF2F5BEA),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.receipt_long, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          "Receipt",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF2F5BEA),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Flexible(
              child: Text(
                "GRAND TOTAL",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 12),
            Text(
              "₱1380.00",
              style: TextStyle(
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
          if (icon != null) Icon(icon, size: 18, color: Colors.grey),
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
                color: valueColor ?? textColor ?? Colors.black,
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
      onTap: onTap, // toggles the state
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

  static Widget _barChart(String day, double height, bool active) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 28,
          height: height,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF2F5BEA) : const Color(0xFFDCE5FF),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactions = [
      {
        "id": "20260412-001",
        "time": "08:14 AM",
        "items": "2 items",
        "amount": "₱190.00",
      },
      {
        "id": "20260412-002",
        "time": "09:32 AM",
        "items": "2 items",
        "amount": "₱114.00",
      },
      {
        "id": "20260412-003",
        "time": "10:05 AM",
        "items": "2 items",
        "amount": "₱240.00",
      },
      {
        "id": "20260412-004",
        "time": "11:20 AM",
        "items": "2 items",
        "amount": "₱195.00",
      },
      {
        "id": "20260412-005",
        "time": "01:15 PM",
        "items": "2 items",
        "amount": "₱156.00",
      },
      {
        "id": "20260412-006",
        "time": "01:15 PM",
        "items": "2 items",
        "amount": "₱185.00",
      },
      {
        "id": "20260412-007",
        "time": "02:50 PM",
        "items": "1 item",
        "amount": "₱300.00",
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
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
                    // Left side: Viewing + selected date
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
                              : "Please pick a date", // fallback
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    // Right side: Pick Date button
                    ElevatedButton.icon(
                      onPressed: _selectDate,
                      icon: const Icon(Icons.calendar_month, size: 18),
                      label: const Text("Pick Date"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F5BEA),
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
                          value: "₱1380.00",
                          subtitle: "Today",
                          color: const Color(0xFF2F5BEA),
                          textColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 125,
                        height: 125,
                        child: _summaryCard(
                          title: "",
                          value: "7",
                          subtitle: "Transactions",
                          icon: Icons.receipt_long,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 125,
                        height: 125,
                        child: _summaryCard(
                          title: "",
                          value: "₱4,439",
                          subtitle: "Monthly",
                          icon: Icons.calendar_today,
                          valueColor: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /// WEEKLY OVERVIEW
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        runSpacing: 12,
                        children: [
                          const Text(
                            "Weekly Overview",
                            style: TextStyle(
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
                                onTap: () {
                                  setState(() {
                                    isWeeklyActive = true;
                                  });
                                },
                              ),
                              _tabButton(
                                text: "Monthly",
                                active: !isWeeklyActive,
                                onTap: () {
                                  setState(() {
                                    isWeeklyActive = false;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // WEEKLY / MONTHLY BAR CHART
                      SizedBox(
                        height: 125, 
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal, 
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(
                              isWeeklyActive
                                  ? weeklyData.length
                                  : monthlyData.length,
                              (index) {
                                final data = isWeeklyActive
                                    ? weeklyData
                                    : monthlyData;
                                final labels = isWeeklyActive
                                    ? weeklyLabels
                                    : monthlyLabels;
                                // Find max value in the dataset
                                final maxValue = data.reduce(
                                  (a, b) => a > b ? a : b,
                                ); // Scale bar height proportionally to fit container
                                final double availableHeight =
                                    120 - 20; // reserve 20px for label
                                final scaledHeight =
                                    (data[index] / maxValue) * availableHeight;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        width: 28,
                                        height: scaledHeight,
                                        decoration: BoxDecoration(
                                          color: data[index] == maxValue
                                              ? const Color(0xFF2F5BEA)
                                              : const Color(0xFFDCE5FF),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        labels[index],
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /// TRANSACTIONS & GRAND TOTAL
                ..._buildTransactions(transactions),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
