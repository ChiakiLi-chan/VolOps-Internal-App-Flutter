import 'package:flutter/material.dart';
import '../repo/volunteer_repo.dart';
import 'package:volopsip/helpers/volunteer_page/vol_details.dart';
import 'package:volopsip/helpers/volunteer_page/vol_provider.dart';
import 'package:provider/provider.dart';
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // ❌ Close (X) button
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
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      child: Icon(Icons.person, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            volunteer.fullName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            volunteer.volunteerType,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Info section
                _InfoRow(label: 'Email', value: volunteer.email),
                _InfoRow(label: 'Contact', value: volunteer.contactNumber),

                const Divider(height: 24),

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
                            builder: (context) {
                              return ProfileAddVolunteerToEvent(
                                volunteer: volunteer,
                              );
                            },
                          );
                        },
                      ),
                    const SizedBox(width: 8),
                    TextButton(
                      child: const Text('View Profile'),
                      onPressed: () {
                        Navigator.pop(context); // close first popup

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
                                      // Refresh the provider when changes happen
                                      // Assuming you use Provider for VolunteerPage
                                      if (context.mounted) {
                                        // trigger a provider refresh
                                        final provider = context.read<VolunteerProvider>();
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
        ],
      ),
    ),
  );
}

/// Reusable info row
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
