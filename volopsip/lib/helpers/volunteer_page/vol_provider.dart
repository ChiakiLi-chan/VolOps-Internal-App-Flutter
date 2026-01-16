import 'package:flutter/material.dart';
import 'package:volopsip/repo/volunteer_repo.dart';
import 'package:volopsip/models/volunteer.dart';

class VolunteerProvider extends ChangeNotifier {
  final VolunteerRepository _repo = VolunteerRepository();

  List<Volunteer> _volunteers = [];
  bool _isLoading = false;

  List<Volunteer> get volunteers => _volunteers;
  bool get isLoading => _isLoading;

  Future<void> fetchVolunteers() async {
    _isLoading = true;
    notifyListeners();

    _volunteers = await _repo.getAllVolunteers();

    _isLoading = false;
    notifyListeners();
  }

  /// Call this after edits / deletes / adds
  Future<void> refresh() async {
    await fetchVolunteers();
  }
}
