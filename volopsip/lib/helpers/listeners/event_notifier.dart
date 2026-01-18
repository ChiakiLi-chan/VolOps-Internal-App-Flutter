import 'package:flutter/material.dart';

class VolunteerEventNotifier extends ChangeNotifier {
  void updated() {
    notifyListeners();
  }
}

// Singleton instance
final volunteerEventNotifier = VolunteerEventNotifier();
