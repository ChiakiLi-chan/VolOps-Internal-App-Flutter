import 'package:flutter/material.dart';
import '../repo/volunteer_repo.dart';
import 'package:volopsip/helpers/volunteer_page/vol_details.dart';
import 'package:volopsip/helpers/volunteer_page/vol_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:volopsip/modal/add_volunteer_to_event.dart';

Future<void> showVolunteerPopup(BuildContext context, String uuid) async {
  final repo = VolunteerRepository();
  final volunteer = await repo.getVolunteerByUuid(uuid);

  if (!context.mounted) return;

  if (volunteer == null) {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text('Volunteer Not Found'),
        content: Text(
          'No volunteer found with this UUID:\n\n$uuid',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return;
  }

  await showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          // Close button
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close),
              splashRadius: 20,
              tooltip: 'Close',
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Dialog content
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with image
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.blue.shade100,
                        backgroundImage: volunteer.photoPath != null && volunteer.photoPath!.isNotEmpty
                            ? FileImage(File(volunteer.photoPath!))
                            : null,
                        child: (volunteer.photoPath == null || volunteer.photoPath!.isEmpty)
                            ? const Icon(Icons.person, size: 28, color: Colors.blue)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              volunteer.fullName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              volunteer.volunteerType,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Info section
                  _InfoRow(label: 'Email', value: volunteer.email),
                  _InfoRow(label: 'Contact', value: volunteer.contactNumber),

                  const Divider(height: 32),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.event),
                        label: const Text('Add to Event'),
                        onPressed: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => ProfileAddVolunteerToEvent(
                              volunteer: volunteer,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('View Profile'),
                        onPressed: () {
                          Navigator.pop(context); // Close first popup
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: VolunteerDetailsModal(
                                      volunteer: volunteer,
                                      onVolunteerUpdated: () {
                                        if (context.mounted) {
                                          final provider =
                                              context.read<VolunteerProvider>();
                                          provider.refresh();
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
