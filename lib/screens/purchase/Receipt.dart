import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/misc.dart';
import '../../designs/drawer.dart';
import '../../designs/themes.dart';
import '../../designs/appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'purchase_section.dart'; 
import 'listof_purchase.dart';



void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Receipt(),
  ));
}

class Receipt extends StatefulWidget {
  const Receipt({super.key});

  @override
  State<Receipt> createState() => _ReceiptState();
}

class _ReceiptState extends State<Receipt> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Receipt"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // RECEIPT TITLE
                  const Text(
                    "RECEIPT",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // CUSTOMER INFO
                  Center(
                    child: Column(
                      children: const [
                        ReceiptInfoRow(label: "Name", value: "________"),
                        SizedBox(height: 10),
                        ReceiptInfoRow(label: "Address", value: "________"),
                        SizedBox(height: 10),
                        ReceiptInfoRow(label: "Date", value: "________"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // TRANSACTION ID
                  const Center(
                    child: Text(
                      "Transaction: 26-04-22-C-08",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // PURCHASE HEADER
                  Container(
                    width: double.infinity,
                    color: Colors.indigo,
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: const Center(
                      child: Text(
                        "LIST OF PURCHASE",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // PURCHASE TABLE
                  Table(
                    border: TableBorder.all(color: Colors.grey, width: 1),
                    columnWidths: const {
                      0: FlexColumnWidth(1.3),
                      1: FlexColumnWidth(1.3),
                      2: FlexColumnWidth(1),
                      3: FlexColumnWidth(1.2),
                    },
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(color: Colors.indigo),
                        children: [
                          _tableHeader("Ref. No."),
                          _tableHeader("Name"),
                          _tableHeader("Qty"),
                          _tableHeader("Price"),
                        ],
                      ),
                      TableRow(
                        children: [
                          _tableCell("4243737"),
                          _tableCell("Ice Cream"),
                          _tableCell("10"),
                          _tableCell("400"),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 60),

                  // TOTALS SECTION
                  Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        TotalRow(label: "Total:", amount: "P 400.00"),
                        SizedBox(height: 10),
                        TotalRow(label: "Cash:", amount: "P 500.00"),
                        SizedBox(height: 10),
                        TotalRow(label: "Change:", amount: "P 100.00"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80),

                  // RECORD BUTTON
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: const BorderSide(color: Colors.black, width: 3),
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Record Saved")),
                        );
                      },
                      child: const Text(
                        "RECORD",
                        style: TextStyle(fontSize: 22, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets for Table ---

  Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  Widget _tableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Center(
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

// --- Supporting UI Classes ---

class ReceiptInfoRow extends StatelessWidget {
  final String label;
  final String value;
  const ReceiptInfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("$label: ", style: const TextStyle(fontSize: 22)),
        Text(value, style: const TextStyle(fontSize: 22, decoration: TextDecoration.underline)),
      ],
    );
  }
}

class TotalRow extends StatelessWidget {
  final String label;
  final String amount;
  const TotalRow({super.key, required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(width: 5),
        Text(amount, style: const TextStyle(fontSize: 20, decoration: TextDecoration.underline)),
      ],
    );
  }
}



