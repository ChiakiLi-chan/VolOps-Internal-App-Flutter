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

  Future<void> _importExcel(BuildContext context) async {
    final repo = VolunteerRepository();

    // Pick XLSX file
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result == null) return;

    final file = File(result.files.single.path!);
    final bytes = file.readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);

    int importedCount = 0;

    for (final sheet in excel.tables.keys) {
      final rows = excel.tables[sheet]!.rows;

      // Skip header row (row 0)
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];

        if (row.isEmpty) continue;

        final volunteer = Volunteer(
          firstName: row[0]?.value.toString() ?? '',
          lastName: row[1]?.value.toString() ?? '',
          nickname: row[2]?.value?.toString().isEmpty ?? true
              ? null
              : row[2]!.value.toString(),
          age: int.tryParse(row[3]?.value.toString() ?? '0') ?? 0,
          email: row[4]?.value.toString() ?? '',
          contactNumber: row[5]?.value.toString() ?? '',
          volunteerType: row[6]?.value.toString() ?? 'OTD',
          department: row[7]?.value.toString() ?? '',
        );

        await repo.createVolunteer(volunteer);
        importedCount++;
      }
    }

    Navigator.pop(context);
    onVolunteersAdded();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$importedCount volunteers imported')),
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
