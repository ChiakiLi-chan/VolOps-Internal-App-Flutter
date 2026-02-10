import '../../models/volunteer.dart';
import 'event_pdf_sort.dart';

class EventPdfFilter {
  final String? volunteerType;   // null = all
  final Set<String> departments; // empty = all
  final EventPdfSortType sortType;
  final Set<String> attributes; // ✅ NEW


  const EventPdfFilter({
    this.volunteerType,
    this.departments = const {},
    this.attributes = const {}, // ✅ NEW
    this.sortType = EventPdfSortType.alphabetical,
  });

  bool get isEmpty =>
      volunteerType == null &&
      departments.isEmpty &&
      attributes.isEmpty;

  bool matches(Volunteer v) {
    if (volunteerType != null && v.volunteerType != volunteerType) {
      return false;
    }

    if (departments.isNotEmpty && !departments.contains(v.department)) {
      return false;
    }

    // ⚠️ attributes are event-specific → handled in exporter
    return true;
  }
}
