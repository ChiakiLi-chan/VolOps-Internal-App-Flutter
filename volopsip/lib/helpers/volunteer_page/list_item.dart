import 'dart:io';
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
  // /// ✅ Converts Google Drive "share" links into direct image links
  // String _normalizeImageUrl(String url) {
  //   if (!url.contains('drive.google.com')) return url;

  //   final match = RegExp(r'/d/([^/]+)').firstMatch(url);
  //   if (match == null) return url;

  //   final fileId = match.group(1);
  //   return 'https://drive.google.com/uc?export=view&id=$fileId';
  // }

  Widget _buildAvatar() {
    final path = volunteer.photoPath;

    if (path == null || path.isEmpty) {
      return const Icon(Icons.person, size: 50, color: Colors.white);
    }

    // 🌐 Network image (Google Drive / URL)
    if (path.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          path,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.person, size: 50, color: Colors.white),
        ),
      );
    }

    // 📁 Local file image
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(path),
        width: 100,
        height: 100,
        fit: BoxFit.cover,
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
            child: _buildAvatar(), // ✅ THIS WAS THE MISSING PART
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
