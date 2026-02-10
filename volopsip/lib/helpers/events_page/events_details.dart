import 'package:flutter/material.dart';
import 'package:volopsip/models/event_assignment.dart';
import 'package:volopsip/models/events.dart';
import 'package:volopsip/models/volunteer.dart';
import 'package:volopsip/repo/volunteer_repo.dart';
import 'package:volopsip/repo/events_repo.dart';
import 'package:volopsip/helpers/events_page/additional_volunteers_to_event.dart';
import 'package:volopsip/helpers/qr_connection/persistent_ws_server.dart';
import 'package:volopsip/modal/event_scanning.dart';
class EventDetailsModal extends StatefulWidget {
  final Event event;
  final List<EventAssignment> assignments;
  final List<Volunteer> volunteers; // may be empty
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
  List<Volunteer> allVolunteers = []; // will always contain volunteers for lookup

  @override
  void initState() {
    super.initState();

    // DEBUG: print incoming volunteers
    debugPrint('EventDetailsModal initState: widget.volunteers.length = ${widget.volunteers.length}');
    debugPrint('Volunteer IDs: ${widget.volunteers.map((v) => v.id).toList()}');

    // If widget.volunteers is empty, load all from repo
    if (widget.volunteers.isEmpty) {
      _loadAllVolunteers();
    } else {
      allVolunteers = widget.volunteers;
    }

    _groupAssignments();
  }

  Future<void> _loadAllVolunteers() async {
    allVolunteers = await VolunteerRepository().getAllVolunteers();
    debugPrint('Loaded all volunteers from repository: count = ${allVolunteers.length}');
    debugPrint('Volunteer IDs: ${allVolunteers.map((v) => v.id).toList()}');
    setState(() {}); // rebuild UI with loaded volunteers
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
    debugPrint('Looking for volunteer with ID: $id');
    debugPrint('Current allVolunteers count: ${allVolunteers.length}');
    debugPrint('Volunteer IDs: ${allVolunteers.map((v) => v.id).toList()}');

    try {
      final v = allVolunteers.firstWhere((v) => v.id == id);
      return '${v.firstName} ${v.lastName}';
    } catch (_) {
      return 'id is $id (not found)';
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
    final attributeToSet = targetAttribute == 'Unassigned' ? '' : targetAttribute;

    final assignmentIds = widget.assignments
        .where((a) => selectedVolunteerIds.contains(a.volunteerId))
        .map((a) => a.id!)
        .toList();

    await EventRepository().updateAssignmentsAttributes(assignmentIds, attributeToSet);

    setState(() {
      for (var assignments in attributeAssignments.values) {
        for (var a in assignments) {
          if (selectedVolunteerIds.contains(a.volunteerId)) {
            a.attribute = attributeToSet;
          }
        }
      }
      selectedVolunteerIds.clear();
      _groupAssignments();
      editMode = false;
    });

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
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.person_add_alt_1, color: Colors.green),
                  onPressed: () async {
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => AddVolunteersToEventModal(
                        eventId: widget.event.id!,
                        allVolunteers: allVolunteers,
                        currentAssignments: widget.assignments,
                        onAdded: () async {
                          final updatedAssignments =
                              await EventRepository().getAllEventAssignments();
                          widget.assignments.clear();
                          widget.assignments.addAll(
                              updatedAssignments.where((a) => a.eventId == widget.event.id));

                          _groupAssignments();
                          setState(() {});

                          if (widget.onUpdated != null) await widget.onUpdated!();
                        },
                      ),
                    );
                  },
                ),
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
          // Attributes & Volunteers
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Scan button (always visible)
                      IconButton(
                        icon: const Icon(Icons.qr_code_scanner),
                        tooltip: 'Scan QR',
                        onPressed: () async {
                          PersistentWebSocketServer().sendToPhone(
                            'ES-${widget.event.id}-$attr-${widget.event.name}',
                          );

                          // Open scanning dialog
                          await eventScanning(
                            context: context,
                            attribute: attr,
                            eventName: widget.event.name,
                          );

                          // Fetch updated assignments for this event (just like manual move)
                          final updatedAssignments = await EventRepository().getAllEventAssignments();
                          widget.assignments.clear();
                          widget.assignments.addAll(
                              updatedAssignments.where((a) => a.eventId == widget.event.id));

                          // Re-group by attributes
                          _groupAssignments();

                          // Rebuild this parent UI
                          setState(() {});

                          // Also notify grandparent to refresh
                          if (widget.onUpdated != null) {
                            await widget.onUpdated!();
                          }
                        },
                      ),

                      // Move button (edit mode only)
                      if (editMode)
                        IconButton(
                          icon: const Icon(Icons.drive_file_move, color: Colors.blue),
                          onPressed: selectedVolunteerIds.isEmpty
                              ? null
                              : () => _moveSelectedVolunteers(attr),
                        ),
                    ],
                  ),
                ),
                ...assignments.map((a) {
                  final selected = selectedVolunteerIds.contains(a.volunteerId);
                  return Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: ListTile(
                      leading: editMode
                          ? Checkbox(
                              value: selected,
                              onChanged: (_) => _toggleVolunteerSelection(a.volunteerId),
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
