import 'package:flutter/material.dart';
import 'package:volopsip/models/event_assignment.dart';
import 'package:volopsip/models/events.dart';
import 'package:volopsip/models/volunteer.dart';
import 'package:volopsip/repo/events_repo.dart';
import 'package:volopsip/helpers/events_page/additional_volunteers_to_event.dart';

class EventDetailsModal extends StatefulWidget {
  final Event event;
  final List<EventAssignment> assignments;
  final List<Volunteer> volunteers;
  final Future<void> Function()? onUpdated; // optional callback after changes

  const EventDetailsModal({
    super.key,
    required this.event,
    required this.assignments,
    required this.volunteers,
    this.onUpdated,
  });

  @override
  State<EventDetailsModal> createState() => _EventDetailsModalState();
}

class _EventDetailsModalState extends State<EventDetailsModal> {
  bool editMode = false; // toggle edit mode
  Set<int> selectedVolunteerIds = {}; // store selected volunteer IDs
  late Map<String, List<EventAssignment>> attributeAssignments;

  @override
  void initState() {
    super.initState();
    _groupAssignments();
  }

  void _groupAssignments() {
    attributeAssignments = {
      for (var attr in widget.event.attributes) attr: []
    };
    attributeAssignments.putIfAbsent('Unassigned', () => []);

    for (var a in widget.assignments) {
      final attr = a.attribute.isNotEmpty ? a.attribute : 'Unassigned';
      attributeAssignments[attr]!.add(a);
    }
  }

  String _getVolunteerName(int id) {
    try {
      final v = widget.volunteers.firstWhere((v) => v.id == id);
      return '${v.firstName} ${v.lastName}';
    } catch (_) {
      return 'Unknown';
    }
  }

  void _toggleVolunteerSelection(int id) {
    setState(() {
      if (selectedVolunteerIds.contains(id)) {
        selectedVolunteerIds.remove(id);
      } else {
        selectedVolunteerIds.add(id);
      }
    });
  }

  Future<void> _moveSelectedVolunteers(String targetAttribute) async {
    // Update in database here

    final attributeToSet = targetAttribute == 'Unassigned' ? '' : targetAttribute;

    // Get the assignment IDs of selected volunteers
    final assignmentIds = widget.assignments
        .where((a) => selectedVolunteerIds.contains(a.volunteerId))
        .map((a) => a.id!)
        .toList();

    // Persist in database
    await EventRepository().updateAssignmentsAttributes(assignmentIds, attributeToSet);

    // For now, we update the local state
    setState(() {
      for (var assignments in attributeAssignments.values) {
        for (var a in assignments) {
          if (selectedVolunteerIds.contains(a.volunteerId)) {
            a.attribute = targetAttribute == 'Unassigned' ? '' : targetAttribute;
          }
        }
      }
      selectedVolunteerIds.clear();
      _groupAssignments(); // regroup
      editMode = false;
    });

    // Optionally notify parent to refresh
    if (widget.onUpdated != null) {
      await widget.onUpdated!();
    }
  }

  @override
  Widget build(BuildContext context) {
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
            leading: const Icon(Icons.assignment),
            title: Text(
              widget.event.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min, // important so the row doesn't take full width
              children: [
                // --- Add Volunteers icon ---
                IconButton(
                  icon: const Icon(Icons.person_add_alt_1, color: Colors.green),
                  onPressed: () async {
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => AddVolunteersToEventModal(
                        eventId: widget.event.id!,
                        allVolunteers: widget.volunteers,
                        currentAssignments: widget.assignments,
                        onAdded: () async {
                          // Refresh assignments in this modal after adding
                          final updatedAssignments =
                              await EventRepository().getAllEventAssignments();

                          widget.assignments.clear();
                          widget.assignments.addAll(
                              updatedAssignments
                                  .where((a) => a.eventId == widget.event.id));

                          _groupAssignments();
                          setState(() {}); // refresh UI

                          // Notify parent to refresh numbers in EventList
                          if (widget.onUpdated != null) await widget.onUpdated!();
                        },
                      ),
                    );
                  },
                ),

                // --- Edit/Close icon ---
                IconButton(
                  icon: Icon(editMode ? Icons.close : Icons.edit),
                  onPressed: () {
                    setState(() {
                      editMode = !editMode;
                      if (!editMode) selectedVolunteerIds.clear();
                    });
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          // Show attributes and volunteers
          ...attributeAssignments.entries.map((entry) {
            final attr = entry.key;
            final assignments = entry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(
                    attr,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: editMode
                      ? IconButton(
                          icon: const Icon(Icons.drive_file_move,
                              color: Colors.blue),
                          onPressed: selectedVolunteerIds.isEmpty
                              ? null
                              : () => _moveSelectedVolunteers(attr),
                        )
                      : null,
                ),
                ...assignments.map((a) {
                  final selected = selectedVolunteerIds.contains(a.volunteerId);
                  return Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: ListTile(
                      leading: editMode
                          ? Checkbox(
                              value: selected,
                              onChanged: (_) =>
                                  _toggleVolunteerSelection(a.volunteerId),
                            )
                          : const Icon(Icons.person, size: 20),
                      title: Text(_getVolunteerName(a.volunteerId)),
                      dense: true,
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                }),
                const Divider(),
              ],
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
