import 'package:flutter/foundation.dart';

typedef PhoneMessageCallback = void Function(String message);

class PhoneMessageHandler {
  final PhoneMessageCallback onMessage; // called for any message
  final VoidCallback? onPing;           // called only for "ping"

  PhoneMessageHandler({
    required this.onMessage,
    this.onPing,
  });

  void handle(String msg) {
    // If message is ping, call onPing
    if (msg.toLowerCase() == 'ping') {
      onPing?.call();
    } else {
      // Otherwise call onMessage
      onMessage(msg);
    }
  }
}
