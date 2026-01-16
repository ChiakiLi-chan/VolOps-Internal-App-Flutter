import 'dart:io';

typedef MessageCallback = void Function(String message);
typedef ClientConnectedCallback = void Function();

class LocalWebSocketServer {
  HttpServer? _server;
  WebSocket? _client;

  ClientConnectedCallback? onClientConnected;
  ClientConnectedCallback? onClientDisconnected;

  /// Start the server if not already started
  Future<void> start(MessageCallback onMessage) async {
    if (_server != null) return; // already running

    _server = await HttpServer.bind(
      InternetAddress.anyIPv4,
      5050,
    );

    _server!.listen((HttpRequest request) async {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        final socket = await WebSocketTransformer.upgrade(request);
        _client = socket;

        // Notify client connected
        if (onClientConnected != null) onClientConnected!();

        socket.listen(
          (data) {
            onMessage(data.toString());
          },
          onDone: () {
            _client = null;
            if (onClientDisconnected != null) onClientDisconnected!();
          },
          onError: (_) {
            _client = null;
            if (onClientDisconnected != null) onClientDisconnected!();
          },
        );
      } else {
        request.response
          ..statusCode = HttpStatus.forbidden
          ..close();
      }
    });
  }

  void send(String message) => _client?.add(message);

  Future<void> stop() async {
    await _client?.close();
    await _server?.close();
    _client = null;
    _server = null;
  }

  /// Get local IPv4 address
  static Future<String> getLocalIp() async {
    final interfaces = await NetworkInterface.list(
      includeLoopback: false,
      type: InternetAddressType.IPv4,
    );

    final preferredNames = ['wi-fi', 'wlan', 'ethernet'];

    for (final name in preferredNames) {
      for (final iface in interfaces) {
        if (iface.name.toLowerCase().contains(name)) {
          for (final addr in iface.addresses) {
            if (!addr.isLoopback) return addr.address;
          }
        }
      }
    }

    // fallback
    for (final iface in interfaces) {
      for (final addr in iface.addresses) {
        if (!addr.isLoopback) return addr.address;
      }
    }

    return '127.0.0.1';
  }
}
