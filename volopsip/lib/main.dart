import 'package:flutter/material.dart';
import 'package:path/path.dart';

// Desktop SQLite
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Your pages
import 'package:volopsip/connect_qr.dart';
import '../pages/volunteer_page.dart';
import 'package:volopsip/pages/events_page.dart';
import 'dart:io';

//* Optional: Reset database on each app start for testing purposes
Future<void> resetDatabase() async {
  // Get the path used by sqflite_common_ffi
  final databasesPath = await databaseFactory.getDatabasesPath();
  final dbPath = join(databasesPath, 'volopsip.db');

  if (await File(dbPath).exists()) {
    await File(dbPath).delete();
    print('Deleted old database at $dbPath');
  }

  // Optional: clear FFI cache
  databaseFactory = databaseFactoryFfi;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  sqfliteFfiInit();                   
  databaseFactory = databaseFactoryFfi; 

  await resetDatabase();
 // Comment: Remove comments from line above to restart  database on each app launch for testing

  runApp(const MyApp());
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
  // Track the currently selected page
  String activePage = 'home';

  Widget get pageContent {
    switch (activePage) {
      case 'volunteers':
        return const VolunteerPage();
      case 'events':
        return const EventsPage();
      case 'settings':
        return const Center(child: Text('Settings Page'));
      case 'home':
      default:
        return const Center(
          child: Text(
            'Welcome',
            style: TextStyle(fontSize: 24),
          ),
        );
    }
  }

  void setActivePage(String page, BuildContext buildContext) {
    setState(() {
      activePage = page;
    });
    Navigator.pop(buildContext); // use the renamed parameter
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          activePage == 'home'
              ? 'Home'
              : activePage == 'volunteers'
                  ? 'Volunteer List'
                  : activePage == 'events'
                      ? 'Events'
                  : 'Settings',
        ),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                selected: activePage == 'home',
                onTap: () => setActivePage('home', context),
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Volunteer List'),
                selected: activePage == 'volunteers',
                onTap: () => setActivePage('volunteers', context),
              ),
              ListTile(
                leading: const Icon(Icons.assignment),
                title: const Text('Events'),
                selected: activePage == 'events',
                onTap: () => setActivePage('events', context),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                selected: activePage == 'settings',
                onTap: () => setActivePage('settings', context),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code),
                    label: const Text('Connect to Phone'),
                    onPressed: () {
                      Navigator.pop(context);
                      setActivePage('connect', context); // optional: handle QR connect
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ConnectQr(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: pageContent,
    );
  }
}
