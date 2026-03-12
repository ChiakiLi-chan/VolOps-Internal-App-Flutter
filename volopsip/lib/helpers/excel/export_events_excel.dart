import 'dart:io';
import 'package:path/path.dart' as p;

import '../../models/events.dart';
import '../../models/event_assignment.dart';
import '../../models/volunteer.dart';
import '../../repo/volunteer_repo.dart';
import 'package:volopsip/helpers/pdf/event_pdf_filter.dart';
import 'package:volopsip/helpers/pdf/event_pdf_sort.dart';

class EventCsvExporter {

  static String _safeFileName(String name) {
    return name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }

  static String formatTimestamp(DateTime? ts) {
    if (ts == null) return '';

    final months = [
      '',
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
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

    final appliedFilter = filter ?? const EventPdfFilter();

    final volunteerRepo = VolunteerRepository();
    final volunteers = await volunteerRepo.getAllVolunteers();

    final Map<int, EventAssignment> assignmentByVolunteerId = {
      for (final a in assignments) a.volunteerId: a
    };

    final assignedVolunteerIds = assignmentByVolunteerId.keys.toSet();

    /// =========================
    /// APPLY FILTERS
    /// =========================
    final filteredVolunteers = volunteers.where((v) {

      if (v.id == null) return false;
      if (!assignedVolunteerIds.contains(v.id!)) return false;
      if (!appliedFilter.matches(v)) return false;

      if (appliedFilter.attributes.isNotEmpty) {

        final status =
            assignmentByVolunteerId[v.id!]?.attribute.isNotEmpty == true
                ? assignmentByVolunteerId[v.id!]!.attribute
                : 'Unassigned';

        if (!appliedFilter.attributes.contains(status)) return false;
      }

      return true;

    }).toList();

    /// =========================
    /// APPLY SORTING
    /// =========================
    filteredVolunteers.sort((a, b) {

      switch (appliedFilter.sortType) {

        case EventPdfSortType.status:

          final sa =
              assignmentByVolunteerId[a.id!]?.attribute.isNotEmpty == true
                  ? assignmentByVolunteerId[a.id!]!.attribute
                  : 'Unassigned';

          final sb =
              assignmentByVolunteerId[b.id!]?.attribute.isNotEmpty == true
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

    /// =========================
    /// BUILD CSV CONTENT
    /// =========================
    final buffer = StringBuffer();

    /// HEADER
    buffer.writeln('Last Modified,Name,Volunteer Type,Department,Status');

    /// ROWS
    for (final v in filteredVolunteers) {

      final assignment = assignmentByVolunteerId[v.id!];

      final formattedTime =
          formatTimestamp(assignment?.lastModified);

      final status =
          assignment?.attribute.isNotEmpty == true
              ? assignment!.attribute
              : 'Unassigned';

      buffer.writeln(
        '"$formattedTime","${v.fullName}","${v.volunteerType}","${v.department}","$status"'
      );
    }

    /// =========================
    /// SAVE FILE
    /// =========================
    final baseDir = Directory(r'C:\flutter\VolOps-Internal-App-Flutter');

    if (!await baseDir.exists()) {
      await baseDir.create(recursive: true);
    }

    final file = File(
      p.join(baseDir.path, '${_safeFileName(event.name)}.csv'),
    );

    await file.writeAsString(buffer.toString());

    /// =========================
    /// OPEN FILE (Windows)
    /// =========================
    await Process.run(
      'cmd',
      ['/c', 'start', '', file.path],
      runInShell: true,
    );
  }
}