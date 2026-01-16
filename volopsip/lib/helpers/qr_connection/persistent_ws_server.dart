import 'websocket_server.dart';

class PersistentWebSocketServer {
  static final PersistentWebSocketServer _instance =
      PersistentWebSocketServer._internal();

  factory PersistentWebSocketServer() => _instance;

  final LocalWebSocketServer server = LocalWebSocketServer();

  PersistentWebSocketServer._internal();
}
