import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../database/database_helper.dart';
import '../../designs/barcode_scanner_page.dart';
import '../../designs/themes.dart';
import '../../models/products/products.dart';
import '../../providers/auth_provider.dart';
import '../../providers/inventoryProvider.dart';

class EditProductPage extends ConsumerStatefulWidget {
  final Product product;
  final ScrollController? scrollController;

  const EditProductPage({
    super.key,
    required this.product,
    this.scrollController,
  });

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

  bool isEditing = false;
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

  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final FocusNode _typeFocusNode = FocusNode();

  List<String> get _filteredTypes {
    final query = productTypeController.text.trim().toUpperCase();
    if (query.isEmpty) return types;
    return types.where((t) => t.contains(query)).toList();
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

  void _showTypeOverlay() {
    _removeTypeOverlay();
    _overlayEntry = _buildOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  OverlayEntry _buildOverlayEntry() {
    final userId = ref.read(authProvider).value?.id;

    // Get the text field's position and size
    final RenderBox renderBox =
        _typeFocusNode.context!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final double fieldWidth = renderBox.size.width;

    return OverlayEntry(
      builder: (context) {
        return GestureDetector(
          onTap: () {
            _typeFocusNode.unfocus();
          },
          behavior: HitTestBehavior.translucent,
          child: Stack(
            children: [
              Positioned(
                left: offset.dx,
                // Position it ABOVE the text field
                bottom: MediaQuery.of(context).size.height - offset.dy + 4,
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
                              "BAKERY",
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
                                productTypeController.text = type;
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
            ],
          ),
        );
      },
    );
  }

  // ── Category CRUD ────────────────────────────────────────────────────────

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
            productTypeController.clear();
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

    // Load custom categories silently in the background, default categories are shown
    // immediately so the field is never blocked waiting for the DB call.
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCategories());

    _typeFocusNode.addListener(() {
      if (_typeFocusNode.hasFocus && isEditing) {
        _showTypeOverlay();
      } else {
        _removeTypeOverlay();
        final val = productTypeController.text.trim().toUpperCase();
        setState(() {
          productType = val.isEmpty ? null : val;
          isProductTypeCustom = val.isNotEmpty && !types.contains(val);
        });
      }
    });
  }

  /// Loads any user-saved custom categories from the DB and appends them to
  /// [types]. Runs after the first frame so it never blocks the initial render.
  Future<void> _loadCategories() async {
    final userId = ref.read(authProvider).value?.id;
    if (userId == null) return;
    try {
      final custom = await DatabaseHelper.instance.getCategoryNames(userId);
      if (!mounted) return;
      setState(() {
        for (final name in custom) {
          if (!types.contains(name)) types.add(name);
        }
      });
    } catch (_) {
      // Non-fatal — defaults are already shown.
    }
  }

  @override
  void dispose() {
    _removeTypeOverlay();
    _typeFocusNode.dispose();
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

  // Image picker
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

  // Date picker
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
        _expiryDate = DateFormat('MM-dd-yyyy').format(picked);
        expiryController.text = _expiryDate!;
      });
    }
  }

  // Save
  Future<void> _save() async {
    if (nameController.text.trim().isEmpty) {
      _snack('Enter Product Name', isError: true);
      return;
    }
    if (qtyCtrl.text.isEmpty) {
      _snack('Enter No. of Items', isError: true);
      return;
    }
    if (originalPriceController.text.trim().isEmpty) {
      _snack('Enter Original Price', isError: true);
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

    await ref.read(inventoryProvider.notifier).updateProduct(updated);

    if (mounted) {
      _snack('Product updated successfully!');
      setState(() {
        isEditing = false;
      });
    }
  }

  // Delete product
  Future<void> _deleteProduct() async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Product?'),
        content: Text('Remove "${widget.product.name}" from inventory?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: AppTheme.textRed)),
          ),
        ],
      ),
    );

    if (confirmDelete == true && mounted) {
      await ref
          .read(inventoryProvider.notifier)
          .deleteProduct(widget.product.id!);
      if (mounted) {
        Navigator.pop(context); // Close the bottom sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product deleted successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
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

    return Column(
      children: [
        // Handle bar
        Container(
          margin: EdgeInsets.only(top: 12),
          height: 4,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(height: 8),
        // Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEditing ? 'EDIT PRODUCT' : 'PRODUCT DETAILS',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        Divider(),
        // Content
        Expanded(
          child: SingleChildScrollView(
            controller: widget.scrollController,
            // Extra bottom padding = keyboard height so focused fields are
            // always visible above the keyboard when it slides up.
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo + Name / Description
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
                                onPressed: isEditing ? _showPhotoDialog : null,
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
                                            Icons.add_photo_alternate_outlined,
                                            size: 28,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Add Photo',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16),
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
                              readOnly: !isEditing,
                              textCapitalization: TextCapitalization.characters,
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
                            SizedBox(height: 10),
                            Text('DESCRIPTION'),
                            SizedBox(height: 5),
                            TextField(
                              readOnly: !isEditing,
                              controller: descriptionController,
                              maxLines: 2,
                              decoration: InputDecoration(
                                hintText: 'Optional',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 15),

                  // Barcode
                  Text('BARCODE'),
                  SizedBox(height: 5),
                  TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],

                    controller: barcodeController,
                    readOnly: !isEditing,
                    decoration: InputDecoration(
                      hintText: 'Scan or enter barcode',
                      border: OutlineInputBorder(),
                      suffixIcon: Transform.translate(
                        offset: Offset(-6, 0),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            customBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            splashColor: AppTheme.brandBlue.withOpacity(0.2),
                            onTap: isEditing
                                ? () async {
                                    await Future.delayed(
                                      Duration(milliseconds: 150),
                                    );
                                    final scanned = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BarcodeScannerPage(),
                                      ),
                                    );
                                    if (scanned != null) {
                                      setState(
                                        () => barcodeController.text = scanned,
                                      );
                                    }
                                  }
                                : null,
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

                  // Qty + Expiry
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
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          controller: qtyCtrl,
                          readOnly: !isEditing,
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
                          readOnly: !isEditing,
                          onTap: isEditing ? _selectDate : null,
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

                  // Prices
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
                          readOnly: !isEditing,
                          decoration: InputDecoration(
                            hintText: 'P 00.0',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Flexible(
                        child: TextField(
                          readOnly: !isEditing,
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

                  // Product type — shown immediately; custom categories are
                  // appended silently once _loadCategories() finishes.
                  CompositedTransformTarget(
                    link: _layerLink,
                    child: TextField(
                      controller: productTypeController,
                      focusNode: _typeFocusNode,
                      readOnly: !isEditing,
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
                        // Rebuild the overlay so the filtered list updates.
                        _refreshOverlay();
                        final val = productTypeController.text
                            .trim()
                            .toUpperCase();
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
                            // Clear button — only visible when there's text.
                            if (productTypeController.text.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  productTypeController.clear();
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

                  SizedBox(height: 24),

                  // Edit button and Remove button
                  if (!isEditing)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => setState(() => isEditing = true),
                            icon: Icon(
                              Icons.edit_outlined,
                              color: Colors.white,
                            ),
                            label: Text('Edit Product'),
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
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _deleteProduct,
                            icon: Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                            ),
                            label: Text('Remove Product'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.textRed,
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

                  // Save button
                  if (isEditing)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // Reset to original values
                              final p = widget.product;
                              nameController.text = p.name;
                              descriptionController.text = p.description ?? '';
                              barcodeController.text = p.barcode ?? '';
                              qtyCtrl.text = '${p.quantity}';
                              originalPriceController.text =
                                  p.originalPrice?.toString() ?? '';
                              srpController.text = p.sellingPrice.toString();
                              _expiryDate = p.expiryDate;
                              expiryController.text = p.expiryDate ?? '';
                              _imagePath = p.imagePath;
                              productType = p.productType;
                              productTypeController.text = p.productType ?? '';
                              isProductTypeCustom =
                                  p.productType != null &&
                                  !types.contains(p.productType);
                              setState(() {
                                isEditing = false;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text('Cancel'),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _save,
                            icon: Icon(
                              Icons.save_outlined,
                              color: Colors.white,
                            ),
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
        ),
      ],
    );
  }
}
