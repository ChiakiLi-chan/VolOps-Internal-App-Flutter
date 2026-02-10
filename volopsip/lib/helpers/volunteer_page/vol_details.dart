import 'dart:io';
import 'package:flutter/material.dart';
import 'package:volopsip/models/volunteer.dart';
import 'package:volopsip/repo/volunteer_repo.dart';
import 'package:volopsip/helpers/volunteer_page/vol_update.dart'; 
import 'package:qr_flutter/qr_flutter.dart';

class VolunteerDetailsModal extends StatefulWidget {
  final Volunteer volunteer;
  final VoidCallback onVolunteerUpdated;

  const VolunteerDetailsModal({
    super.key,
    required this.volunteer,
    required this.onVolunteerUpdated,
  });

  @override
  State<VolunteerDetailsModal> createState() => _VolunteerDetailsModalState();
}

class _VolunteerDetailsModalState extends State<VolunteerDetailsModal> {
  final VolunteerRepository _repo = VolunteerRepository();
  late Volunteer volunteer;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    volunteer = widget.volunteer;
  }

  Future<void> deleteVolunteer() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Volunteer'),
        content: const Text('Are you sure you want to delete this volunteer?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      await _repo.deleteVolunteer(volunteer.id!);
      widget.onVolunteerUpdated();
      Navigator.pop(context); // close details modal
    }
  }

  Widget _buildPhoto() {
    final path = volunteer.photoPath;

    if (path == null || path.isEmpty) {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.person, size: 60, color: Colors.white),
      );
    }

    if (path.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          path,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Container(
                width: 120,
                height: 120,
                color: Colors.grey.shade300,
                child: const Icon(Icons.person, size: 60, color: Colors.white),
              ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        File(path),
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24, 
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title + action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${volunteer.lastName}, ${volunteer.firstName}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(isEditing ? Icons.close : Icons.edit),
                      onPressed: () => setState(() => isEditing = !isEditing),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: deleteVolunteer,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Body
            if (isEditing)
              EditVolunteerForm(
                volunteer: volunteer,
                onSave: (updatedVolunteer) async {
                  await _repo.updateVolunteer(updatedVolunteer);
                  setState(() {
                    volunteer = updatedVolunteer;
                    isEditing = false;
                  });
                  widget.onVolunteerUpdated();
                },
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Volunteer Info Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(
                        color: Color.fromARGB(255, 0, 0, 0),
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPhoto(),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Personal Information',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const Divider(),
                                InfoRow(label: 'First Name', value: volunteer.firstName),
                                InfoRow(label: 'Last Name', value: volunteer.lastName),
                                if (volunteer.nickname != null && volunteer.nickname!.isNotEmpty)
                                  InfoRow(label: 'Nickname', value: volunteer.nickname!),
                                InfoRow(label: 'Age', value: volunteer.age.toString()),
                                InfoRow(label: 'Email', value: volunteer.email),
                                InfoRow(label: 'Contact', value: volunteer.contactNumber),
                                InfoRow(label: 'Type', value: volunteer.volunteerType),
                                InfoRow(label: 'Department', value: volunteer.department),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // QR Code Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(
                        color: Color.fromARGB(255, 0, 0, 0),
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'QR Code',
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 18
                            ),
                          ),
                          const Divider(),
                          Center(
                            child: QrImageView(
                              data: volunteer.uuid,
                              size: 200,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Helper widget for label-value pairs
class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
              width: 110,
              child: Text(
                '$label:',
                style: const TextStyle(fontWeight: FontWeight.w600),
              )),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
