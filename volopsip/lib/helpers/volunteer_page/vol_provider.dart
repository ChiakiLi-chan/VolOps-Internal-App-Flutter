import 'package:flutter/material.dart';
import 'package:volopsip/repo/volunteer_repo.dart';
import 'package:volopsip/models/volunteer.dart';

class VolunteerProvider extends ChangeNotifier {
  final VolunteerRepository _repo = VolunteerRepository();

  // Raw data from DB
  List<Volunteer> _allVolunteers = [];

  // Filtered data exposed to UI
  List<Volunteer> _volunteers = [];

  bool _isLoading = false;

  // Active filters
  String? filterVolunteerType;        // null = all
  Set<String> filterDepartments = {}; // empty = all

  List<Volunteer> get volunteers => _volunteers;
  bool get isLoading => _isLoading;

  /// Unique departments for filter modal
  List<String> get availableDepartments {
    final set = <String>{};
    for (final v in _allVolunteers) {
      if (v.department != null && v.department!.isNotEmpty) {
        set.add(v.department!);
      }
    }
    return set.toList()..sort();
  }

  Future<void> fetchVolunteers() async {
    _isLoading = true;
    notifyListeners();

    _allVolunteers = await _repo.getAllVolunteers();
    _applyFilterLogic();

    _isLoading = false;
    notifyListeners();
  }

  /// Call after add / edit / delete
  Future<void> refresh() async {
    await fetchVolunteers();
  }

  /// Apply filters from modal
  void applyFilters({
    String? volunteerType,
    Set<String>? departments,
  }) {
    filterVolunteerType = volunteerType;
    filterDepartments = departments ?? {};
    _applyFilterLogic();
    notifyListeners();
  }

  /// Reset filters (show all)
  void clearFilters() {
    filterVolunteerType = null;
    filterDepartments.clear();
    _applyFilterLogic();
    notifyListeners();
  }

  void _applyFilterLogic() {
    _volunteers = _allVolunteers.where((v) {
      final matchesType =
          filterVolunteerType == null ||
          v.volunteerType == filterVolunteerType;

      final matchesDepartment =
          filterDepartments.isEmpty ||
          (v.department != null && filterDepartments.contains(v.department));

      return matchesType && matchesDepartment;
    }).toList();
  }
}
