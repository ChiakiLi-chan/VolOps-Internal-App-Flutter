import 'package:flutter/material.dart';
import 'package:volopsip/models/events.dart';
import 'package:volopsip/models/event_assignment.dart';
import 'package:volopsip/repo/events_repo.dart';
import 'package:volopsip/modal/add_event.dart';
import 'package:volopsip/helpers/events_page/list_event.dart';
import 'package:volopsip/models/volunteer.dart';
import 'package:volopsip/helpers/listeners/event_notifier.dart';
import 'package:volopsip/repo/volunteer_repo.dart';
import 'package:volopsip/helpers/events_page/events_details.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final EventRepository _repo = EventRepository();
  final VolunteerRepository _volRepo = VolunteerRepository();
  List<Volunteer> allVolunteers = [];
  List<Event> events = [];
  Map<int, List<EventAssignment>> volunteerAssignmentsByEvent = {};

  final Set<int> _selectedEventIds = {};
  bool get _isSelectionMode => _selectedEventIds.isNotEmpty;

  @override
  void initState() {
    super.initState();
    fetchVolunteers();
    fetchEventsAndAssignments();

    // Listen to global notifier
    volunteerEventNotifier.addListener(_onVolunteerEventUpdated);
  }

  @override
  void dispose() {
    volunteerEventNotifier.removeListener(_onVolunteerEventUpdated);
    super.dispose();
  }

  void _onVolunteerEventUpdated() {
    fetchEventsAndAssignments(); // refresh page whenever an assignment changes
  }


  Future<void> fetchVolunteers() async {
    final volunteersData = await _volRepo.getAllVolunteers();
    setState(() {
      allVolunteers = volunteersData;
    });
  }

  /// Fetch all events and their volunteer assignments
  Future<void> fetchEventsAndAssignments() async {
    final eventsData = await _repo.getAllEvents();
    final assignments = await _repo.getAllEventAssignments();

    final Map<int, List<EventAssignment>> assignmentsByEvent = {};
    for (var assignment in assignments) {
      assignmentsByEvent.putIfAbsent(assignment.eventId, () => []);
      assignmentsByEvent[assignment.eventId]!.add(assignment);
    }

    setState(() {
      events = eventsData;
      volunteerAssignmentsByEvent = assignmentsByEvent;
    });
  }

  void _toggleSelection(Event event) {
    setState(() {
      if (_selectedEventIds.contains(event.id)) {
        _selectedEventIds.remove(event.id);
      } else {
        _selectedEventIds.add(event.id!);
      }
    });
  }

  Future<void> _deleteSelectedEvents() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Events'),
        content: Text(
          'Delete ${_selectedEventIds.length} selected events?\n\n'
          'All assignments under these events will also be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    for (final id in _selectedEventIds) {
      await _repo.deleteEvent(id);
    }

    setState(() => _selectedEventIds.clear());
    fetchEventsAndAssignments();
  }

  /// Open bottom sheet to add a new event
  void _showAddEventModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddEventModal(onEventAdded: fetchEventsAndAssignments),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isSelectionMode
              ? '${_selectedEventIds.length} selected'
              : 'Events',
        ),
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() => _selectedEventIds.clear());
                },
              )
            : null,
        actions: _isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _deleteSelectedEvents,
                ),
              ]
            : [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _showAddEventModal,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Event'),
                ),
              ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: EventList(
          events: events,
          volunteerAssignmentsByEvent: volunteerAssignmentsByEvent,
          allVolunteers: allVolunteers,
          selectedEventIds: _selectedEventIds,

          // ✅ TAP
          onTapEvent: (event) {
            if (_isSelectionMode) {
              _toggleSelection(event);
            }
            // 🔑 Defer dialog opening to next frame
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                builder: (_) => Dialog(
                  insetPadding: const EdgeInsets.all(20),
                  child: EventDetailsModal(
                    event: event,
                    assignments: volunteerAssignmentsByEvent[event.id!] ?? [],
                    volunteers: allVolunteers,
                    onUpdated: fetchEventsAndAssignments,
                  ),
                ),
              );
            });
          },

          // ✅ LONG PRESS (THIS WAS MISSING)
          onLongPressEvent: _toggleSelection,
        ),
      ),
    );
  }
}
