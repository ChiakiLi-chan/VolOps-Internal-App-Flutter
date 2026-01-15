import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;

class LocalServer {
  HttpServer? _server;

  /// Start the local server on port 5050
  Future<void> start(void Function(String) onMessage) async {
    final router = shelf_router.Router();

    router.post('/message', (Request request) async {
      final body = await request.readAsString();
      try {
        final data = jsonDecode(body);
        onMessage(data['text'] ?? '');
      } catch (e) {
        onMessage('Received invalid data');
      }
      return Response.ok('OK');
    });

    _server = await io.serve(
      router,
      InternetAddress.anyIPv4, // allow devices on same Wi-Fi
      5050,
    );

    print('Server running on port 5050');
  }

  /// Stop the server
  Future<void> stop() async {
    await _server?.close();
  }

  /// Get the local Wi-Fi IP
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

    // fallback: any IPv4 non-loopback
    for (final iface in interfaces) {
      for (final addr in iface.addresses) {
        if (!addr.isLoopback) return addr.address;
      }
    }

    return '127.0.0.1';
  }
}
