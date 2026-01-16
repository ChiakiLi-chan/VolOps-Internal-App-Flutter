import 'package:flutter/material.dart';
import 'package:volopsip/models/volunteer.dart';
import 'package:volopsip/helpers/volunteer_page/vol_details.dart'; // make sure the path matches

class VolunteerListItem extends StatelessWidget {
  final Volunteer volunteer;
  final VoidCallback? onVolunteerUpdated; // now optional

  const VolunteerListItem({
    super.key,
    required this.volunteer,
    this.onVolunteerUpdated, // optional
  });

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => VolunteerDetailsModal(
        volunteer: volunteer,
        onVolunteerUpdated: onVolunteerUpdated ?? () {}, // fallback if null
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetails(context),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            volunteer.fullName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
