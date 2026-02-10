import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanVolunteerQR extends StatefulWidget {
  final ValueNotifier<bool> eventScanningNotifier;

  const ScanVolunteerQR({super.key, required this.eventScanningNotifier});

  @override
  State<ScanVolunteerQR> createState() => _ScanVolunteerQRState();
}

class _ScanVolunteerQRState extends State<ScanVolunteerQR> {
  bool isEventScanning = false;
  bool scanningPaused = false; // pause scanning while dialog is open

  static const qrPrefix = 'VQROF2026-';

  @override
  void initState() {
    super.initState();
    // Initialize the scanning state
    isEventScanning = widget.eventScanningNotifier.value;

    // Listen for changes from ScanLandingPage
    widget.eventScanningNotifier.addListener(_onEventScanningChanged);
  }

  void _onEventScanningChanged() {
    setState(() {
      isEventScanning = widget.eventScanningNotifier.value;
    });
  }

  @override
  void dispose() {
    widget.eventScanningNotifier.removeListener(_onEventScanningChanged);
    super.dispose();
  }


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
    // Always return the showDialog, just change the content depending on isEventScanning
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // force user to press OK
      builder: (context) => AlertDialog(
        title: Text(isEventScanning ? 'Volunteer Scanned' : 'QR Scanned'),
        content: Text(
          isEventScanning
              ? 'Volunteer QR scanned successfully!'
              : "Volunteer QR Scanned. Press OK to show profile.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, code), // always returns code
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
