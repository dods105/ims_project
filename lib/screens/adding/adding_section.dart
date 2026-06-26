import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/products/products.dart';
import 'package:flutter_application_1/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../database/database_helper.dart';
import '../../designs/drawer.dart';
import '../../designs/appbar.dart';
import 'package:image_picker/image_picker.dart';
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
  final TextEditingController qtyCtrl = TextEditingController();
  final TextEditingController srpController = TextEditingController();

  // product type field.
  final TextEditingController _typeController = TextEditingController();
  String? productType;

  //preset type.
  bool isProductTypeCustom = false;

  List<String> types = [
    "DRINKS",
    "FROZEN FOODS",
    "CANNED GOODS",
    "BISCUITS",
    "SNACKS",
    'TOILETRIES',
    'CLEANING SUPPLIES',
  ];
  bool _isLoadingTypes = true;

  //overlay for the custom dropdown
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final FocusNode _typeFocusNode = FocusNode();

  String? _expiryDate;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
    _typeFocusNode.addListener(() {
      if (_typeFocusNode.hasFocus) {
        _showTypeOverlay();
      } else {
        _removeTypeOverlay();
        final val = _typeController.text.trim().toUpperCase();
        setState(() {
          productType = val.isEmpty ? null : val;
          isProductTypeCustom = val.isNotEmpty && !types.contains(val);
        });
      }
    });
  }

  @override
  void dispose() {
    barcodeController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    qtyCtrl.dispose();
    originalprice.dispose();
    srpController.dispose();
    expiryController.dispose();
    _typeController.dispose();
    _typeFocusNode.dispose();
    _removeTypeOverlay();
    super.dispose();
  }

  //gets any custom categories user has saved before and turns into the preset list sorted alphabetically
  Future<void> _loadCategories() async {
    final userId = ref.read(authProvider).value?.id;
    if (userId != null) {
      try {
        final items = await DatabaseHelper.instance.getCategoryNames(userId);
        if (mounted) {
          setState(() {
            final addedTypes = <String>[];
            for (var item in items) {
              if (!types.contains(item)) addedTypes.add(item);
            }
            addedTypes.sort();
            types.addAll(addedTypes);
            _isLoadingTypes = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _isLoadingTypes = false);
      }
    } else {
      if (mounted) setState(() => _isLoadingTypes = false);
    }
  }

  //returns filtered list of types based on text input.
  List<String> get _filteredTypes {
    final query = _typeController.text.trim().toUpperCase();
    if (query.isEmpty) return types;
    return types.where((t) => t.contains(query)).toList();
  }

  void _showTypeOverlay() {
    _removeTypeOverlay();
    _overlayEntry = _buildOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeTypeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _refreshOverlay() {
    if (_overlayEntry != null) {
      _removeTypeOverlay();
      _overlayEntry = _buildOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  OverlayEntry _buildOverlayEntry() {
    final userId = ref.read(authProvider).value?.id;

    return OverlayEntry(
      builder: (context) {
        //live-read the text input and display corresponding type
        double fieldWidth = 300;
        final RenderBox? renderBox =
            _typeFocusNode.context?.findRenderObject() as RenderBox?;
        if (renderBox != null && renderBox.attached && renderBox.hasSize) {
          fieldWidth = renderBox.size.width;
        }

        return Stack(
          children: [
            // tap outside to dismiss the dropdown.
            Positioned.fill(
              child: GestureDetector(
                onTap: () => _typeFocusNode.unfocus(),
                behavior: HitTestBehavior.translucent,
              ),
            ),

            //place dropdown above product type field
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              targetAnchor: Alignment.topLeft,
              followerAnchor: Alignment.bottomLeft,
              offset: const Offset(0, -4),
              child: SizedBox(
                width: fieldWidth,
                child: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(10),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 260),
                    child: Builder(
                      builder: (context) {
                        final filtered = _filteredTypes;

                        return ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final type = filtered[index];
                            final isDefault = [
                              "DRINKS",
                              "FROZEN FOODS",
                              "CANNED GOODS",
                              "BISCUITS",
                              "SNACKS",
                              "TOILETRIES",
                              "CLEANING SUPPLIES",
                            ].contains(type);

                            return ListTile(
                              dense: true,
                              title: Text(type),
                              trailing: !isDefault && userId != null
                                  ? GestureDetector(
                                      onTap: () =>
                                          _deleteCustomCategory(type, userId),
                                      child: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                    )
                                  : null,
                              onTap: () {
                                _typeController.text = type;
                                setState(() {
                                  productType = type;
                                  isProductTypeCustom = false;
                                });
                                _typeFocusNode.unfocus();
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCustomCategory(String categoryName, int userId) async {
    _removeTypeOverlay();
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Are you sure you want to delete "$categoryName" from your categories?\n\n'
          'Note: This will only remove the category from the list. '
          'Products with this category will keep their type.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      try {
        final db = await DatabaseHelper.instance.database;
        await db.delete(
          'categories',
          where: 'user_id = ? AND category_name = ?',
          whereArgs: [userId, categoryName],
        );
        setState(() {
          types.remove(categoryName);
          if (productType == categoryName) {
            productType = null;
            _typeController.clear();
          }
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Category "$categoryName" deleted successfully'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting category: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _saveCustomTypeIfNeeded(int userId) async {
    if (!isProductTypeCustom ||
        productType == null ||
        productType!.trim().isEmpty) {
      return;
    }

    final db = await DatabaseHelper.instance.database;
    final existing = await db.query(
      'categories',
      where: 'user_id = ? AND category_name = ?',
      whereArgs: [userId, productType!.trim()],
    );

    if (existing.isEmpty) {
      final shouldSave = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Save New Category'),
          content: Text(
            'Do you want to save "${productType!}" to your categories list?\n\n'
            'If you save it, you\'ll be able to select it from the dropdown next time.\n'
            'If not, you\'ll need to type it again for future products.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop("no"),
              child: const Text('No, Don\'t Save'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop("yes"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.brandBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Yes, Save Category'),
            ),
          ],
        ),
      );

      if (shouldSave == "yes") {
        await DatabaseHelper.instance.insertCustomCategory(
          userId,
          productType!.trim(),
        );
        if (!types.contains(productType)) {
          setState(() => types.add(productType!));
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Category "${productType!}" saved!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } else {
      if (!types.contains(productType)) {
        setState(() => types.add(productType!));
      }
    }
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

    //check if product type is custom or already in the type list
    final typedValue = _typeController.text.trim().toUpperCase();
    if (typedValue.isNotEmpty) {
      productType = typedValue;
      isProductTypeCustom = !types.contains(typedValue);
    }

    await _saveCustomTypeIfNeeded(userId);

    final barcode = barcodeController.text.trim();
    if (barcode.isNotEmpty) {
      final existingBarcodeProduct = await ref
          .read(inventoryProvider.notifier)
          .getProductByBarcode(userId, barcode);

      if (existingBarcodeProduct != null && mounted) {
        final existingName = existingBarcodeProduct.name;
        final newName = nameController.text.trim();

        if (existingName != newName) {
          final result = await showDialog<String>(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Product Name Mismatch'),
              content: Text(
                'Barcode $barcode is already used by "$existingName"\n\n'
                'You entered "$newName". Keep the existing name or change it?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop('close'),
                  child: const Text('Close'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop('keep'),
                  child: const Text('Keep Existing Name'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop('change'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.brandBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Change Product Name'),
                ),
              ],
            ),
          );

          if (result == null || result == 'close') return;
          if (result == 'keep') nameController.text = existingName;
        }
      }
    }

    //Product obejct creation
    var product = Product(
      userId: userId,
      name: nameController.text.trim(),
      quantity: int.tryParse(qtyCtrl.text) ?? 0,
      sellingPrice: double.tryParse(srpController.text) ?? 0.0,
      originalPrice: double.tryParse(originalprice.text) ?? 0.0,
      productType: productType?.trim() ?? "UNCATEGORIZED",
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

    //if product already exist, chack price if same or not
    //if not show pop up regarding price change
    if (duplicateProduct != null && mounted) {
      final double sellingPrice = duplicateProduct.sellingPrice;
      final double originalPrice = duplicateProduct.originalPrice ?? 0.0;
      final double newSell = product.sellingPrice;
      final double newOriginal = product.originalPrice ?? 0.0;

      final bool priceChange =
          sellingPrice != newSell || originalPrice != newOriginal;

      if (priceChange) {
        final result = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Price Change Detected'),
            content: const Text(
              'This product already exists with a different price.\n\n'
              'Do you want to update the price for ALL existing stock to the new price?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop('close'),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop('keep'),
                child: const Text(
                  'No, Keep Old Price',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop('update'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.brandBlue,
                ),
                child: const Text(
                  'Yes, Update Price',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );

        if (result == null || result == 'close') return;

        // keep old product price, dont update price
        if (result == 'keep') {
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
    if (path != null) setState(() => _imagePath = path);
  }

  void _removePhoto() => setState(() => _imagePath = null);

  void _showActionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Upload Photo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Remove Photo'),
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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _expiryDate = DateFormat('MM-dd-yyyy').format(picked);
        expiryController.text = _expiryDate!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authProvider).value?.id;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBarDesign(page: 'ADD PRODUCT'),
      endDrawer: const AppDrawer(page: '/adding'),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15.5, 20.0, 30.0, 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //mage upload
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 25),
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
                                foregroundColor: AppTheme.brandBlue,
                                side: BorderSide(color: AppTheme.brandBlue),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: _showActionDialog,
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
                                          color: AppTheme.brandBlue,
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Photo',
                                          style: TextStyle(
                                            color: AppTheme.brandBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 15),

                    //name ad description
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('PRODUCT NAME'),
                          const SizedBox(height: 5),
                          TextField(
                            controller: nameController,
                            textCapitalization: TextCapitalization.characters,
                            onChanged: (value) {
                              nameController.value = TextEditingValue(
                                text: value.toUpperCase(),
                                selection: TextSelection.collapsed(
                                  offset: value.length,
                                ),
                              );
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              hintText: 'Enter Product Name',
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Text('DESCRIPTION'),
                          const SizedBox(height: 5),
                          TextField(
                            controller: descriptionController,
                            minLines: 1,
                            maxLines: null,
                            decoration: const InputDecoration(
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

                const SizedBox(height: 20),

                //Barcode
                TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: barcodeController,
                  decoration: InputDecoration(
                    hintText: 'Barcode number...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
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
                              child: Icon(Icons.qr_code_scanner, size: 28),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Qty / Expiry labels
                Row(
                  children: [
                    SizedBox(
                      width: screenWidth / 2 - 50,
                      child: const Text('NO. OF ITEMS'),
                    ),
                    const SizedBox(width: 35),
                    SizedBox(
                      width: screenWidth / 2 - 50,
                      child: const Text('EXPIRATION DATE'),
                    ),
                  ],
                ),
                const SizedBox(height: 5),

                // Qty / Expiry fields
                Row(
                  children: [
                    Flexible(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        controller: qtyCtrl,
                        decoration: const InputDecoration(
                          hintText: '0',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: TextField(
                        controller: expiryController,
                        decoration: const InputDecoration(
                          hintText: 'Select Date',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        onTap: _selectDate,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // Price labels
                Row(
                  children: [
                    SizedBox(
                      width: screenWidth / 2 - 50,
                      child: const Text('ORG. PRICE'),
                    ),
                    const SizedBox(width: 35),
                    SizedBox(
                      width: screenWidth / 2 - 50,
                      child: const Text('SRP'),
                    ),
                  ],
                ),

                // Price fields
                Row(
                  children: [
                    Flexible(
                      child: TextField(
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*'),
                          ),
                        ],
                        controller: originalprice,
                        decoration: const InputDecoration(
                          hintText: 'P 00.0',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: TextField(
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*'),
                          ),
                        ],
                        controller: srpController,
                        decoration: const InputDecoration(
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

                const SizedBox(height: 15),

                // Product TYPE
                const Text('TYPE'),
                const SizedBox(height: 5),
                //load produvt type from db
                if (_isLoadingTypes)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: const [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 10),
                        Text('Loading categories...'),
                      ],
                    ),
                  )
                else
                  //TextField with custom overlay list
                  CompositedTransformTarget(
                    link: _layerLink,
                    child: TextField(
                      controller: _typeController,
                      focusNode: _typeFocusNode,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
                        TextInputFormatter.withFunction((old, newVal) {
                          final upper = newVal.text.toUpperCase();
                          return newVal.copyWith(
                            text: upper,
                            selection: TextSelection.collapsed(
                              offset: upper.length,
                            ),
                          );
                        }),
                      ],
                      onChanged: (_) {
                        //rebuild the overlay so filtered list update
                        _refreshOverlay();
                        final val = _typeController.text.trim().toUpperCase();
                        setState(() {
                          productType = val.isEmpty ? null : val;
                          isProductTypeCustom =
                              val.isNotEmpty && !types.contains(val);
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Select or type a category…',
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            //clear button. only visible when there is text.
                            // the x button
                            if (_typeController.text.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _typeController.clear();
                                  setState(() {
                                    productType = null;
                                    isProductTypeCustom = false;
                                  });
                                  _refreshOverlay();
                                },
                                child: const Icon(Icons.clear, size: 18),
                              ),
                            const Icon(Icons.arrow_drop_down),
                            const SizedBox(width: 4),
                          ],
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Add button
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => savedproduct(userId!),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('Add'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.brandBlue,
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
      ),
    );
  }
}
