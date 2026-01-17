import 'package:volopsip/pages/connect_qr.dart';
import 'package:flutter/foundation.dart';


typedef PhoneMessageCallback = void Function(String message);

class PhoneMessageHandler {
  final PhoneMessageCallback onMessage;
  final VoidCallback? onPing;

  PhoneMessageHandler({
    required this.onMessage,
    this.onPing,
  });

  void handle(String msg) {
    onMessage(msg);

    switch (msg.toLowerCase()) {
      case 'ping':
        onPing?.call();
        break;

      // future messages
      // case 'sync':
      // case 'disconnect':
    }
  }
}
