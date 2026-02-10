import 'websocket_server.dart';
import 'package:flutter/foundation.dart';

class PersistentWebSocketServer {
  static final PersistentWebSocketServer _instance =
      PersistentWebSocketServer._internal();

  factory PersistentWebSocketServer() => _instance;

  PersistentWebSocketServer._internal();

  final LocalWebSocketServer server = LocalWebSocketServer();

  void sendToPhone(String message) {
    server.send(message);
    debugPrint('Sent to phone: $message');
  }
}
