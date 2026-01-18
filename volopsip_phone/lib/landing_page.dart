import 'package:flutter/material.dart';
import 'qr_scan_page.dart';
import 'phone_connect_page.dart'; 
import 'package:volopsip_phone/qr_scan_page_connected.dart';
import 'scan_qr_action.dart'; 

class ScanLandingPage extends StatefulWidget {
  const ScanLandingPage({super.key});

  @override
  State<ScanLandingPage> createState() => _ScanLandingPageState();
}

class _ScanLandingPageState extends State<ScanLandingPage> {
  String? connectedIp; // null = disconnected
  late PhoneConnectionHandler _handler;

  @override
  void initState() {
    super.initState();
    _handler = PhoneConnectionHandler(
      onMessage: (msg) {
        // Optional: handle messages from PC
      },
      onStatusChange: (status) {
        setState(() {}); // refresh UI when connection status changes
      },
      onDisconnected: () {
        setState(() {
          connectedIp = null; // auto-update if phone disconnects
        });
      },
    );
  }

  void _connectToLaptop() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScanPage()),
    );

    if (result != null && result.startsWith('ws://')) {
      final ip = result.replaceAll('ws://', '').split(':').first;
      setState(() {
        connectedIp = ip;
      });

      // Connect to PC
      _handler.connect(result);
    }
  }

  void _disconnect() {
    _handler.dispose();
    setState(() {
      connectedIp = null;
    });
  }

  void _pingPc() {
    _handler.send('ping'); // send message to PC
  }

  void _volunteerQrScanned(String qrData) {
    _handler.send(qrData);
  }

  @override
  void dispose() {
    _handler.dispose();
    super.dispose();
  }

  Future<void> _scanVolunteerQr() async {
    final qrData = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => ScanVolunteerQR()),
    );

    if (qrData == null) return;

    _volunteerQrScanned(qrData);
  }


  @override
  Widget build(BuildContext context) {
    final isConnected = connectedIp != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Phone Connection')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Connect / Disconnect Button
            ElevatedButton.icon(
              onPressed: isConnected ? _disconnect : _connectToLaptop,
              icon: const Icon(Icons.desktop_windows, color: Colors.white),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(250, 70),
                backgroundColor: isConnected ? Colors.green : Colors.blue,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(), // makes it oval
              ),
              label: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isConnected
                        ? 'Connected — $connectedIp'
                        : 'Connect to Laptop',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  if (isConnected)
                    const Text(
                      'Tap to disconnect',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(179, 252, 19, 19),
                      ),
                    ),
                ],
              ),
            ),

            // Ping PC button
            if (isConnected) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.notifications, color: Colors.white),
                label: const Text('Ping PC'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(250, 50),
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                ),
                onPressed: _pingPc,
              ),
            ],

            const SizedBox(height: 20),

            // Scan QR Code button
            ScanQrActionPage(
              isConnected: isConnected,
              onScan: _scanVolunteerQr,
            ),
          ],
        ),
      ),
    );
  }
}
