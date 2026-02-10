import 'package:flutter/material.dart';
import 'package:volopsip/helpers/events_page/log_manager.dart';
Future<void> eventScanning({
  required BuildContext context,
  required String attribute,
  required String eventName,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      List<String> logs = [];

      return StatefulBuilder(
        builder: (context, setState) {
          // Listen to logs
          final subscription = LogManager().logStream.listen((log) {
            // Only update if still mounted
            if (context.mounted) {
              setState(() {
                logs.add('• $log');
              });
            }
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
                            text: 'You are currently scanning volunteers to mark as '),
                        TextSpan(
                          text: attribute,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                        const TextSpan(text: ' in '),
                        TextSpan(
                          text: eventName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.green),
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
                    text: TextSpan(
                      style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                      children: [
                        const TextSpan(text: 'Exiting this will end scanning for '),
                        TextSpan(
                            text: attribute,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () {
                      subscription.cancel(); // cancel the log listener
                      Navigator.of(context).pop(true); // return a value to parent
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
  );
}
