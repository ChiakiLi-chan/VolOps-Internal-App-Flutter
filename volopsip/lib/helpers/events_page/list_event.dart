import 'package:flutter/material.dart';
import '../../models/events.dart';
import '../../models/event_assignment.dart';
import 'package:volopsip/helpers/events_page/events_details.dart'; // import modal
import 'package:volopsip/models/volunteer.dart';

class EventList extends StatelessWidget {
  final List<Event> events;
  final Map<int, List<EventAssignment>> volunteerAssignmentsByEvent;
  final List<Volunteer> allVolunteers; 
  final Future<void> Function()? onUpdated;

  const EventList({
    super.key,
    required this.events,
    required this.volunteerAssignmentsByEvent,
    required this.allVolunteers,
    this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Center(
        child: Text('No events yet. Tap "Add Event" to create one.'),
      );
    }

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (_, index) {
        final event = events[index];
        final eventAssignments =
            volunteerAssignmentsByEvent[event.id!] ?? [];

        // Count attributes including Unassigned
        final attributeCounts = {for (var attr in event.attributes) attr: 0};
        if (!attributeCounts.containsKey('Unassigned')) {
          attributeCounts['Unassigned'] = 0;
        }
        for (var assignment in eventAssignments) {
          final attr =
              assignment.attribute.isNotEmpty ? assignment.attribute : 'Unassigned';
          attributeCounts[attr] = (attributeCounts[attr] ?? 0) + 1;
        }

        final subtitleText = attributeCounts.entries
            .map((e) => '${e.key}: ${e.value}')
            .join(' | ');

        return Card(
          child: ListTile(
            leading: const Icon(Icons.assignment),
            title: Text(event.name),
            subtitle: Text(subtitleText),
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => EventDetailsModal(
                  event: event,
                  assignments: eventAssignments,
                  volunteers: allVolunteers,
                  onUpdated: onUpdated,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
