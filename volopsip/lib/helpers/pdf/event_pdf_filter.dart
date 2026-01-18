import '../../models/volunteer.dart';

class EventPdfFilter {
  final String? volunteerType;   // null = all
  final Set<String> departments; // empty = all

  const EventPdfFilter({
    this.volunteerType,
    this.departments = const {},
  });

  bool matches(Volunteer v) {
    final matchesType =
        volunteerType == null || v.volunteerType == volunteerType;

    final matchesDepartment =
        departments.isEmpty || departments.contains(v.department);

    return matchesType && matchesDepartment;
  }

  bool get isEmpty =>
      volunteerType == null && departments.isEmpty;
}
