import 'package:flutter/material.dart';
import 'package:volopsip/modal/profile_modal.dart'; 

class VolunteerLookupPage extends StatefulWidget {
  const VolunteerLookupPage({super.key});

  @override
  State<VolunteerLookupPage> createState() => _VolunteerLookupPageState();
}

class _VolunteerLookupPageState extends State<VolunteerLookupPage> {
  final TextEditingController _uuidController = TextEditingController();

  void _lookupVolunteer() {
    final uuid = _uuidController.text.trim();

    if (uuid.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('Missing UUID'),
          content: Text('Please enter a UUID to test.'),
        ),
      );
      return;
    }

    // 🔥 THIS is the important part
    showVolunteerPopup(context, uuid);
  }

  @override
  void dispose() {
    _uuidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Volunteer Lookup')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _uuidController,
              decoration: const InputDecoration(
                labelText: 'Enter Volunteer UUID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _lookupVolunteer,
              child: const Text('Test Popup'),
            ),
          ],
        ),
      ),
    );
  }
}
