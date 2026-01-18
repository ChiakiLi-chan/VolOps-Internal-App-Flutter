import 'package:flutter/material.dart';
import 'package:volopsip/models/volunteer.dart';
import 'package:volopsip/models/events.dart';
import 'package:volopsip/helpers/listeners/event_notifier.dart';
import 'package:volopsip/repo/events_repo.dart';

class ProfileAddVolunteerToEvent extends StatefulWidget {
  final Volunteer volunteer;

  const ProfileAddVolunteerToEvent({
    super.key,
    required this.volunteer,
  });

  @override
  State<ProfileAddVolunteerToEvent> createState() =>
      _ProfileAddVolunteerToEventState();
}
class _ProfileAddVolunteerToEventState
    extends State<ProfileAddVolunteerToEvent> {
  final EventRepository _eventRepo = EventRepository();

  final Set<int> _selectedEventIds = {};
  final Map<int, String> _selectedAttribute = {};

  late Future<List<Event>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = _loadEventsAndAssignments();
  }

  Future<List<Event>> _loadEventsAndAssignments() async {
    final events = await _eventRepo.getAllEvents();

    // Load existing assignments for this volunteer
    final assignments =
        await _eventRepo.getVolunteerEventAssignments(widget.volunteer.id!);

    // Pre-fill selections
    setState(() {
      _selectedEventIds.addAll(assignments.keys);
      _selectedAttribute.addAll(assignments);
    });

    return events;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Volunteer to Event'),
      content: SizedBox(
        width: 420,
        child: FutureBuilder<List<Event>>(
          future: _eventsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Text('Failed to load events');
            }

            final events = snapshot.data ?? [];

            return ListView(
              shrinkWrap: true,
              children: events.map((event) {
                final eventId = event.id!;
                final isSelected = _selectedEventIds.contains(eventId);
                final attributes = event.attributes;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event checkbox
                    CheckboxListTile(
                      title: Text(event.name),
                      value: isSelected,
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _selectedEventIds.add(eventId);
                          } else {
                            _selectedEventIds.remove(eventId);
                            _selectedAttribute.remove(eventId);
                          }
                        });
                      },
                    ),

                    // Attribute radio buttons
                    if (isSelected && attributes.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 32, bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: attributes.map((attr) {
                            return RadioListTile<String>(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(attr),
                              value: attr,
                              groupValue: _selectedAttribute[eventId],
                              onChanged: (value) {
                                setState(() {
                                  _selectedAttribute[eventId] = value!;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                );
              }).toList(),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final volunteerId = widget.volunteer.id!;
            final repo = EventRepository();

            // Fetch existing assignments
            final existingAssignments =
                await repo.getVolunteerEventAssignments(volunteerId);

            final toAdd = <int>[];
            final toRemove = <int>[];

            // Determine new/removed events
            _selectedEventIds.forEach((eventId) {
              if (!existingAssignments.containsKey(eventId)) toAdd.add(eventId);
            });
            existingAssignments.keys.forEach((eventId) {
              if (!_selectedEventIds.contains(eventId)) toRemove.add(eventId);
            });

            // Remove unselected
            for (var eventId in toRemove) {
              await repo.deleteAssignment(volunteerId, eventId);
            }

            // Add new assignments
            for (var eventId in toAdd) {
              final attr = _selectedAttribute[eventId] ?? '';
              await repo.addVolunteerToEventWithAttribute(volunteerId, eventId, attr);
            }

            // Update attributes for existing assignments
            for (var eventId in _selectedEventIds) {
              if (existingAssignments.containsKey(eventId)) {
                final newAttr = _selectedAttribute[eventId] ?? '';
                final oldAttr = existingAssignments[eventId] ?? '';
                if (newAttr != oldAttr) {
                  await repo.updateAssignmentAttributeForVolunteer(
                      volunteerId, eventId, newAttr);
                }
              }
            }

            // Notify all listeners across the app
            volunteerEventNotifier.updated();

            Navigator.pop(context);
          },
          child: const Text('Confirm'),
        ),

      ],


    );
  }
}
