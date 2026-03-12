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

    /// ======================
    /// COLUMN CONFIGURATION
    /// ======================
    final columnConfig = {
      VolunteerPdfColumn.fullName: {
        'header': 'Name',
        'width': const pw.FlexColumnWidth(2),
        'value': (Volunteer v) => '${v.lastName}, ${v.firstName}',
      },

      VolunteerPdfColumn.nickname: {
        'header': 'Nickname',
        'width': const pw.FlexColumnWidth(1.5),
        'value': (Volunteer v) => v.nickname ?? '-',
      },

      VolunteerPdfColumn.age: {
        'header': 'Age',
        'width': const pw.FlexColumnWidth(1),
        'value': (Volunteer v) => v.age?.toString() ?? '-',
      },

      VolunteerPdfColumn.email: {
        'header': 'Email',
        'width': const pw.FlexColumnWidth(3),
        'value': (Volunteer v) => v.email,
      },

      VolunteerPdfColumn.contactNumber: {
        'header': 'Contact',
        'width': const pw.FlexColumnWidth(2),
        'value': (Volunteer v) => v.contactNumber,
      },

      VolunteerPdfColumn.volunteerType: {
        'header': 'Volunteer Type',
        'width': const pw.FlexColumnWidth(2),
        'value': (Volunteer v) => v.volunteerType,
      },

      VolunteerPdfColumn.department: {
        'header': 'Department',
        'width': const pw.FlexColumnWidth(2),
        'value': (Volunteer v) => v.department,
      },
    };

    /// ======================
    /// PAGE ORIENTATION
    /// ======================
    final pageFormat = columns.length > 5
        ? PdfPageFormat.a4.landscape
        : PdfPageFormat.a4;

    /// ======================
    /// BUILD HEADERS
    /// ======================
    final headers = columns.map((col) {
      if (col == VolunteerPdfColumn.qr) {
        return _headerCell('QR');
      }

      return _headerCell(columnConfig[col]!['header'] as String);
    }).toList();

    /// ======================
    /// BUILD COLUMN WIDTHS
    /// ======================
    final columnWidths = <int, pw.TableColumnWidth>{};

    int i = 0;
    for (final col in columns) {
      if (col == VolunteerPdfColumn.qr) {
        columnWidths[i] = const pw.FlexColumnWidth(1);
      } else {
        columnWidths[i] =
            columnConfig[col]!['width'] as pw.TableColumnWidth;
      }
      i++;
    }

    /// ======================
    /// BUILD ROWS
    /// ======================
    final rows = volunteers.map((v) {

      return columns.map((col) {

        if (col == VolunteerPdfColumn.qr) {
          return _cell(
            pw.Center(
              child: pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: v.uuid,
                width: 30,
                height: 30,
              ),
            ),
          );
        }

        final valueFunction =
            columnConfig[col]!['value'] as Function;

        final text = valueFunction(v).toString();

        return _cell(
          pw.Text(
            text,
            softWrap: true,
          ),
        );

      }).toList();

    }).toList();

    /// ======================
    /// BUILD PDF PAGE
    /// ======================
    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(16),

        build: (_) => [

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
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
            ),
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
                  columnWidths: columnWidths,
                  border: pw.TableBorder.all(
                    color: PdfColors.grey400,
                  ),

                  defaultVerticalAlignment:
                      pw.TableCellVerticalAlignment.middle,

                  children: [

                    /// HEADER ROW
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey300,
                      ),
                      children: headers,
                    ),

                    /// DATA ROWS
                    ...rows.map(
                      (cells) => pw.TableRow(children: cells),
                    ),
                  ],
                ),
        ],
      ),
    );

    /// ======================
    /// SAVE FILE
    /// ======================
    final baseDir = Directory(r'C:\flutter\VolOps-Internal-App-Flutter');

    if (!await baseDir.exists()) {
      await baseDir.create(recursive: true);
    }

    final file = File(
      p.join(baseDir.path, 'volunteers_report.pdf'),
    );

    await file.writeAsBytes(await pdf.save());

    /// ======================
    /// OPEN FILE
    /// ======================
    await Process.run(
      'cmd',
      ['/c', 'start', '', file.path],
      runInShell: true,
    );
  }

  /// ======================
  /// HEADER CELL
  /// ======================
  static pw.Widget _headerCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  /// ======================
  /// NORMAL CELL
  /// ======================
  static pw.Widget _cell(pw.Widget child) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: child,
    );
  }
}