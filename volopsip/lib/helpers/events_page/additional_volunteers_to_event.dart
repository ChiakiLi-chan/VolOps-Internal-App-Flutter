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
  Set<String> selectedTypes = {};
  Set<String> selectedDepartments = {};

  @override
  Widget build(BuildContext context) {
    // Filter out volunteers already assigned
    var availableVolunteers = widget.allVolunteers
        .where((v) =>
            !widget.currentAssignments.any((a) => a.volunteerId == v.id))
        .toList();

    // Apply type & department filters
    if (selectedTypes.isNotEmpty) {
      availableVolunteers = availableVolunteers
          .where((v) => selectedTypes.contains(v.volunteerType))
          .toList();
    }
    if (selectedDepartments.isNotEmpty) {
      availableVolunteers = availableVolunteers
          .where((v) => selectedDepartments.contains(v.department))
          .toList();
    }

    // Get all unique types and departments for filter chips
    final allTypes =
        widget.allVolunteers.map((v) => v.volunteerType).toSet().toList();
    final allDepartments =
        widget.allVolunteers.map((v) => v.department).toSet().toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
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

              // --- Filter Chips ---
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Text("Core/Volunteer Type",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  )),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: allTypes.map((type) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(type),
                        selected: selectedTypes.contains(type),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedTypes.add(type);
                            } else {
                              selectedTypes.remove(type);
                            }
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),

              const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Text("Department",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  )),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: allDepartments.map((dept) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(dept),
                        selected: selectedDepartments.contains(dept),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedDepartments.add(dept);
                            } else {
                              selectedDepartments.remove(dept);
                            }
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Divider(),

              // --- Select/Deselect All Filtered ---
              if (availableVolunteers.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton.icon(
                    icon: Icon(
                      selectedVolunteerIds.containsAll(
                              availableVolunteers.map((v) => v.id!))
                          ? Icons.remove_done
                          : Icons.select_all,
                    ),
                    label: Text(
                      selectedVolunteerIds.containsAll(
                              availableVolunteers.map((v) => v.id!))
                          ? 'Deselect All Filtered'
                          : 'Select All Filtered',
                    ),
                    onPressed: () {
                      setState(() {
                        final allFilteredIds =
                            availableVolunteers.map((v) => v.id!).toList();
                        if (selectedVolunteerIds
                            .containsAll(allFilteredIds)) {
                          selectedVolunteerIds.removeAll(allFilteredIds);
                        } else {
                          selectedVolunteerIds.addAll(allFilteredIds);
                        }
                      });
                    },
                  ),
                ),

              // --- Volunteer Checkboxes ---
              SizedBox(
                height: 400, // fixed height for scrollable list
                child: availableVolunteers.isEmpty
                    ? const Center(
                        child: Text("No volunteers available with current filters"))
                    : ListView.builder(
                        itemCount: availableVolunteers.length,
                        itemBuilder: (context, index) {
                          final v = availableVolunteers[index];
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
                        },
                      ),
              ),

              const SizedBox(height: 16),

              // Add Selected Button
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
        ),
      ),
    );
  }
}