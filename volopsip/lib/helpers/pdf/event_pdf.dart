import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../models/events.dart';
import '../../models/event_assignment.dart';
import '../../models/volunteer.dart';
import 'event_pdf_filter.dart';
import 'event_pdf_sort.dart';
import '../../repo/volunteer_repo.dart';

class EventPdfExporter {
  static String _safeFileName(String name) {
    return name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }

  static Future<void> export({
    required Event event,
    required List<EventAssignment> assignments,
    EventPdfFilter? filter,
  }) async {
    final pdf = pw.Document();
    final appliedFilter = filter ?? const EventPdfFilter();

    // 🔑 ALWAYS load volunteers from DB
    final volunteerRepo = VolunteerRepository();
    final volunteers = await volunteerRepo.getAllVolunteers();

    print('PDF EXPORT DEBUG');
    print('Volunteers loaded from DB: ${volunteers.length}');
    print('Assignments passed in: ${assignments.length}');

    final Map<int, String> assignmentStatusByVolunteerId = {
      for (final a in assignments)
        a.volunteerId:
            a.attribute.isNotEmpty ? a.attribute : 'Unassigned',
    };

    final filteredVolunteers = volunteers.where((v) {
      if (v.id == null) return false;
      return appliedFilter.matches(v);
    }).toList();

    // 🔑 APPLY SORTING
filteredVolunteers.sort((a, b) {
  switch (appliedFilter.sortType) {
    case EventPdfSortType.status:
      final sa = assignmentStatusByVolunteerId[a.id!] ?? 'Unassigned';
      final sb = assignmentStatusByVolunteerId[b.id!] ?? 'Unassigned';
      return sa.compareTo(sb);

    case EventPdfSortType.department:
      return a.department.compareTo(b.department);

    case EventPdfSortType.volunteerType:
      return a.volunteerType.compareTo(b.volunteerType);

    case EventPdfSortType.alphabetical:
    default:
      return a.fullName.toLowerCase()
        .compareTo(b.fullName.toLowerCase());
  }
});

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Event title
            pw.Text(
              event.name,
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 12),

            // Filter summary
            pw.Text(
              'Filters Applied:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              appliedFilter.isEmpty
                  ? 'None (All volunteers)'
                  : [
                      if (appliedFilter.volunteerType != null)
                        'Volunteer Type: ${appliedFilter.volunteerType}',
                      if (appliedFilter.departments.isNotEmpty)
                        'Departments: ${appliedFilter.departments.join(', ')}',
                    ].join(' | '),
            ),

            pw.SizedBox(height: 20),

            pw.Text(
              'Volunteers',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),

            // 🔑 STEP 2: SHOW RESULT
            if (filteredVolunteers.isEmpty)
              pw.Text(
                'No volunteers match the selected filters.',
                style: pw.TextStyle(
                  fontStyle: pw.FontStyle.italic,
                  color: PdfColors.grey700,
                ),
              )
            else
              pw.Table.fromTextArray(
                headers: const [
                  'Name',
                  'Volunteer Type',
                  'Department',
                  'Status',
                ],
                data: filteredVolunteers.map((v) {
                  final status =
                      assignmentStatusByVolunteerId[v.id!] ?? 'Unassigned';

                  return [
                    v.fullName,
                    v.volunteerType,
                    v.department,
                    status,
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.grey300),
              ),
          ],
        ),
      ),
    );

    // Save file
    final baseDir = Directory(r'C:\flutter\VolOps-Internal-App-Flutter');
    if (!await baseDir.exists()) {
      await baseDir.create(recursive: true);
    }

    final file = File(
      p.join(baseDir.path, '${_safeFileName(event.name)}.pdf'),
    );

    await file.writeAsBytes(await pdf.save());

    // Open PDF (Windows)
    await Process.run(
      'cmd',
      ['/c', 'start', '', file.path],
      runInShell: true,
    );
  }
}
