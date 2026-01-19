import '../../models/volunteer.dart';
import 'event_pdf_sort.dart';

class EventPdfFilter {
  final String? volunteerType;   // null = all
  final Set<String> departments; // empty = all
  final EventPdfSortType sortType;

  const EventPdfFilter({
    this.volunteerType,
    this.departments = const {},
    this.sortType = EventPdfSortType.alphabetical,
  });

  bool matches(Volunteer v) {
    final matchesType =
        volunteerType == null || v.volunteerType == volunteerType;

    final matchesDepartment =
        departments.isEmpty || departments.contains(v.department);

    return matchesType && matchesDepartment;
  }

  bool get isEmpty =>
      volunteerType == null &&
      departments.isEmpty &&
      sortType == EventPdfSortType.alphabetical;
}
