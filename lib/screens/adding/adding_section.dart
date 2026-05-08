import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/products/products.dart';
import 'package:flutter_application_1/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../designs/drawer.dart';
import '../../designs/appbar.dart';
import 'package:image_picker/image_picker.dart'; // Add new logic function
import 'dart:io';
import '../../designs/themes.dart';
import '../../providers/inventoryProvider.dart';
import 'barcode_scanner_page.dart';
import 'package:flutter/services.dart';

class AddingSectionPage extends ConsumerStatefulWidget {
  const AddingSectionPage({super.key});

  @override
  ConsumerState<AddingSectionPage> createState() => _AddingSectionPageState();
}

class _AddingSectionPageState extends ConsumerState<AddingSectionPage> {
  final TextEditingController barcodeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  bool isProductTypeCustom = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController originalprice = TextEditingController();
  final TextEditingController prodcuttypeController = TextEditingController();
  String? productType;
  final TextEditingController qtyCtrl = TextEditingController();
  final TextEditingController srpController = TextEditingController();
  final List<String> types = [
    "DRINKS",
    "FROZEN FOODS",
    "CANNED GOODS",
    "BAKERY",
    "BISCUITS",
    "SNACKS",
    'TOILETRIES',
    'CLEANING SUPPLIES',
  ];

  String? _expiryDate;
  String? _imagePath;

  @override
  void dispose() {
    barcodeController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    qtyCtrl.dispose();
    originalprice.dispose();
    srpController.dispose();
    expiryController.dispose();
    prodcuttypeController.dispose();
    super.dispose();
  }

  Future<void> savedproduct(int userId) async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter Product Name"),
          backgroundColor: Colors.red,
          duration: Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (qtyCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter No. of Items"),
          backgroundColor: Colors.red,
          duration: Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (originalprice.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter Original Price"),
          backgroundColor: Colors.red,
          duration: Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (srpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter SRP"),
          backgroundColor: Colors.red,
          duration: Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final product = Product(
      userId: userId,
      name: nameController.text.trim(),
      quantity: int.tryParse(qtyCtrl.text) ?? 0,
      sellingPrice: double.tryParse(srpController.text) ?? 0.0,
      originalPrice: double.tryParse(originalprice.text) ?? 0.0,
      productType: productType,
      expiryDate: _expiryDate,
      barcode: barcodeController.text.trim().isEmpty
          ? null
          : barcodeController.text.trim(),
      description: descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
      imagePath: _imagePath,
    );

    final duplicateProduct = await ref
        .read(inventoryProvider.notifier)
        .getExistingProduct(product);

    if (duplicateProduct != null && mounted) {
      final double sellingPrice = duplicateProduct.sellingPrice;
      final double originalPrice = duplicateProduct.originalPrice ?? 0.0;
      final double newSell = product.sellingPrice;
      final double newOriginal = product.originalPrice ?? 0.0;

      bool priceChange =
          sellingPrice != newSell || originalPrice != newOriginal;

      if (priceChange) {
        final bool? confirm = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Price Change Detected'),
              content: const Text(
                'This product already exists in your inventory with a different price.\n\n'
                'Do you want to update the price for ALL existing stock of this product to the new price?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'No, Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.brandBlue,
                  ),
                  child: const Text(
                    'Yes, Update Price',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );

        if (confirm != true) {
          return;
        }
      }
    }

    await ref.read(inventoryProvider.notifier).addProduct(product);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Product added successfully!"),
          backgroundColor: AppTheme.textGreen,
        ),
      );

      Navigator.pushReplacementNamed(context, '/inventory');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final path = await ref
        .read(inventoryProvider.notifier)
        .pickAndSaveImage(source);

    if (path != null) {
      setState(() {
        _imagePath = path;
      });
    }
  }

  void _removePhoto() {
    setState(() {
      _imagePath = null;
    });
  }

  void _showActionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text('Upload Photo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Remove Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _removePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 30)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _expiryDate = DateFormat('yyyy-MM-dd').format(picked);
        expiryController.text = _expiryDate!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.read(authProvider).value?.id;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBarDesign(page: 'ADD PRODUCT'),
      endDrawer: const AppDrawer(page: '/adding'),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(15.5, 20.0, 30.0, 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Horizontal center
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LEFT SIDE (Upload UI)
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 25),
                          SizedBox(
                            height: 100,
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                elevation:
                                    0, // remove default shadow if you want flat look
                                backgroundColor: const Color.from(
                                  alpha: 0,
                                  red: 0,
                                  green: 0,
                                  blue: 0,
                                ),
                                foregroundColor: const Color.fromARGB(
                                  255,
                                  38,
                                  15,
                                  144,
                                ),
                                side: BorderSide(
                                  color: Color.fromARGB(255, 38, 15, 144),
                                ), // border
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                _showActionDialog();
                              },
                              child: _imagePath != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(_imagePath!),
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_a_photo,
                                          size: 28.0,
                                          color: const Color.fromARGB(
                                            255,
                                            38,
                                            15,
                                            144,
                                          ),
                                        ),
                                        SizedBox(height: 3),
                                        Text(
                                          'Photo',
                                          style: TextStyle(
                                            color: const Color.fromARGB(
                                              255,
                                              38,
                                              15,
                                              137,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 15),

                    // RIGHT SIDE (Name + Description)
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PRODUCT NAME'),
                          SizedBox(height: 5),
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              hintText: 'Enter product name',
                            ),
                          ),

                          SizedBox(height: 15),

                          Text('DESCRIPTION'),
                          SizedBox(height: 5),
                          TextField(
                            controller: descriptionController,
                            minLines: 1,
                            maxLines: null, // makes description taller
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              hintText: 'Tap to add description',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TextField(
                  controller: barcodeController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    hintText: 'Barcode number...',
                    suffixIcon: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        splashColor: Colors.blue.withOpacity(0.2),
                        highlightColor: Colors.blue.withOpacity(0.15),
                        onTap: () async {
                          await Future.delayed(Duration(milliseconds: 150));
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BarcodeScannerPage(),
                            ),
                          );
                        },
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: Icon(
                            Icons.qr_code_scanner,
                            size: 32,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Row(
                  children: [
                    SizedBox(
                      width: screenWidth / 2 - 50,
                      child: Text('NO. OF ITEMS'),
                    ),

                    SizedBox(width: 35.0),

                    SizedBox(
                      width: screenWidth / 2 - 50,
                      child: Text('EXPIRATION DATE'),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    // First TextField
                    Flexible(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        controller: qtyCtrl,
                        decoration: InputDecoration(
                          hintText: '0',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.0), // Second TextField
                    Flexible(
                      child: TextField(
                        controller: expiryController,
                        decoration: InputDecoration(
                          hintText: 'Select Date',
                          filled: true,
                          fillColor: Colors.transparent,
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                        readOnly: true,
                        onTap: () {
                          _selectDate();
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.0),
                Row(
                  children: [
                    SizedBox(
                      width: screenWidth / 2 - 50,
                      child: Text('ORG. PRICE'),
                    ),

                    SizedBox(width: 35.0),

                    SizedBox(width: screenWidth / 2 - 50, child: Text('SRP')),
                  ],
                ),
                Row(
                  children: [
                    // First TextField
                    Flexible(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        controller: originalprice,
                        decoration: InputDecoration(
                          hintText: 'P 00.0',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.0), // Second TextField
                    Flexible(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        controller: srpController,
                        decoration: InputDecoration(
                          hintText: 'P 00.0',
                          fillColor: Colors.transparent,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownMenu<String>(
                      width: double.infinity,
                      initialSelection: productType ?? types.first,
                      enableFilter: true,
                      requestFocusOnTap: false,
                      onSelected: (String? newValue) {
                        setState(() {
                          if (newValue == "Other") {
                            isProductTypeCustom = true;
                            productType = null;
                            prodcuttypeController.clear();
                          } else {
                            isProductTypeCustom = false;
                            productType = newValue;
                          }
                        });
                      },
                      dropdownMenuEntries: [
                        ...types.map(
                          (type) => DropdownMenuEntry<String>(
                            value: type,
                            label: type,
                          ),
                        ),
                        const DropdownMenuEntry<String>(
                          value: "Other",
                          label: "OTHER (TYPE MANUALLY)",
                        ),
                      ],
                    ),

                    if (isProductTypeCustom)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: TextField(
                          controller: prodcuttypeController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z ]'),
                            ),
                            TextInputFormatter.withFunction((
                              oldValue,
                              newValue,
                            ) {
                              final upper = newValue.text.toUpperCase();

                              return newValue.copyWith(
                                text: upper,
                                selection: TextSelection.collapsed(
                                  offset: upper.length,
                                ),
                              );
                            }),
                          ],
                          decoration: const InputDecoration(
                            hintText: "Enter product type",
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            productType = value.toUpperCase();
                          },
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          savedproduct(userId!);
                        },
                        icon: Icon(Icons.add, color: Colors.white),
                        label: Text('Add'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ), // left, top, right, bottom,),
    );
  }
}
