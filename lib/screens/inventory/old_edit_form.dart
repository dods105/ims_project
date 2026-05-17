import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../designs/barcode_scanner_page.dart';
import '../../designs/themes.dart';
import '../../models/products/products.dart';
import '../../providers/inventoryProvider.dart';

class EditProductPage extends ConsumerStatefulWidget {
  final Product product;

  EditProductPage({super.key, required this.product});

  @override
  ConsumerState<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends ConsumerState<EditProductPage> {
  late final TextEditingController barcodeController;
  late final TextEditingController descriptionController;
  late final TextEditingController expiryController;
  late final TextEditingController nameController;
  late final TextEditingController originalPriceController;
  late final TextEditingController productTypeController;
  late final TextEditingController qtyCtrl;
  late final TextEditingController srpController;

  String? productType;
  bool isProductTypeCustom = false;

  final List<String> types = [
    'DRINKS',
    'FROZEN FOODS',
    'CANNED GOODS',
    'BAKERY',
    'BISCUITS',
    'SNACKS',
    'TOILETRIES',
    'CLEANING SUPPLIES',
  ];

  String? _expiryDate;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    final p = widget.product;

    nameController = TextEditingController(text: p.name);
    descriptionController = TextEditingController(text: p.description ?? '');
    barcodeController = TextEditingController(text: p.barcode ?? '');
    qtyCtrl = TextEditingController(text: '${p.quantity}');
    originalPriceController = TextEditingController(
      text: p.originalPrice?.toString() ?? '',
    );
    srpController = TextEditingController(text: p.sellingPrice.toString());
    _expiryDate = p.expiryDate;
    expiryController = TextEditingController(text: p.expiryDate ?? '');
    _imagePath = p.imagePath;

    productType = p.productType;
    productTypeController = TextEditingController(text: p.productType ?? '');
    isProductTypeCustom =
        p.productType != null && !types.contains(p.productType);
  }

  @override
  void dispose() {
    barcodeController.dispose();
    descriptionController.dispose();
    expiryController.dispose();
    nameController.dispose();
    originalPriceController.dispose();
    productTypeController.dispose();
    qtyCtrl.dispose();
    srpController.dispose();
    super.dispose();
  }

  //  Image picker
  Future<void> _pickImage(ImageSource source) async {
    final path = await ref
        .read(inventoryProvider.notifier)
        .pickAndSaveImage(source);
    if (path != null) setState(() => _imagePath = path);
  }

  void _removePhoto() => setState(() => _imagePath = null);

  void _showPhotoDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Photo'),
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
      ),
    );
  }

  //  Date picker
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate != null
          ? DateTime.tryParse(_expiryDate!) ??
                DateTime.now().add(Duration(days: 30))
          : DateTime.now().add(Duration(days: 30)),
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

  //  Save
  Future<void> _save() async {
    if (nameController.text.trim().isEmpty) {
      _snack('Enter Product Name', isError: true);
      return;
    }
    if (qtyCtrl.text.isEmpty) {
      _snack('Enter No. of Items', isError: true);
      return;
    }

    if (srpController.text.isEmpty) {
      _snack('Enter SRP', isError: true);
      return;
    }

    final updated = Product(
      id: widget.product.id,
      userId: widget.product.userId,
      name: nameController.text.trim(),
      quantity: int.tryParse(qtyCtrl.text) ?? 0,
      sellingPrice: double.tryParse(srpController.text) ?? 0.0,
      originalPrice: double.tryParse(originalPriceController.text),
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

    await ref.read(inventoryProvider.notifier).updateProduct(updated);

    if (mounted) {
      _snack('Product updated successfully!');
      Navigator.pop(context);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppTheme.textRed : AppTheme.textGreen,
        duration: Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(title: Text('EDIT PRODUCT')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //  Photo + Name / Description
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo button
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
                              backgroundColor: Colors.transparent,
                              foregroundColor: AppTheme.brandBlue,
                              side: BorderSide(color: AppTheme.brandBlue),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _showPhotoDialog,
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo, size: 28),
                                      SizedBox(height: 3),
                                      Text('Photo'),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 15),

                  // Name + Description
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
                            border: OutlineInputBorder(),
                            hintText: 'Enter product name',
                          ),
                        ),
                        SizedBox(height: 15),
                        Text('DESCRIPTION'),
                        SizedBox(height: 5),
                        TextField(
                          controller: descriptionController,
                          minLines: 1,
                          maxLines: null,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Tap to add description',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              //  Barcode
              TextField(
                controller: barcodeController,
                decoration: InputDecoration(
                  hintText: 'Barcode number…',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: Transform.translate(
                    offset: Offset(-6, 0),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        customBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        splashColor: AppTheme.brandBlue.withOpacity(0.2),
                        onTap: () async {
                          await Future.delayed(Duration(milliseconds: 150));
                          final scanned = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BarcodeScannerPage(),
                            ),
                          );
                          if (scanned != null) {
                            setState(() => barcodeController.text = scanned);
                          }
                        },
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: Center(
                            child: Icon(Icons.qr_code_scanner, size: 28),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              //  Qty + Expiry
              Row(
                children: [
                  SizedBox(
                    width: screenWidth / 2 - 50,
                    child: Text('NO. OF ITEMS'),
                  ),
                  SizedBox(width: 35),
                  SizedBox(
                    width: screenWidth / 2 - 50,
                    child: Text('EXPIRATION DATE'),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Flexible(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      controller: qtyCtrl,
                      decoration: InputDecoration(
                        hintText: '0',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    child: TextField(
                      controller: expiryController,
                      readOnly: true,
                      onTap: _selectDate,
                      decoration: InputDecoration(
                        hintText: 'Select Date',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 15),

              //  Prices
              Row(
                children: [
                  SizedBox(
                    width: screenWidth / 2 - 50,
                    child: Text('ORG. PRICE'),
                  ),
                  SizedBox(width: 35),
                  SizedBox(width: screenWidth / 2 - 50, child: Text('SRP')),
                ],
              ),
              Row(
                children: [
                  Flexible(
                    child: TextField(
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                      controller: originalPriceController,
                      decoration: InputDecoration(
                        hintText: 'P 00.0',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    child: TextField(
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                      controller: srpController,
                      decoration: InputDecoration(
                        hintText: 'P 00.0',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 15),
              Text('TYPE'),
              SizedBox(height: 5),

              //  Product type
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownMenu<String>(
                    width: double.infinity,
                    initialSelection: types.contains(productType)
                        ? productType
                        : (isProductTypeCustom ? 'Other' : null),
                    enableFilter: true,
                    requestFocusOnTap: false,
                    onSelected: (String? newValue) {
                      setState(() {
                        if (newValue == 'Other') {
                          isProductTypeCustom = true;
                          productType = null;
                          productTypeController.clear();
                        } else {
                          isProductTypeCustom = false;
                          productType = newValue;
                        }
                      });
                    },
                    dropdownMenuEntries: [
                      ...types.map(
                        (t) => DropdownMenuEntry<String>(value: t, label: t),
                      ),
                      DropdownMenuEntry<String>(
                        value: 'Other',
                        label: 'OTHER (TYPE MANUALLY)',
                      ),
                    ],
                  ),
                  if (isProductTypeCustom)
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: TextField(
                        controller: productTypeController,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z ]'),
                          ),
                          TextInputFormatter.withFunction((old, nv) {
                            final u = nv.text.toUpperCase();
                            return nv.copyWith(
                              text: u,
                              selection: TextSelection.collapsed(
                                offset: u.length,
                              ),
                            );
                          }),
                        ],
                        decoration: InputDecoration(
                          hintText: 'Enter product type',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) => productType = v.toUpperCase(),
                      ),
                    ),
                ],
              ),

              SizedBox(height: 24),

              //  Save button
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _save,
                      icon: Icon(Icons.save_outlined, color: Colors.white),
                      label: Text('Save Changes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.brandBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
