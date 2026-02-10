// file: helpers/esadd_helper.dart
import 'package:flutter/material.dart';

class ESAdding {
  /// Display an alert dialog showing the ESADD message data
  static void showEsAddDialog(
      BuildContext context, String eventAttr, String eventId, String qrData) {
    showDialog(
      context: context,
      barrierDismissible: false, // force user to press OK
      builder: (context) => AlertDialog(
        title: const Text('ESADD Message Received'),
        content: Text(
          'Event Attribute: $eventAttr\n'
          'Event ID: $eventId\n'
          'QR Data: $qrData',
          style: const TextStyle(fontSize: 16),
        ),
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
