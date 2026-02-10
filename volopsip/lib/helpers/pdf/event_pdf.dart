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

  static String formatTimestamp(DateTime? ts) {
    if (ts == null) return '';
    final months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final monthName = months[ts.month];
    final hour12 = ts.hour == 0 ? 12 : ts.hour > 12 ? ts.hour - 12 : ts.hour;
    final ampm = ts.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = ts.minute.toString().padLeft(2, '0');
    return '$monthName ${ts.day}, ${ts.year} $hour12:$minuteStr$ampm';
  }

  static Future<void> export({
    required Event event,
    required List<EventAssignment> assignments,
    EventPdfFilter? filter,
  }) async {
    final pdf = pw.Document();
    final appliedFilter = filter ?? const EventPdfFilter();

    // Load all volunteers
    final volunteerRepo = VolunteerRepository();
    final volunteers = await volunteerRepo.getAllVolunteers();

    // Map volunteerId → assignment (for this event)
    final Map<int, EventAssignment> assignmentByVolunteerId = {
      for (final a in assignments) a.volunteerId: a
    };

    // Only include volunteers assigned to this event
    final assignedVolunteerIds = assignmentByVolunteerId.keys.toSet();

    // Apply filters
    final filteredVolunteers = volunteers.where((v) {
      if (v.id == null) return false;
      if (!assignedVolunteerIds.contains(v.id!)) return false; // <-- only assigned
      if (!appliedFilter.matches(v)) return false;

      if (appliedFilter.attributes.isNotEmpty) {
        final status = assignmentByVolunteerId[v.id!]?.attribute.isNotEmpty == true
            ? assignmentByVolunteerId[v.id!]!.attribute
            : 'Unassigned';
        if (!appliedFilter.attributes.contains(status)) return false;
      }

      return true;
    }).toList();

    // Apply sorting
    filteredVolunteers.sort((a, b) {
      switch (appliedFilter.sortType) {
        case EventPdfSortType.status:
          final sa = assignmentByVolunteerId[a.id!]?.attribute.isNotEmpty == true
              ? assignmentByVolunteerId[a.id!]!.attribute
              : 'Unassigned';
          final sb = assignmentByVolunteerId[b.id!]?.attribute.isNotEmpty == true
              ? assignmentByVolunteerId[b.id!]!.attribute
              : 'Unassigned';
          return sa.compareTo(sb);

        case EventPdfSortType.department:
          return a.department.compareTo(b.department);

        case EventPdfSortType.volunteerType:
          return a.volunteerType.compareTo(b.volunteerType);

        case EventPdfSortType.alphabetical:
        default:
          return a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
      }
    });

    // Build PDF page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              event.name,
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 12),
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
                      if (appliedFilter.attributes.isNotEmpty)
                        'Status: ${appliedFilter.attributes.join(', ')}',
                    ].join(' | '),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Volunteers',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            if (filteredVolunteers.isEmpty)
              pw.Text(
                'No volunteers match the selected filters.',
                style: pw.TextStyle(fontStyle: pw.FontStyle.italic, color: PdfColors.grey700),
              )
            else
              pw.Table.fromTextArray(
                headers: const [
                  'Last Modified',
                  'Name',
                  'Volunteer Type',
                  'Department',
                  'Status',
                ],
                data: filteredVolunteers.map((v) {
                  final assignment = assignmentByVolunteerId[v.id!];
                  final formattedTime = formatTimestamp(assignment?.lastModified);

                  final status = assignment?.attribute.isNotEmpty == true
                      ? assignment!.attribute
                      : 'Unassigned';

                  return [
                    formattedTime,
                    v.fullName,
                    v.volunteerType,
                    v.department,
                    status,
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
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
