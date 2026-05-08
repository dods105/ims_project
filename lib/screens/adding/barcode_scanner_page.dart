import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  bool _isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Barcode")),
      body: MobileScanner(
        onDetect: (capture) {
          if (_isScanned) return;

          final barcodes = capture.barcodes;
          if (barcodes.isEmpty) return;

          final value = barcodes.first.rawValue;

          if (value != null) {
            _isScanned = true;

            Future.delayed(const Duration(milliseconds: 200), () {
              Navigator.pop(context, value);
            });
          }
        },
      ),
    );
  }
}
