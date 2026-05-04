import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../designs/drawer.dart';
import '../../designs/themes.dart';
import '../../designs/appbar.dart';
import 'package:image_picker/image_picker.dart'; // Add new logic function

class AddingSectionPage extends ConsumerStatefulWidget {
  const AddingSectionPage({super.key});

  @override
  ConsumerState<AddingSectionPage> createState() => _AddingSectionPageState();
}

class _AddingSectionPageState extends ConsumerState<AddingSectionPage> {
  @override
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
                                // TODO: add upload action
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
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
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              labelText: 'Enter product name',
                            ),
                          ),

                          SizedBox(height: 15),

                          Text('DESCRIPTION'),
                          SizedBox(height: 5),
                          TextField(
                            minLines: 1,
                            maxLines: null, // makes description taller
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
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
                SizedBox(height: 5.0),
                TextField(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    labelText: 'Barcode number...',
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
                          filled: true,
                          fillColor: Colors.transparent,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                        readOnly: true,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                SizedBox(height: 20.0, child: Text('TYPE OF PRODUCT')),
                DropdownMenu<String>(
                  width: double.infinity,
                  initialSelection: 'Canned Goods',
                  onSelected: (String? newValue) {
                    print('Selected: $newValue');
                  },
                  dropdownMenuEntries: <DropdownMenuEntry<String>>[
                    DropdownMenuEntry(
                      value: 'Canned Goods',
                      label: 'Canned Goods',
                    ),
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
                ),
              ],
            ),
          ),
        ),
      ), // left, top, right, bottom,),
    );
  }
}
