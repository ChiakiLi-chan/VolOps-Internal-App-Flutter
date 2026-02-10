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

    /// =======================
    /// BUILD TABLE HEADERS
    /// =======================
    final headers = <pw.Widget>[
      if (columns.contains(VolunteerPdfColumn.fullName))
        _headerCell('Name'),
      if (columns.contains(VolunteerPdfColumn.nickname))
        _headerCell('Nickname'),
      if (columns.contains(VolunteerPdfColumn.age))
        _headerCell('Age'),
      if (columns.contains(VolunteerPdfColumn.email))
        _headerCell('Email'),
      if (columns.contains(VolunteerPdfColumn.contactNumber))
        _headerCell('Contact'),
      if (columns.contains(VolunteerPdfColumn.volunteerType))
        _headerCell('Volunteer Type'),
      if (columns.contains(VolunteerPdfColumn.department))
        _headerCell('Department'),
      if (columns.contains(VolunteerPdfColumn.qr))
        _headerCell('QR'),
    ];

    /// =======================
    /// BUILD TABLE ROWS
    /// =======================
    final rows = volunteers.map((v) {
      return <pw.Widget>[
        if (columns.contains(VolunteerPdfColumn.fullName))
          _cell(pw.Text(v.fullName)),

        if (columns.contains(VolunteerPdfColumn.nickname))
          _cell(pw.Text(v.nickname ?? '-')),

        if (columns.contains(VolunteerPdfColumn.age))
          _cell(pw.Text(v.age.toString())),

        if (columns.contains(VolunteerPdfColumn.email))
          _cell(pw.Text(v.email)),

        if (columns.contains(VolunteerPdfColumn.contactNumber))
          _cell(pw.Text(v.contactNumber)),

        if (columns.contains(VolunteerPdfColumn.volunteerType))
          _cell(pw.Text(v.volunteerType)),

        if (columns.contains(VolunteerPdfColumn.department))
          _cell(pw.Text(v.department)),

        if (columns.contains(VolunteerPdfColumn.qr))
          _cell(
            pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              data: v.uuid,
              width: 45,
              height: 45,
            ),
            alignCenter: true,
          ),
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
                : pw.Table(
                    border: pw.TableBorder.all(
                      color: PdfColors.grey400,
                    ),
                    defaultVerticalAlignment:
                        pw.TableCellVerticalAlignment.middle,
                    children: [
                      // Header row
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.grey300,
                        ),
                        children: headers,
                      ),

                      // Data rows
                      ...rows.map(
                        (cells) => pw.TableRow(children: cells),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );

    /// =======================
    /// SAVE & OPEN FILE
    /// =======================
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

  /// =======================
  /// HELPERS
  /// =======================
  static pw.Widget _headerCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _cell(pw.Widget child, {bool alignCenter = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: alignCenter
          ? pw.Center(child: child)
          : child,
    );
  }
}
