import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';

import '../models/volunteer.dart';
import '../repo/volunteer_repo.dart';

class AddVolunteerExcelModal extends StatelessWidget {
  final VoidCallback onVolunteersAdded;

  const AddVolunteerExcelModal({
    super.key,
    required this.onVolunteersAdded,
  });

  String _key(String firstName, String lastName) {
    return '${firstName.trim().toLowerCase()}|${lastName.trim().toLowerCase()}';
  }

  Future<void> _importExcel(BuildContext context) async {
    final repo = VolunteerRepository();

    // Pick XLSX file
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result == null) return;

    // Load existing volunteers ONCE
    final existingVolunteers = await repo.getAllVolunteers();

    final existingKeys = <String>{
      for (final v in existingVolunteers)
        _key(v.firstName, v.lastName),
    };

    final file = File(result.files.single.path!);
    final bytes = file.readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);

    int importedCount = 0;
    int skippedCount = 0;

    for (final sheet in excel.tables.keys) {
      final rows = excel.tables[sheet]!.rows;

      // Skip header row
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty) continue;

        final firstName = row[0]?.value.toString() ?? '';
        final lastName = row[1]?.value.toString() ?? '';

        // Skip invalid rows
        if (firstName.isEmpty || lastName.isEmpty) {
          skippedCount++;
          continue;
        }

        final key = _key(firstName, lastName);

        // Skip duplicates
        if (existingKeys.contains(key)) {
          skippedCount++;
          continue;
        }

        final volunteer = Volunteer(
          firstName: firstName,
          lastName: lastName,
          nickname: row[2]?.value?.toString().trim().isEmpty ?? true
              ? null
              : row[2]!.value.toString(),
          age: int.tryParse(row[3]?.value.toString() ?? '0') ?? 0,
          email: row[4]?.value.toString() ?? '',
          contactNumber: row[5]?.value.toString() ?? '',
          volunteerType: row[6]?.value.toString() ?? 'OTD',
          department: row[7]?.value.toString() ?? '',
        );

        await repo.createVolunteer(volunteer);
        existingKeys.add(key); // prevent duplicates inside same file
        importedCount++;
      }
    }

    Navigator.pop(context);
    onVolunteersAdded();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$importedCount imported, $skippedCount skipped (duplicates or invalid)',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Import Volunteers from Excel',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ElevatedButton.icon(
            icon: const Icon(Icons.upload_file),
            label: const Text('Select XLSX File'),
            onPressed: () => _importExcel(context),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
