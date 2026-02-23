import 'dart:io';
import 'package:flutter/material.dart';
import 'package:volopsip/models/volunteer.dart';
import 'package:volopsip/helpers/volunteer_page/vol_details.dart';

class VolunteerListItem extends StatelessWidget {
  final Volunteer volunteer;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onVolunteerUpdated;

  const VolunteerListItem({
    super.key,
    required this.volunteer,
    required this.isSelected,
    this.onTap,
    this.onLongPress,
    this.onVolunteerUpdated,
  });

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => VolunteerDetailsModal(
        volunteer: volunteer,
        onVolunteerUpdated: onVolunteerUpdated ?? () {},
      ),
    );
  }

  Widget _buildAvatar() {
    final path = volunteer.photoPath;

    if (path == null || path.isEmpty) {
      return const Icon(Icons.person, size: 50, color: Colors.white);
    }

    String imageUrl = path;

    // --- Convert Google Drive links to direct links ---
    if (path.contains("drive.google.com")) {
      final uri = Uri.parse(path);
      String? fileId;

      // Check for "id=" query parameter
      if (uri.queryParameters.containsKey('id')) {
        fileId = uri.queryParameters['id'];
      } else {
        // Sometimes the file ID is in the path itself: /file/d/FILE_ID/view
        final segments = uri.pathSegments;
        final idIndex = segments.indexOf('d');
        if (idIndex != -1 && segments.length > idIndex + 1) {
          fileId = segments[idIndex + 1];
        }
      }

      if (fileId != null) {
        imageUrl = 'https://drive.google.com/uc?export=view&id=$fileId';
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.person, size: 50, color: Colors.white),
      ),
    );
  }

  
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap ?? () => _showDetails(context),
        onLongPress: onLongPress,
        child: SizedBox.expand( // ✅ match parent
          child: Stack(
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                clipBehavior: Clip.hardEdge,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // keep child size
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _buildAvatar(),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          volunteer.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Hover / Selection overlay
              if (isSelected)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
