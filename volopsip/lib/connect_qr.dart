import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'local_server.dart';

class ConnectQr extends StatefulWidget {
  const ConnectQr({super.key});

  @override
  State<ConnectQr> createState() => _ConnectQrState();
}

class _ConnectQrState extends State<ConnectQr> {
  final server = LocalServer();

  String lastMessage = 'Waiting for phone...';
  String? localIp;
  bool isServerStarted = false;

  @override
  void initState() {
    super.initState();
    setupServer();
  }

  Future<void> setupServer() async {
    localIp = await LocalServer.getLocalIp();

    await server.start((msg) {
      setState(() {
        lastMessage = msg;
      });
    });

    setState(() {
      isServerStarted = true;
    });
  }

  @override
  void dispose() {
    server.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final qrData =
        (localIp != null && isServerStarted)
            ? 'http://$localIp:5050/message'
            : '';

    return Scaffold(
      appBar: AppBar(title: const Text('Desktop Receiver')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              lastMessage,
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 20),
            if (qrData.isNotEmpty)
              QrImageView(
                data: qrData,
                size: 200,
                errorCorrectionLevel: QrErrorCorrectLevel.L,
              )
            else
              const CircularProgressIndicator(),
            const SizedBox(height: 10),
            Text(
              qrData.isNotEmpty
                  ? 'Scan this QR with your phone'
                  : 'Starting server...',
            ),
          ],
        ),
      ),
    );
  }
}
