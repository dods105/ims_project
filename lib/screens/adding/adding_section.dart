import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../designs/drawer.dart';
import '../../designs/themes.dart';

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
      appBar: AppBar(title: Text('ADD PRODUCTS', style: AppTheme.displayLarge)),
      endDrawer: const AppDrawer(page: '/adding'),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(15.5, 20.0, 30.0, 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Horizontal center
              children: [
                Text('PRODUCT NAME'),
                SizedBox(height: 5.0),
                TextField(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    labelText: 'Enter product name',
                  ),
                ),
                SizedBox(height: 15.0),
                Text('DESCRIPTION'),
                SizedBox(height: 5.0),
                TextField(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    labelText: 'Tap to add description',
                  ),
                ),
                SizedBox(height: 20.0),
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
                      child: Text('EXPIRATION DATE'),
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
                      child: Text('EXPIRATION DATE'),
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
                  ]
                )
              ],
            ),
          ),
        ),
      ), // left, top, right, bottom,),
    );
  }
}
