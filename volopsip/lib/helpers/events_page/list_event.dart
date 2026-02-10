import 'package:flutter/material.dart';
import '../../models/events.dart';
import '../../models/event_assignment.dart';
import 'package:volopsip/helpers/events_page/events_details.dart'; // import modal
import 'package:volopsip/models/volunteer.dart';
import 'package:volopsip/helpers/pdf/event_pdf.dart';
import 'package:volopsip/modal/event_pdf_filter_modal.dart';
import 'package:volopsip/helpers/pdf/event_pdf_filter.dart';



class EventList extends StatelessWidget {
  final List<Event> events;
  final Map<int, List<EventAssignment>> volunteerAssignmentsByEvent;
  final List<Volunteer> allVolunteers; 
  final Future<void> Function()? onUpdated;

  final Set<int> selectedEventIds;
  final void Function(Event event)? onTapEvent;
  final void Function(Event event)? onLongPressEvent;

  const EventList({
    super.key,
    required this.events,
    required this.volunteerAssignmentsByEvent,
    required this.allVolunteers,
    required this.selectedEventIds,
    this.onTapEvent,
    this.onLongPressEvent,
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
        
        final isSelected = selectedEventIds.contains(event.id);

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
          color: isSelected ? Colors.blue.withOpacity(0.15) : null,
          child: ListTile(
            leading: isSelected
                ? const Icon(Icons.check_circle, color: Colors.blue)
                : const Icon(Icons.assignment),
            title: Text(event.name),
            subtitle: Text(subtitleText),
            trailing: isSelected
                ? null
                : IconButton(
                    icon: const Icon(Icons.picture_as_pdf),
                    tooltip: 'Export PDF',
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => EventPdfFilterModal(
                          initialFilter: const EventPdfFilter(),
                          onApply: (filter) async {
                            await EventPdfExporter.export(
                              event: event,
                              assignments: eventAssignments,
                              filter: filter,
                            );
                          },
                        ),
                      );
                    },
                  ),
            onTap: () {
              if (onTapEvent != null) {
                onTapEvent!(event);
                return;
              }

              showDialog(
                context: context,
                builder: (_) => Dialog(
                  insetPadding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight:
                          MediaQuery.of(context).size.height * 0.8,
                      maxWidth: 500,
                    ),
                    child: SingleChildScrollView(
                      child: EventDetailsModal(
                        event: event,
                        assignments: eventAssignments,
                        volunteers: allVolunteers,
                        onUpdated: onUpdated,
                      ),
                    ),
                  ),
                ),
              );
            },
            onLongPress: onLongPressEvent != null
                ? () => onLongPressEvent!(event)
                : null,
          ),
        );
      },
    );
  }
}