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

  String? lastEventAttr;
  String? lastEventId;
  String? lastEventName;

  final ValueNotifier<bool> eventScanningNotifier = ValueNotifier(false);

  bool isEventScanning = false; 

  @override
  void initState() {
    super.initState();
    _handler = PhoneConnectionHandler(
      onMessage: (msg) {
        debugPrint('Message from PC: $msg');

        if (msg.startsWith('ES-')) {
          // Remove "ES-"
          final payload = msg.substring(3);
          final parts = payload.split('-');

          if (parts.length < 3) return;

          final eventId = parts[0];
          final eventAttr = parts[1];
          final eventName = parts.sublist(2).join('-');

          setState(() {
            isEventScanning = true;
            lastEventId = eventId;
            lastEventAttr = eventAttr;
            lastEventName = eventName;
          });

          eventScanningNotifier.value = true;
          // Show start scanning popup
          _showScanningPopup(eventAttr, eventName);

        } 
        else if (msg == 'STOPES') {
          
          final eventAttr = lastEventAttr ?? 'Unknown';
          final eventName = lastEventName ?? 'Unknown';

          setState(() {
            isEventScanning = false;
            lastEventId = null;
            lastEventAttr = null;
            lastEventName = null;
          });
          eventScanningNotifier.value = false;
          // Show stop scanning popup
          _showStopScanningPopup(eventAttr, eventName);
        }
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

  void _showStopScanningPopup(String eventAttr, String eventName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Scanning Stopped'),
        content: Text(
          'Stopping scan for $eventAttr for $eventName',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }


  void _showScanningPopup(String eventAttr, String eventName) {
    showDialog(
      context: context,
      barrierDismissible: false, // user must acknowledge
      builder: (context) => AlertDialog(
        title: const Text('Scanning Started'),
        content: Text(
          'Currently scanning $eventAttr for $eventName',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
        MaterialPageRoute(
          builder: (_) => ScanVolunteerQR(
            eventScanningNotifier: eventScanningNotifier, 
          ),
        ),
      );

    if (qrData == null) return;

    String dataToSend = qrData;

    if (isEventScanning) {
      // Add prefix when scanning is active
      // Using the last received eventAttr and eventId
      dataToSend = 'ESADD-$lastEventAttr-$lastEventId-$qrData';
    }

    _volunteerQrScanned(dataToSend);
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
