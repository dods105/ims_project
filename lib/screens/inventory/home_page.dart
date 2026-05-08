import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/adding/barcode_scanner_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/designs/appbar.dart';
import '../../providers/auth_provider.dart';
import '../../designs/drawer.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController barcodeController = TextEditingController();

  @override
  void dispose() {
    barcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBarDesign(page: "STORAGE"),
      endDrawer: const AppDrawer(page: '/inventory'),

      body: Column(
        children: [
          const SizedBox(height: 20),

          // --- YOUR ORIGINAL SEARCH BAR ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              controller: barcodeController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () async {
                    await Future.delayed(const Duration(milliseconds: 150));

                    final scannedBarcode = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BarcodeScannerPage(),
                      ),
                    );

                    if (scannedBarcode != null) {
                      setState(() {
                        barcodeController.text = scannedBarcode;
                      });
                    }
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // --- YOUR ORIGINAL LABELS ---
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 20, 30, 10),
            child: Row(
              children: const [
                Expanded(
                  flex: 3,
                  child: Text(
                    'NAME',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'STOCKS',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'PRICE',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Icon(Icons.filter_list, size: 20),
              ],
            ),
          ),

          // --- STORAGE LIST WITH CLICK LOGIC ---
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => _showProductDetails(context, index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          color: cs.outline,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    '----------------',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    '---',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Expanded(flex: 2, child: Text('')),
                            const Expanded(flex: 2, child: Text('')),
                            const Icon(
                              Icons.more_vert,
                              size: 18,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- THE DIGITAL RECEIPT SLIDING UI ---
  void _showProductDetails(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Digital Receipt",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Store Section
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.store,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Pedro's Store",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      "Official Receipt",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Receipt Info
              _buildReceiptRow("Receipt No.", "20260408-001"),
              _buildReceiptRow("Date", "2026-04-08"),
              _buildReceiptRow("Time", "09:05 AM"),
              _buildReceiptRow("Payment", "Cash"),

              const Divider(height: 30, thickness: 1),

              // Items List
              const Text(
                "ITEMS",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 10),
              _buildItemRow("Safeguard Bar Soap x3", "₱165.00"),
              _buildItemRow("Milo 3-in-1 Sachet x5", "₱60.00"),

              const SizedBox(height: 20),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "TOTAL",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "₱225.00",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),

              const Spacer(),
              const Center(
                child: Text(
                  "Thank you for your purchase!",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              const SizedBox(height: 15),

              // Close Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper widgets to keep the code clean
  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildItemRow(String name, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(name), Text(price)],
      ),
    );
  }
}
