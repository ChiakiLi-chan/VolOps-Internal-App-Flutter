import 'package:flutter/material.dart';

/// Simple model for displaying volunteers in the dialog
class VolunteerOption {
  final int id;
  final String name;

  VolunteerOption({required this.id, required this.name});
}

/// Shows a multi-select dialog of volunteers
/// Returns a list of selected volunteer IDs
Future<List<int>> showVolunteerSelector(
  BuildContext context, {
  required List<VolunteerOption> volunteers,
  List<int>? initiallySelected,
}) async {
  final selectedIds = initiallySelected != null ? List<int>.from(initiallySelected) : <int>[];

  return showDialog<List<int>>(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text('Select Volunteers'),
        content: SizedBox(
          width: double.maxFinite,
          child: StatefulBuilder(
            builder: (context, setState) {
              bool allSelected = selectedIds.length == volunteers.length;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- Select All Checkbox ---
                  CheckboxListTile(
                    value: allSelected,
                    title: const Text('Select All'),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          selectedIds.clear();
                          selectedIds.addAll(volunteers.map((v) => v.id));
                        } else {
                          selectedIds.clear();
                        }
                      });
                    },
                  ),
                  const Divider(),
                  // --- Individual Volunteers ---
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: volunteers.length,
                      itemBuilder: (_, index) {
                        final vol = volunteers[index];
                        final isSelected = selectedIds.contains(vol.id);

                        return CheckboxListTile(
                          value: isSelected,
                          title: Text(vol.name),
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                selectedIds.add(vol.id);
                              } else {
                                selectedIds.remove(vol.id);
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
            onPressed: () => Navigator.pop(context, <int>[]), // cancel, return empty
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
