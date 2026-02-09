import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../models/volunteer.dart';
import 'volunteer_pdf_columns.dart';

class VolunteerPdfExporter {
  static Future<void> export({
    required List<Volunteer> volunteers,
    required Set<VolunteerPdfColumn> columns,
    required String? volunteerTypeFilter,
    required Set<String> departmentFilter,
  }) async {
    final pdf = pw.Document();

    // 🔑 Header labels (fixed order)
    final headers = <String>[
      if (columns.contains(VolunteerPdfColumn.fullName)) 'Name',
      if (columns.contains(VolunteerPdfColumn.nickname)) 'Nickname',
      if (columns.contains(VolunteerPdfColumn.age)) 'Age',
      if (columns.contains(VolunteerPdfColumn.email)) 'Email',
      if (columns.contains(VolunteerPdfColumn.contactNumber)) 'Contact',
      if (columns.contains(VolunteerPdfColumn.volunteerType)) 'Volunteer Type',
      if (columns.contains(VolunteerPdfColumn.department)) 'Department',
    ];

    final data = volunteers.map((v) {
      return [
        if (columns.contains(VolunteerPdfColumn.fullName)) v.fullName,
        if (columns.contains(VolunteerPdfColumn.nickname)) v.nickname ?? '-',
        if (columns.contains(VolunteerPdfColumn.age)) v.age.toString(),
        if (columns.contains(VolunteerPdfColumn.email)) v.email,
        if (columns.contains(VolunteerPdfColumn.contactNumber)) v.contactNumber,
        if (columns.contains(VolunteerPdfColumn.volunteerType))
          v.volunteerType,
        if (columns.contains(VolunteerPdfColumn.department))
          v.department,
      ];
    }).toList();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Volunteer Report',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 8),

            pw.Text(
              'Filters:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              [
                volunteerTypeFilter != null
                    ? 'Volunteer Type: $volunteerTypeFilter'
                    : 'Volunteer Type: All',
                departmentFilter.isNotEmpty
                    ? 'Departments: ${departmentFilter.join(', ')}'
                    : 'Departments: All',
              ].join(' | '),
            ),

            pw.SizedBox(height: 16),

            volunteers.isEmpty
                ? pw.Text(
                    'No volunteers match the current filters.',
                    style: pw.TextStyle(
                      fontStyle: pw.FontStyle.italic,
                      color: PdfColors.grey700,
                    ),
                  )
                : pw.Table.fromTextArray(
                    headers: headers,
                    data: data,
                    headerStyle:
                        pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    cellAlignment: pw.Alignment.centerLeft,
                    headerDecoration:
                        const pw.BoxDecoration(color: PdfColors.grey300),
                  ),
          ],
        ),
      ),
    );

    final baseDir = Directory(r'C:\flutter\VolOps-Internal-App-Flutter');
    if (!await baseDir.exists()) {
      await baseDir.create(recursive: true);
    }

    final file = File(
      p.join(baseDir.path, 'volunteers_report.pdf'),
    );

    await file.writeAsBytes(await pdf.save());

    await Process.run(
      'cmd',
      ['/c', 'start', '', file.path],
      runInShell: true,
    );
  }
}
