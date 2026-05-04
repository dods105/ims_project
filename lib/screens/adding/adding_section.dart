import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/products/products.dart';
import 'package:flutter_application_1/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../designs/drawer.dart';
import '../../designs/appbar.dart';
import 'package:image_picker/image_picker.dart'; // Add new logic function
import 'dart:io';
import 'barcode_scanner_page.dart';
import 'package:flutter/services.dart';


class AddingSectionPage extends ConsumerStatefulWidget {
  const AddingSectionPage({super.key});

  @override
  ConsumerState<AddingSectionPage> createState() => _AddingSectionPageState();
}

class _AddingSectionPageState extends ConsumerState<AddingSectionPage> {

final ImagePicker _picker = ImagePicker();
File? _selectedImage;

final TextEditingController barcodeController = TextEditingController();

final TextEditingController _dateContoller = TextEditingController();

final TextEditingController nameController = TextEditingController();

final TextEditingController descriptionController = TextEditingController();

final TextEditingController numberofitemsController = TextEditingController();

final TextEditingController originalprice = TextEditingController();

final TextEditingController srpController = TextEditingController();

Future<void> _pickImage(ImageSource source) async {
  // Use ImageSource.gallery or ImageSource.camera
  final XFile? pickedFile = await _picker.pickImage(
    source: source,
    maxWidth: 1800, // Optional: limit size
    imageQuality: 80, // Optional: compress image
  );

  if (pickedFile != null) {
    setState(() {
      _selectedImage = File(pickedFile.path);
    });
  }
}  

void _removePhoto() {
  setState(() {
    _selectedImage = null;
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
              contentPadding: EdgeInsets.only(left: -8),
              title: Text('Camera'),
              onTap: () {
                Navigator.pop(context); _pickImage(ImageSource.camera);
                // TODO: camera action
              },
            ),
            ListTile(
              leading: Icon(Icons.photo),
                 contentPadding: EdgeInsets.only(left: -8),
              title: Text('Gallery'),
              onTap: () {
                Navigator.pop(context); _pickImage(ImageSource.gallery);
                // TODO: gallery action
              },
            ),
             ListTile(
              leading: Icon(Icons.delete),
                 contentPadding: EdgeInsets.only(left: -8),
              title: Text('Remove Photo'),
              onTap: () {
                Navigator.pop(context); _removePhoto();
                // TODO: gallery action
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _selectDate() async{
  DateTime? _picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000), 
    lastDate: DateTime(2100)
    );
    if (_picked != null){
      setState(() {
      _dateContoller.text = _picked.toString().split(" ")[0];
      });
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
  }
  if (numberofitemsController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Enter No. of Items"),
        backgroundColor: Colors.red,
        duration: Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
      ),
    );
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

 /* final product = Product(
    userId: userId, 
    name: nameController.text.trim(),
    quantity: numberofitemsController.textint.(parse),
    sellingPrice:
    )*/
}

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
    // LEFT SIDE
    Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 25),

          GestureDetector(
            onTap: _showActionDialog,
            child: Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromARGB(255, 38, 15, 144),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.hardEdge,

              child: _selectedImage != null
                  ? Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 28,
                            color: Color.fromARGB(255, 38, 15, 144),
                          ),
                          SizedBox(height: 5),
                          Text("Photo"),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    ),

    const SizedBox(width: 15),

    // RIGHT SIDE
    Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PRODUCT NAME'),
          const SizedBox(height: 5),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter product name',
            ),
          ),

          const SizedBox(height: 15),

          const Text('DESCRIPTION'),
          const SizedBox(height: 5),
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

Text('BARCODE NUMBER'),

SizedBox(height: 5),

Stack(
  clipBehavior: Clip.none,
  children: [
    TextField(
      controller: barcodeController,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Barcode number...',
      ),
    ),

    Positioned(
  right: 8,
  top: 6,
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () async {
        await Future.delayed(const Duration(milliseconds: 300));
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BarcodeScannerPage(),
          ),
        );

        if (result != null) {
          setState(() {
            barcodeController.text = result;
            print("Scanned: $result");
          });
        }
      },
      borderRadius: BorderRadius.circular(8),
      splashColor: Colors.blue.withOpacity(0.2),
      highlightColor: Colors.blue.withOpacity(0.1),

      child: const Padding(
        padding: EdgeInsets.all(6),
        child: Icon(
          Icons.qr_code_scanner,
          size: 30,
          color: Colors.black,
        ),
      ),
    ),
  ),
),
  ],
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
                        controller: numberofitemsController,
                        decoration: InputDecoration(
                          hintText: '00:00',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.0), // Second TextField
                    Flexible(
                      child: TextField(
                        controller: _dateContoller,
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

                    SizedBox(
                      width: screenWidth / 2 - 50,
                      child: Text('SRP'),
                    ),
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
                  ]
                ),
                SizedBox(height: 15),
                SizedBox(
                  height: 20.0,
                  child:Text('TYPE OF PRODUCT'),
                  ),
                DropdownMenu<String>(
  width: double.infinity,
   enableFilter: true, // allows typing/searching
  requestFocusOnTap: true,
  initialSelection: 'Canned Goods',
  onSelected: (String? newValue) {
    print('Selected: $newValue');
  },
  dropdownMenuEntries: <DropdownMenuEntry<String>>[
    DropdownMenuEntry(value: 'Canned Goods', label: 'Canned Goods'),
    DropdownMenuEntry(value: 'Buiscuits', label: 'Buiscuits'),
  ],
),
SizedBox(height: 20),

Row(
  children: [
    Expanded(
      child: ElevatedButton.icon(
        onPressed: () {
          savedproduct(userId);//print(_selectedImage);
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
)
              ],
            ),
          ),
        ),
      ), // left, top, right, bottom,),
    );
  }
  @override
void dispose() {
  barcodeController.dispose();
  _dateContoller.dispose();
  nameController.dispose();
  descriptionController.dispose();
  numberofitemsController.dispose();
  originalprice.dispose();
  srpController.dispose();
  super.dispose();
  }
}
