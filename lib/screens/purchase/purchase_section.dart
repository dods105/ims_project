import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/purchase/listof_purchase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../designs/drawer.dart';
import '../../designs/themes.dart';
import '../../designs/appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'listof_purchase.dart';




class purchase_section extends StatefulWidget {
  const purchase_section({super.key});

  @override
  _purchase_sectionState createState() => _purchase_sectionState();
}

class _purchase_sectionState extends State<purchase_section> {
  final TextEditingController _searchController = TextEditingController();
  
  bool _isItemSelected = false;
  int _quantity = 1; 

  bool _isItemSelected2 = false;
  int _quantity2 = 1;

  bool _isItemSelected3 = false;
  int _quantity3 = 1;

  bool _isItemSelected4 = false;
  int _quantity4 = 1;

  bool _isItemSelected5 = false;
  int _quantity5 = 1;

  // Function to calculate Total Price
  double _calculateTotalPrice() {
    double total = 0;
    if (_isItemSelected) total += (150.0 * _quantity);
    if (_isItemSelected2) total += (250.0 * _quantity2);
    if (_isItemSelected3) total += (100.0 * _quantity3);
    if (_isItemSelected4) total += (75.0 * _quantity4);
    if (_isItemSelected5) total += (1200.0 * _quantity5);
    return total;
  }

  // Function to calculate Total Items
  int _calculateTotalItems() {
    int count = 0;
    if (_isItemSelected) count += _quantity;
    if (_isItemSelected2) count += _quantity2;
    if (_isItemSelected3) count += _quantity3;
    if (_isItemSelected4) count += _quantity4;
    if (_isItemSelected5) count += _quantity5;
    return count;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarDesign(page: 'Purchase'),
      endDrawer: AppDrawer(page: '/purchase'),

      body: Column(
        children: [
          buildSearchBar(
            controller: _searchController,
            onChanged: (value) => print("Searching for: $value"),
          ),
          Expanded(
            child: SingleChildScrollView( 
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Expanded(flex: 3, child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(flex: 1, child: Center(child: Text('Stock', style: TextStyle(fontWeight: FontWeight.bold)))),
                        Expanded(flex: 1, child: Center(child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold)))),
                        SizedBox(width: 36, child: Center(child: Text('Sell', style: TextStyle(fontWeight: FontWeight.bold)))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  productRow(
                    name: "Product 1",
                    stock: 15,
                    price: 150.0,
                    isSelected: _isItemSelected,
                    quantity: _quantity, 
                    onTap: () => setState(() => _isItemSelected = !_isItemSelected),
                    onIncrease: () => setState(() => _quantity++), 
                    onDecrease: () => setState(() { if (_quantity > 1) _quantity--; }), 
                  ),

                  productRow(
                    name: "Product 2",
                    stock: 20,
                    price: 250.0,
                    isSelected: _isItemSelected2,
                    quantity: _quantity2, 
                    onTap: () => setState(() => _isItemSelected2 = !_isItemSelected2),
                    onIncrease: () => setState(() => _quantity2++), 
                    onDecrease: () => setState(() { if (_quantity2 > 1) _quantity2--; }), 
                  ),

                  productRow(
                    name: "Product 3",
                    stock: 10,
                    price: 100.0,
                    isSelected: _isItemSelected3,
                    quantity: _quantity3, 
                    onTap: () => setState(() => _isItemSelected3 = !_isItemSelected3),
                    onIncrease: () => setState(() => _quantity3++), 
                    onDecrease: () => setState(() { if (_quantity3 > 1) _quantity3--; }), 
                  ),

                  productRow(
                    name: "Product 4",
                    stock: 50,
                    price: 75.0,
                    isSelected: _isItemSelected4,
                    quantity: _quantity4, 
                    onTap: () => setState(() => _isItemSelected4 = !_isItemSelected4),
                    onIncrease: () => setState(() => _quantity4++), 
                    onDecrease: () => setState(() { if (_quantity4 > 1) _quantity4--; }), 
                  ),

                  productRow(
                    name: "Product 5",
                    stock: 5,
                    price: 1200.0,
                    isSelected: _isItemSelected5,
                    quantity: _quantity5, 
                    onTap: () => setState(() => _isItemSelected5 = !_isItemSelected5),
                    onIncrease: () => setState(() => _quantity5++), 
                    onDecrease: () => setState(() { if (_quantity5 > 1) _quantity5--; }), 
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomBar(),
    );
  }

  Widget buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total: ₱${_calculateTotalPrice().toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                "No. of Items: ${_calculateTotalItems()}",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              print("Total Price: ${_calculateTotalPrice()}");
              Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (context) => const ListofPurchase(),
    ),
  );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: Colors.blue,
            ),
            child: const Text("Confirm", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget productRow({
    required String name,
    required int stock,
    required double price,
    required bool isSelected,
    required int quantity,
    required VoidCallback onTap,
    required VoidCallback onIncrease,
    required VoidCallback onDecrease,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isSelected ? Colors.blue : Colors.transparent, width: 2),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text(name, style: const TextStyle(fontSize: 16))),
                Expanded(flex: 1, child: Center(child: Text("$stock"))),
                Expanded(flex: 1, child: Center(child: Text("$price"))),
                Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.green.shade900, width: 3),
                  ),
                  child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                ),
              ],
            ),
          ),
        ),
        if (isSelected)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Quantity", style: TextStyle(fontSize: 16)),
                    Row(
                      children: [
                        IconButton(onPressed: onDecrease, icon: const Icon(Icons.remove_circle_outline)),
                        Container(
                          width: 60,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(child: Text("$quantity", style: const TextStyle(fontWeight: FontWeight.bold))),
                        ),
                        IconButton(onPressed: onIncrease, icon: const Icon(Icons.add_circle_outline)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Price", style: TextStyle(fontSize: 16)),
                    Container(
                      width: 110,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        border: Border.all(color: Colors.blue.shade200),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          "₱${(price * quantity).toStringAsFixed(2)}",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget buildSearchBar({required TextEditingController controller, Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: "search product name....",
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(60), borderSide: BorderSide.none),
          suffixIcon: const Icon(Icons.qr_code, color: Colors.black),
        ),
      ),
    );
  }
}