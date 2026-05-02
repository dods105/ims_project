import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../designs/drawer.dart';
import '../../designs/themes.dart';
import '../../designs/appbar.dart';
import 'package:image_picker/image_picker.dart'; // Add new logic function
import 'dart:io';
import 'barcode_scanner_page.dart';


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

  Widget build(BuildContext context) {
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
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Enter product name',
            ),
          ),

          const SizedBox(height: 15),

          const Text('DESCRIPTION'),
          const SizedBox(height: 5),
          TextField(
            minLines: 1,
            maxLines: null,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Tap to add description',
            ),
          ),
        ],
      ),
    ),
  ],
),

  SizedBox(height: 20),

Text('BARCODE NUMBER'),

SizedBox(height: 10),

Stack(
  clipBehavior: Clip.none,
  children: [
    TextField(
      controller: barcodeController,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelText: 'Barcode number...',
      ),
    ),

    Positioned(
      right: 12,
      top: 8,
      child: Material(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),),
        color: Colors.white,
        child: InkWell(
          onTap: () async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const BarcodeScannerPage(),
    ),
  );

  if (result != null) {
    setState(() {
       barcodeController.text = result;// assign to your text field controller or variable
      print("Scanned: $result");
    });
  }
},
          customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),),
          child: Padding(
            padding: EdgeInsets.all(6),
            child: Icon(
              Icons.qr_code_scanner,
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
                Row(
                  children: [
                    // First TextField
                    Flexible(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: '00:00',
                          enabledBorder: OutlineInputBorder(
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
                          labelText: 'Select Date',
                          filled: true,
                          fillColor: Colors.transparent,
                          prefixIcon: Icon(Icons.calendar_today),
                          enabledBorder: OutlineInputBorder(
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
                        decoration: InputDecoration(
                          labelText: 'P 00.0',
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.0), // Second TextField
                    Flexible(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'P 00.0',
                          fillColor: Colors.transparent,
                          enabledBorder: OutlineInputBorder(
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
        onPressed: () {},
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
  super.dispose();
  }
}
