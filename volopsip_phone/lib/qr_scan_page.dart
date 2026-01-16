import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  bool scanned = false;

  void onDetect(BarcodeCapture capture) {
    if (scanned) return;

    final barcode = capture.barcodes.first;
    final value = barcode.rawValue;

    if (value == null) return;

    if (value.startsWith('ws://')) {
      scanned = true;

      // Go back to landing page and return the WS URL
      Navigator.pop(context, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Desktop QR')),
      body: MobileScanner(
        onDetect: onDetect,
      ),
    );
  }
}
