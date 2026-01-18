import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path; // rename to avoid clash
import 'package:provider/provider.dart';

// Desktop SQLite
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

//Helpers
import 'package:volopsip/helpers/volunteer_page/vol_provider.dart';

// Your pages
import 'package:volopsip/pages/connect_qr.dart';
import '../pages/volunteer_page.dart';
import 'package:volopsip/pages/events_page.dart';
import 'package:volopsip/pages/lookupUUID_test.dart';

Future<void> resetDatabase() async {
  final databasesPath = await databaseFactory.getDatabasesPath();
  final dbPath = path.join(databasesPath, 'volopsip.db');

  if (await File(dbPath).exists()) {
    await File(dbPath).delete();
    print('Deleted old database at $dbPath');
  }

  databaseFactory = databaseFactoryFfi;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  //await resetDatabase();

  runApp(
    MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => VolunteerProvider()),
        ],
        child: const MyApp(),
      ),
    );
  }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0; // track current page index
  bool phoneConnected = false; // track phone connection
  String connectedIp = '';

  // Pages
  final List<Widget> pages = [
    const Center(child: Text('Welcome', style: TextStyle(fontSize: 24))),
    const VolunteerPage(),
    const EventsPage(),
    const VolunteerLookupPage(),
    const ConnectQrWs(), // QR/WebSocket page
  ];

  void setPage(int index) {
    setState(() {
      selectedIndex = index;
    });
    Navigator.pop(context); // close drawer
  }

  void updateConnection(bool connected, [String ip = '']) {
    setState(() {
      phoneConnected = connected;
      connectedIp = ip;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedIndex == 0
              ? 'Home'
              : selectedIndex == 1
                  ? 'Volunteer List'
                  : selectedIndex == 2
                      ? 'Events'
                        :selectedIndex == 3
                            ? 'UUID Test'
                        : 'Connect',
        ),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                selected: selectedIndex == 0,
                onTap: () => setPage(0),
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Volunteer List'),
                selected: selectedIndex == 1,
                onTap: () => setPage(1),
              ),
              ListTile(
                leading: const Icon(Icons.assignment),
                title: const Text('Events'),
                selected: selectedIndex == 2,
                onTap: () => setPage(2),
              ),
              ListTile(
                leading: const Icon(Icons.assignment),
                title: const Text('UUID Test'),
                selected: selectedIndex == 3,
                onTap: () => setPage(3),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: InkWell(
                  onTap: () => setPage(4),
                  borderRadius: BorderRadius.circular(30), // makes it oval
                  child: Container(
                    decoration: BoxDecoration(
                      color: phoneConnected ? Colors.green : Colors.blue,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                    child: Row(
                      children: [
                        const Icon(Icons.qr_code, color: Colors.white),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            phoneConnected
                                ? 'Phone Connected — $connectedIp'
                                : 'Connect to Phone',
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: pages.map((page) {
          // If ConnectQrWs, pass a callback to update connection status
          if (page is ConnectQrWs) {
            return ConnectQrWs(
              onPhoneConnected: (ip) => updateConnection(true, ip),
              onPhoneDisconnected: () => updateConnection(false),
            );
          }
          return page;
        }).toList(),
      ),
    );
  }
}
