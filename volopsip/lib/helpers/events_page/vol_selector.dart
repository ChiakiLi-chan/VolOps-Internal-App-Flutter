import 'package:flutter/material.dart';

class VolunteerOption {
  final int id;
  final String name;
  final String volunteerType;
  final String department;

  VolunteerOption({
    required this.id,
    required this.name,
    required this.volunteerType,
    required this.department,
  });
}

Future<List<int>> showVolunteerSelector(
  BuildContext context, {
  required List<VolunteerOption> volunteers,
  List<int>? initiallySelected,
}) async {
  final selectedIds = initiallySelected != null ? List<int>.from(initiallySelected) : <int>[];

  // Unique volunteer types and departments for filters
  final allTypes = volunteers.map((v) => v.volunteerType).toSet().toList();
  final allDepartments = volunteers.map((v) => v.department).toSet().toList();

  final selectedTypes = <String>{};
  final selectedDepartments = <String>{};

  return showDialog<List<int>>(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text('Select Volunteers'),
        content: SizedBox(
          width: double.maxFinite,
          height: 450,
          child: StatefulBuilder(
            builder: (context, setState) {
              // Filter volunteers based on currently selected filters
              final filteredVolunteers = volunteers.where((v) {
                final matchesType = selectedTypes.isEmpty || selectedTypes.contains(v.volunteerType);
                final matchesDept = selectedDepartments.isEmpty || selectedDepartments.contains(v.department);
                return matchesType && matchesDept;
              }).toList();

              // Check if all filtered volunteers are selected
              final allFilteredSelected = filteredVolunteers.every((v) => selectedIds.contains(v.id));

              return Column(
                children: [
                  // --- Volunteer Type Filters ---
                  Wrap(
                    spacing: 8,
                    children: allTypes.map((type) {
                      final isSelected = selectedTypes.contains(type);
                      return FilterChip(
                        label: Text(type),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedTypes.add(type);
                            } else {
                              selectedTypes.remove(type);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  // --- Department Filters ---
                  Wrap(
                    spacing: 8,
                    children: allDepartments.map((dep) {
                      final isSelected = selectedDepartments.contains(dep);
                      return FilterChip(
                        label: Text(dep),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedDepartments.add(dep);
                            } else {
                              selectedDepartments.remove(dep);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const Divider(),
                  // --- Select All Matching Filter Button ---
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      icon: Icon(allFilteredSelected ? Icons.remove_circle_outline : Icons.check_circle_outline),
                      label: Text(allFilteredSelected ? 'Unselect All Filtered' : 'Select All Filtered'),
                      onPressed: () {
                        setState(() {
                          if (allFilteredSelected) {
                            // Unselect all filtered
                            for (final v in filteredVolunteers) {
                              selectedIds.remove(v.id);
                            }
                          } else {
                            // Select all filtered
                            for (final v in filteredVolunteers) {
                              if (!selectedIds.contains(v.id)) selectedIds.add(v.id);
                            }
                          }
                        });
                      },
                    ),
                  ),
                  const Divider(),
                  // --- Volunteer List ---
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: volunteers.length,
                      itemBuilder: (_, index) {
                        final v = volunteers[index];
                        final isSelected = selectedIds.contains(v.id);

                        return CheckboxListTile(
                          value: isSelected,
                          title: Text('${v.name} (${v.volunteerType}, ${v.department})'),
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                selectedIds.add(v.id);
                              } else {
                                selectedIds.remove(v.id);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, <int>[]),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, selectedIds),
            child: const Text('Select'),
          ),
        ],
      );
    },
  ).then((value) => value ?? <int>[]);
}