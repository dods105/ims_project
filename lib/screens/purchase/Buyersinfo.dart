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
import 'Receipt.dart';





void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Buyersinfo(),
  ));
}

class Buyersinfo extends StatefulWidget {
  const Buyersinfo({super.key});

  @override
  _BuyersinfoState createState() => _BuyersinfoState();
}

class _BuyersinfoState extends State<Buyersinfo> {
  // Controllers to handle text input
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cashController = TextEditingController();

  final double totalAmount = 400.00;

  // Logic to calculate change in real-time
  double get change {
    double cash = double.tryParse(cashController.text) ?? 0;
    return cash - totalAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.lightBlue[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Inner White Box for Fields
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Column(
                    children: [
                      buildTextField(
                        label: "NAME",
                        controller: nameController,
                      ),
                      const SizedBox(height: 15),
                      buildTextField(
                        label: "ADDRESS",
                        controller: addressController,
                      ),
                      const SizedBox(height: 15),
                      
                      // Total Amount Display
                      Row(
                        children: [
                          const Text(
                            "• TOTAL AMOUNT: ",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "₱${totalAmount.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 22,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Cash Input
                      buildTextField(
                        label: "CASH",
                        controller: cashController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) {
                          setState(() {}); // Updates the Change display
                        },
                      ),
                      const SizedBox(height: 15),

                      // Change Display
                      Row(
                        children: [
                          const Text(
                            "• CHANGE: ",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "₱${change >= 0 ? change.toStringAsFixed(2) : "0.00"}",
                            style: const TextStyle(
                              fontSize: 22,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Separated Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildCancelButton(),
                    buildConfirmButton(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper for Text Fields
  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
  }) {
    return Row(
      children: [
        Text(
          "• $label: ",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
            decoration: const InputDecoration(
              isDense: true,
              border: UnderlineInputBorder(),
            ),
            style: const TextStyle(fontSize: 22),
          ),
        ),
      ],
    );
  }

  // Separate Logic for Cancel Button
  Widget buildCancelButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onPressed: () {
        print("Cancel pressed: Clearing information...");
        nameController.clear();
        addressController.clear();
        cashController.clear();
        setState(() {}); // Refresh UI to reset Change display
      },
      child: const Text(
        "CANCEL",
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  // Separate Logic for Confirm Button
  Widget buildConfirmButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onPressed: () {
       Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Receipt()),
        );
      },
      child: const Text(
        "CONFIRM",
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }
}