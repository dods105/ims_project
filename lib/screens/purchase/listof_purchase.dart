import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/misc.dart';
import '../../designs/drawer.dart';
import '../../designs/themes.dart';
import '../../designs/appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';




class ListofPurchase extends StatefulWidget {
  const ListofPurchase({super.key});

  @override
  _ListofPurchasState createState() => _ListofPurchasState();
}

class _ListofPurchasState extends State<ListofPurchase> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Purchase List', style: AppTheme.displayLarge),
      ),
      endDrawer: AppDrawer(page: '/purchase'),
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
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("Ref. No.", style: TextStyle(color: Colors.white)),
                    Text("Name", style: TextStyle(color: Colors.white)),
                    Text("Quantity", style: TextStyle(color: Colors.white)),
                    Text("Price", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),

              // Sample Row
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("4243737"),
                    Text("Ice Cream"),
                    Text("10"),
                    Text("400"),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ADD Button
              Container(
                height: 70,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 28),
                    Text(
                      "ADD",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Total Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildLine("TOTAL:", "P 400.00"),
                  const SizedBox(height: 10),
                  buildInputLine("CASH:"),
                  const SizedBox(height: 10),
                  buildInputLine("CHANGE:"),
                ],
              ),

              const Spacer(),

              // Bottom Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildButton("Clear"),
                  buildButton("Edit"),
                  buildButton("Checkout"),
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
        SizedBox(
          width: 80,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(bottom: 4),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black)),
            ),
            child: Text(value),
          ),
        ),
      ],
    );
  }

  Widget buildInputLine(String label) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        const Expanded(
          child: TextField(
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.only(bottom: 4),
              border: UnderlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildButton(String text) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.blue,
      ),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}
 