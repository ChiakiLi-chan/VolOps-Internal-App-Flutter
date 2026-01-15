import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: QRScannerPage(),
    );
  }
}

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String lastStatus = 'Scan a QR code to send message';
  bool hasScanned = false;

  @override
  void reassemble() {
    super.reassemble();
    // Recommended by package for hot reload
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> sendMessage(String url) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': 'Hello from phone!'}),
      );

      if (response.statusCode == 200) {
        setState(() {
          lastStatus = 'Message sent successfully!';
        });
      } else {
        setState(() {
          lastStatus = 'Failed to send message: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        lastStatus = 'Error sending message: $e';
      });
    }
  }

  void _onQRViewCreated(QRViewController ctrl) {
  controller = ctrl;

  controller!.scannedDataStream.listen((scanData) {
      if (hasScanned) return; // 🚫 stop here

      final url = scanData.code;
      if (url == null) return;

      hasScanned = true; // 🔒 lock
      controller!.pauseCamera(); // ⏸ stop camera

      debugPrint('QR FOUND: $url');

      sendMessage(url);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phone QR Sender')),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                lastStatus,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
