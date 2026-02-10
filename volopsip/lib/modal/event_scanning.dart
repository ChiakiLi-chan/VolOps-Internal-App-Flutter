import 'package:flutter/material.dart';
import 'package:volopsip/helpers/events_page/log_manager.dart';
import 'dart:async';
import 'package:volopsip/helpers/qr_connection/persistent_ws_server.dart';  

Future<void> eventScanning({
  required BuildContext context,
  required String attribute,
  required String eventName,
}) {
  final List<String> logs = [];
  StreamSubscription? subscription;

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          // ✅ Create listener ONCE
          subscription ??= LogManager().logStream.listen((log) {
            if (!dialogContext.mounted) return;
            setState(() {
              logs.add('• $log');
            });
          });

          return AlertDialog(
            title: const Text('Scanning Mode'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        const TextSpan(
                          text:
                              'You are currently scanning volunteers to mark as ',
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
                  const Text(
                    'Log',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: logs.isEmpty
                            ? [const Text('• Waiting for scans...')]
                            : logs.map((log) => Text(log)).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 12, color: Colors.redAccent),
                      children: [
                        TextSpan(text: 'Exiting this will end scanning.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () {
                      subscription?.cancel(); // ✅ cancel exactly one listener
                      PersistentWebSocketServer().sendToPhone(
                            'STOPES',
                      );
                      Navigator.of(context).pop(true);
                    },
                    child: const Text(
                      'Exit',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  ).whenComplete(() {
    subscription?.cancel(); // ✅ safety cleanup
  });
}
