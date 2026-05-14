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
import '../../designs/barcode_scanner_page.dart';
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
  final TextEditingController nameController = TextEditingController();
  final TextEditingController originalprice = TextEditingController();
  final TextEditingController prodcuttypeController = TextEditingController();
  final TextEditingController qtyCtrl = TextEditingController();
  final TextEditingController srpController = TextEditingController();

  String? productType;
  bool isProductTypeCustom = false;
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

  // triggred when add button is clicked

  Future<void> savedproduct(int userId) async {
    /* cheks if this have the required fields:
   * name, quantity, original price and selling price
   */
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
    /*if (originalprice.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter Original Price"),
          backgroundColor: Colors.red,
          duration: Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }*/

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

    /**
     * Checks if barcode number exist in the database
     * if it exists, check for the product name in the database and check the product name input
     * compare if same. if it is prompt user to either:
     *  - Change the existing product name to new one or keep the old one or close the promt
     */
    final barcode = barcodeController.text.trim();
    if (barcode.isNotEmpty) {
      final existingBarcodeProduct = await ref
          .read(inventoryProvider.notifier)
          .getProductByBarcode(userId, barcode);

      if (existingBarcodeProduct != null && mounted) {
        final existingName = existingBarcodeProduct.name;
        final newName = nameController.text.trim();
        bool close = false;

        if (existingName != newName) {
          final keep = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Product Name Mismatch'),
                content: Text(
                  'Barcode $barcode is already usesd by product "$existingName"\n\nYou entered "$newName". Do you want to keep the existing name or change it?',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                      close = true;
                    },
                    child: Text('Close'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Keep Existing Name'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.brandBlue,
                    ),
                    child: Text('Change Product Name'),
                  ),
                ],
              );
            },
          );

          if (close == true) {
            return;
          }

          if (keep == false) {
            nameController.text = existingName;
          }
        }
      }
    }

    var product = Product(
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

    /**
     * Checks if product already exist in the database
     * if it exists, update the quantity -> old quatity + new quantity
     * if price change is detected (original or selling price):
     * - ask to update the rest of the product price saved in the databaase
     * - close the prompt, keepp old price, update price
     */
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
                    'Close',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text(
                    'No, Keep Old Price',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(false),
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

        if (confirm == true) {
          // User chose not to update price, add product with original price
          product = Product(
            userId: product.userId,
            name: product.name,
            quantity: product.quantity,
            sellingPrice: sellingPrice,
            originalPrice: originalPrice,
            productType: product.productType,
            expiryDate: product.expiryDate,
            barcode: product.barcode,
            description: product.description,
            imagePath: product.imagePath,
          );
        }
      }
    }

    // ad or update product to the database
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

  // image choices
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

  // expiration date selection
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
                                elevation: 0,
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
                            textCapitalization: TextCapitalization.characters,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[A-Z\s]'),
                              ),
                            ],
                            onChanged: (value) {
                              nameController.value = TextEditingValue(
                                text: value.toUpperCase(),
                                selection: TextSelection.collapsed(
                                  offset: value.length,
                                ),
                              );
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              hintText: 'Enter Product Name',
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

                // barcode input
                TextField(
                  controller: barcodeController,
                  decoration: InputDecoration(
                    hintText: 'Barcode number...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey),
                    ),

                    suffixIcon: Transform.translate(
                      offset: const Offset(-6, 0),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          splashColor: Colors.blue.withOpacity(0.2),
                          highlightColor: Colors.blue.withOpacity(0.15),
                          onTap: () async {
                            await Future.delayed(
                              const Duration(milliseconds: 150),
                            );

                            final scannedBarcode = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const BarcodeScannerPage(),
                              ),
                            );

                            if (scannedBarcode != null) {
                              setState(() {
                                barcodeController.text = scannedBarcode;
                              });
                            }
                          },

                          child: const SizedBox(
                            width: 30,
                            height: 30,
                            child: Center(
                              child: Icon(
                                Icons.qr_code_scanner,
                                size: 28,
                                color: Colors.black,
                              ),
                            ),
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

                // original price
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

                // srp
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

                // product type selection
                Text('TYPE'),
                SizedBox(height: 5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownMenu<String>(
                      width: double.infinity,
                      // initialSelection: productType ?? types.first,
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

                // add button
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
