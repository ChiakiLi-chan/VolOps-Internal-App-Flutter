import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import '../../models/volunteer.dart';

class VolunteerExcelExport {
  static Future<void> export({
    required List<Volunteer> volunteers,
    String? volunteerTypeFilter,
    Set<String>? departmentFilter,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Volunteers'];

    // ✅ HEADER (Import-compatible + UUID at end)
    sheet.appendRow([
      TextCellValue('First Name'),     // 0
      TextCellValue('Last Name'),      // 1
      TextCellValue('Nickname'),       // 2
      TextCellValue('Age'),            // 3
      TextCellValue('Email'),          // 4
      TextCellValue('Contact Number'), // 5
      TextCellValue('Volunteer Type'), // 6
      TextCellValue('Department'),     // 7
      TextCellValue('Image URL'),      // 8
      TextCellValue('UUID'),           // 9 (extra)
    ]);

    // ✅ DATA ROWS
    for (final v in volunteers) {
      sheet.appendRow([
        TextCellValue(v.firstName ?? ''),
        TextCellValue(v.lastName ?? ''),
        TextCellValue(v.nickname ?? ''),
        IntCellValue(v.age ?? 0),
        TextCellValue(v.email ?? ''),
        TextCellValue(v.contactNumber ?? ''),
        TextCellValue(v.volunteerType ?? ''),
        TextCellValue(v.department ?? ''),
        TextCellValue(v.photoPath ?? ''),
        TextCellValue(v.uuid ?? ''),   // <-- UUID here
      ]);
    }

    final directory = await getApplicationDocumentsDirectory();
    final filePath =
        '${directory.path}/volunteers_${DateTime.now().millisecondsSinceEpoch}.xlsx';

    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);

    await OpenFile.open(filePath);
  }
}