import 'package:flutter/material.dart';
import 'package:volopsip/helpers/qr_connection/persistent_ws_server.dart';
Future<void> eventScanning({
  required BuildContext context,
  required String attribute,
  required String eventName,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text('Scanning Mode'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Main message ===
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    const TextSpan(
                      text: 'You are currently scanning volunteers to mark as ',
                    ),
                    TextSpan(
                      text: attribute,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const TextSpan(text: ' in '),
                    TextSpan(
                      text: eventName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // === Log header ===
              const Text(
                'Log',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // === Scrollable log area ===
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const SingleChildScrollView(
                  padding: EdgeInsets.all(8),
                  child: Text('• Waiting for scans...'),
                ),
              ),

              const SizedBox(height: 12),

              // === Warning + Exit on same line ===
              Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.redAccent,
                  ),
                  children: [
                    const TextSpan(text: 'Exiting this will end scanning for '),
                    TextSpan(
                      text: attribute, // <-- event attribute
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () {
                  // Send message to phone
                  PersistentWebSocketServer().sendToPhone('STOPES');

                  // Close dialog or page
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Exit',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),

            ],
          ),
        ),
      );
    },
  );
}
