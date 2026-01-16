import 'package:flutter/material.dart';
import 'landing_page.dart'; // this is the new page

void main() {
  runApp(const PhoneApp());
}

class PhoneApp extends StatelessWidget {
  const PhoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ScanLandingPage(), // starts here
    );
  }
}
