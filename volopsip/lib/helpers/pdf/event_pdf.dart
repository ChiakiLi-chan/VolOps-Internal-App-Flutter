import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../models/events.dart';
import '../../models/event_assignment.dart';
import '../../models/volunteer.dart';

class EventPdfExporter {
  static String _safeFileName(String name) {
    return name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }

  static Future<void> export({
    required Event event,
    required List<EventAssignment> assignments,
    required List<Volunteer> volunteers,
  }) async {
    final pdf = pw.Document();

    final volunteerMap = {
      for (var v in volunteers)
        if (v.id != null) v.id!: v,
    };

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              event.name,
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),

            pw.Text(
              'Attributes:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(event.attributes.join(', ')),

            pw.SizedBox(height: 20),

            pw.Text(
              'Volunteers',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),

            pw.Table.fromTextArray(
              headers: ['Name', 'Status'],
              data: assignments.map((a) {
                final v = volunteerMap[a.volunteerId];
                return [
                  v?.firstName ?? 'Unknown',
                  a.attribute,
                ];
              }).toList(),
            ),
          ],
        ),
      ),
    );

    // ✅ FIXED SAVE LOCATION
    final baseDir = Directory(r'C:\flutter\VolOps-Internal-App-Flutter');

    // Ensure folder exists
    if (!await baseDir.exists()) {
      await baseDir.create(recursive: true);
    }

    final safeName = _safeFileName(event.name);
    final file = File(p.join(baseDir.path, '$safeName.pdf'));

    await file.writeAsBytes(await pdf.save());

    // ✅ Open PDF using default Windows viewer
    await Process.run(
      'cmd',
      ['/c', 'start', '', file.path],
      runInShell: true,
    );
  }
}
