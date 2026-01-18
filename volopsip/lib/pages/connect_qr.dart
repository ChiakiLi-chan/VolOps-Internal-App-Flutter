import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:volopsip/helpers/qr_connection/websocket_server.dart';
import 'package:volopsip/helpers/qr_connection/persistent_ws_server.dart';
import 'package:volopsip/helpers/listeners/message_handler.dart';
import 'package:volopsip/modal/profile_modal.dart'; 

class ConnectQrWs extends StatefulWidget {
  final void Function(String ip)? onPhoneConnected;
  final VoidCallback? onPhoneDisconnected;

  const ConnectQrWs({
    Key? key,
    this.onPhoneConnected,
    this.onPhoneDisconnected,
  }) : super(key: key);

  @override
  State<ConnectQrWs> createState() => _ConnectQrWsState();
}

class _ConnectQrWsState extends State<ConnectQrWs> {
  final serverSingleton = PersistentWebSocketServer();

  late final PhoneMessageHandler messageHandler;

  String lastMessage = 'Waiting for phone...';
  String? localIp;
  bool phoneConnected = false;
  bool started = false;

  @override
  void initState() {
    super.initState();

    // Message handler
    messageHandler = PhoneMessageHandler(
      onMessage: (msg) {
        if (!mounted) return;

        // Update the label
        setState(() => lastMessage = msg);

        // Show dialog for all non-ping messages
        if (msg.toLowerCase() != 'ping') {
          _showMessageDialog(msg);
          showVolunteerPopup(context, msg); 
        }
      },
      onPing: _showPingDialog,
    );

    _initServer();
  }

  Future<void> _showMessageDialog(String message) async {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Message from Phone'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  

  Future<void> _initServer() async {
    localIp = await LocalWebSocketServer.getLocalIp();

    // Client connected callback
    serverSingleton.server.onClientConnected ??= () {
      if (!mounted) return;
      setState(() {
        phoneConnected = true;
        lastMessage = 'Phone connected!';
      });
      if (widget.onPhoneConnected != null && localIp != null) {
        widget.onPhoneConnected!(localIp!);
      }
    };

    // Client disconnected callback
    serverSingleton.server.onClientDisconnected ??= () {
      if (!mounted) return;
      setState(() {
        phoneConnected = false;
        lastMessage = 'Phone disconnected';
      });
      widget.onPhoneDisconnected?.call();
    };

    // Start server
    await serverSingleton.server.start((msg) {
      if (!mounted) return;
      messageHandler.handle(msg);
    });

    if (!mounted) return;
    setState(() {
      started = true;
    });
  }

  Future<void> _showPingDialog() async {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ping received'),
        content: const Text('Phone pinged you.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Keep the server persistent
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wsUrl = (localIp != null && started) ? 'ws://$localIp:5050' : '';

    return Scaffold(
      appBar: AppBar(title: const Text('Desktop WebSocket Receiver')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              lastMessage,
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 20),
            if (wsUrl.isNotEmpty) ...[
              QrImageView(
                data: wsUrl,
                size: 220,
              ),
              const SizedBox(height: 10),
              Text(
                wsUrl,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Scan with phone to connect',
                style: TextStyle(fontSize: 14),
              ),
            ] else
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
