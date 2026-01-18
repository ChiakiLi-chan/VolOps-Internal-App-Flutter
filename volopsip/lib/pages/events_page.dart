import 'package:flutter/material.dart';
import 'package:volopsip/models/events.dart';
import 'package:volopsip/models/event_assignment.dart';
import 'package:volopsip/repo/events_repo.dart';
import 'package:volopsip/modal/add_event.dart';
import 'package:volopsip/helpers/events_page/list_event.dart';
import 'package:volopsip/models/volunteer.dart';
import 'package:volopsip/helpers/listeners/event_notifier.dart';
import 'package:volopsip/repo/volunteer_repo.dart';

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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Add Event button
          Row(
            children: [
              const Spacer(),
              ElevatedButton(
                onPressed: _showAddEventModal,
                child: const Text('Add Event'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Use the new helper widget for the event list
          Expanded(
            child: EventList(
              events: events,
              volunteerAssignmentsByEvent: volunteerAssignmentsByEvent,
              allVolunteers: allVolunteers,
              onUpdated: fetchEventsAndAssignments,
            ),
          ),
        ],
      ),
    );
  }
}
