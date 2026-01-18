import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanVolunteerQR extends StatefulWidget {
  const ScanVolunteerQR({Key? key}) : super(key: key);

  @override
  State<ScanVolunteerQR> createState() => _ScanVolunteerQRState();
}

class _ScanVolunteerQRState extends State<ScanVolunteerQR> {
  bool scanningPaused = false; // pause scanning while dialog is open

  static const qrPrefix = 'VQROF2026-';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Volunteer QR')),
      body: MobileScanner(
        onDetect: (capture) async {
          if (scanningPaused) return; // stop scanning if a QR is being processed

          final barcode = capture.barcodes.first;
          final String? code = barcode.rawValue;
          if (code == null) return;

          if (!code.startsWith(qrPrefix)) {
            // Invalid QR code
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid QR code')),
            );
            return;
          }

          scanningPaused = true; // pause scanner while dialog is open

          // Show dialog and wait until user closes it
          final scannedCode = await _showResultDialog(code);

          // Return scanned code to previous page
          if (scannedCode != null && context.mounted) {
            Navigator.pop(context, scannedCode);
          }

          scanningPaused = false; // resume scanning
        },
      ),
    );
  }

  /// Show a dialog with scanned QR code
  Future<String?> _showResultDialog(String code) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // force user to press OK
      builder: (context) => AlertDialog(
        title: const Text('QR Scanned'),
        //content: Text(code),
        content: Text("Volunteer QR Scanned. Press OK to show profile."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, code), // returns QR code
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
