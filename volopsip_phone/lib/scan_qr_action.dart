import 'package:flutter/material.dart';

class ScanQrActionPage extends StatelessWidget {
  final bool isConnected;
  final VoidCallback? onScan; // ✅ callback to trigger scanning

  const ScanQrActionPage({super.key, required this.isConnected, this.onScan});

  void _showMessage(BuildContext context) {
    if (isConnected) {
      // Trigger actual QR scan
      onScan?.call(); // ✅ call the passed function
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('QR Scan'),
          content: const Text('Please connect to Desktop App before using.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.qr_code_scanner),
      label: const Text('Scan QR Code'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(250, 50),
      ),
      onPressed: () => _showMessage(context),
    );
  }
}
