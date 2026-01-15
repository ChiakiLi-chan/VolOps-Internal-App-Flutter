import 'package:flutter/material.dart';
import 'package:volopsip/models/volunteer.dart';
import 'package:volopsip/models/event_assignment.dart';
import 'package:volopsip/repo/events_repo.dart';

class AddVolunteersToEventModal extends StatefulWidget {
  final int eventId;
  final List<Volunteer> allVolunteers; // all volunteers in system
  final List<EventAssignment> currentAssignments; // volunteers already in event
  final VoidCallback? onAdded; // callback after adding

  const AddVolunteersToEventModal({
    super.key,
    required this.eventId,
    required this.allVolunteers,
    required this.currentAssignments,
    this.onAdded,
  });

  @override
  State<AddVolunteersToEventModal> createState() =>
      _AddVolunteersToEventModalState();
}

class _AddVolunteersToEventModalState extends State<AddVolunteersToEventModal> {
  Set<int> selectedVolunteerIds = {};

  @override
  Widget build(BuildContext context) {
    // filter volunteers not already assigned
    final availableVolunteers = widget.allVolunteers
        .where((v) => !widget.currentAssignments
            .any((a) => a.volunteerId == v.id))
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text(
              "Add Volunteers",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Divider(),
          ...availableVolunteers.map((v) {
            final selected = selectedVolunteerIds.contains(v.id);
            return CheckboxListTile(
              title: Text('${v.firstName} ${v.lastName}'),
              value: selected,
              onChanged: (_) {
                setState(() {
                  if (selected) {
                    selectedVolunteerIds.remove(v.id);
                  } else {
                    selectedVolunteerIds.add(v.id!);
                  }
                });
              },
            );
          }).toList(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: selectedVolunteerIds.isEmpty
                    ? null
                    : () async {
                        // Add selected volunteers to the event
                        await EventRepository().addVolunteersToEvent(
                            widget.eventId, selectedVolunteerIds.toList());

                        if (widget.onAdded != null) widget.onAdded!();

                        Navigator.pop(context);
                      },
                child: const Text("Add Selected"),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
