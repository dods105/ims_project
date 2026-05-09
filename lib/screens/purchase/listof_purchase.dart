import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/misc.dart';
import '../../designs/drawer.dart';
import '../../designs/themes.dart';
import '../../designs/appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'purchase_section.dart'; 
import 'Buyersinfo.dart';





class ListofPurchase extends StatefulWidget {
  const ListofPurchase({super.key});

  @override
  State<ListofPurchase> createState() => _ListofPurchaseState();
}

class _ListofPurchaseState extends State<ListofPurchase> {
  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _changeController = TextEditingController();

  @override
  void dispose() {
    _cashController.dispose();
    _changeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Purchase List'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Transaction Box
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    "Transaction: 26-04-22-C-08",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.indigo],
                  ),
                ),
                child: const Center(
                  child: Text(
                    "LIST OF PURCHASE",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Table Header
              Container(
                color: Colors.indigo[700],
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const Row(
                  children: [
                    Expanded(child: Center(child: Text("Ref. No.", style: TextStyle(color: Colors.white)))),
                    Expanded(child: Center(child: Text("Name", style: TextStyle(color: Colors.white)))),
                    Expanded(child: Center(child: Text("Qty", style: TextStyle(color: Colors.white)))),
                    Expanded(child: Center(child: Text("Price", style: TextStyle(color: Colors.white)))),
                  ],
                ),
              ),

              // Sample Row (Ideally this would be a ListView.builder)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: const Row(
                  children: [
                    Expanded(child: Center(child: Text("4243737"))),
                    Expanded(child: Center(child: Text("Ice Cream"))),
                    Expanded(child: Center(child: Text("10"))),
                    Expanded(child: Center(child: Text("400"))),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ADD Button
              InkWell(
                onTap: () {
                  // TODO: Logic to add items
                },
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle, size: 24),
                      Text("ADD", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Total Section
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Column(
                    children: [
                      buildLine("TOTAL:", "P 400.00"),
                      const SizedBox(height: 10),
                      buildInputLine("CASH:", _cashController),
                      const SizedBox(height: 10),
                      buildInputLine("CHANGE:", _changeController),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Action Buttons
              Row(
                children: [
                  Expanded(child: buildClearButton()),
                  const SizedBox(width: 16),
                  Expanded(child: buildCheckoutButton()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLine(String label, String value) {
    return Row(
      children: [
        SizedBox(width: 70, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(bottom: 4),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black))),
            child: Text(value, textAlign: TextAlign.right),
          ),
        ),
      ],
    );
  }

  Widget buildInputLine(String label, TextEditingController controller) {
    return Row(
      children: [
        SizedBox(width: 70, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
        Expanded(
          child: TextField(
            controller: controller,
            textAlign: TextAlign.right,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.only(bottom: 4),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildClearButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _cashController.clear();
          _changeController.clear();
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text("Clear"),
    );
  }

  Widget buildCheckoutButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Buyersinfo()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text("Checkout"),
    );
  }
}