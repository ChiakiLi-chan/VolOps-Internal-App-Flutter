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
        child: Align(
          alignment: Alignment.topLeft, // <-- align to top-left
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // <-- left-align content
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top row: title + icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${volunteer.lastName}, ${volunteer.firstName}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(isEditing ? Icons.close : Icons.edit),
                        onPressed: () {
                          setState(() => isEditing = !isEditing);
                        },
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [                    
                    VolunteerInfoView(volunteer: volunteer),

                    Center(
                      child: QrImageView(
                        data: volunteer.uuid, 
                        size: 180,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Displays volunteer info (read-only)
class VolunteerInfoView extends StatelessWidget {
  final Volunteer volunteer;
  const VolunteerInfoView({super.key, required this.volunteer});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('First Name: ${volunteer.firstName}'),
        Text('Last Name: ${volunteer.lastName}'),
        if (volunteer.nickname != null && volunteer.nickname!.isNotEmpty)
          Text('Nickname: ${volunteer.nickname}'),
        Text('Age: ${volunteer.age}'),
        Text('Email: ${volunteer.email}'),
        Text('Contact: ${volunteer.contactNumber}'),
        Text('Type: ${volunteer.volunteerType}'),
        Text('Department: ${volunteer.department}'),
      ],
    );
  }
}
