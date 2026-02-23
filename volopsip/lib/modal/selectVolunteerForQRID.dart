import 'package:flutter/material.dart';
import '../models/volunteer.dart';
import '../helpers/pdf/VolunteerQrpdfExport.dart';

class VolunteerQrExportFilterModal extends StatefulWidget {
  final List<Volunteer> volunteers;

  const VolunteerQrExportFilterModal({super.key, required this.volunteers});

  @override
  State<VolunteerQrExportFilterModal> createState() =>
      _VolunteerQrExportFilterModalState();
}

class _VolunteerQrExportFilterModalState
    extends State<VolunteerQrExportFilterModal> {
  Set<String> selectedCores = {};
  Set<String> selectedDepartments = {};
  Set<int> selectedVolunteerIds = {};

  @override
  Widget build(BuildContext context) {
    // Unique cores & departments
    final allCores =
        widget.volunteers.map((v) => v.volunteerType).toSet().toList();
    final allDepartments =
        widget.volunteers.map((v) => v.department).toSet().toList();

    // Filter volunteers based on chips selection
    final filtered = widget.volunteers.where((v) {
      final coreMatch =
          selectedCores.isEmpty || selectedCores.contains(v.volunteerType);
      final deptMatch =
          selectedDepartments.isEmpty || selectedDepartments.contains(v.department);
      return coreMatch && deptMatch;
    }).toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- Header ---
          ListTile(
            leading: const Icon(Icons.qr_code),
            title: const Text(
              "QR Export Filters",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Divider(),

          // --- Filter Chips ---
          Align(
            alignment: Alignment.centerLeft,
            child: const Text("Core / Volunteer Type",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Wrap(
            spacing: 8,
            children: allCores
                .map(
                  (core) => FilterChip(
                    label: Text(core),
                    selected: selectedCores.contains(core),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedCores.add(core);
                        } else {
                          selectedCores.remove(core);
                        }
                        // Deselect volunteers not matching the filter
                        selectedVolunteerIds.removeWhere(
                          (id) => !filtered.any((v) => v.id == id),
                        );
                      });
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),

          Align(
            alignment: Alignment.centerLeft,
            child: const Text("Department",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Wrap(
            spacing: 8,
            children: allDepartments
                .map(
                  (dept) => FilterChip(
                    label: Text(dept),
                    selected: selectedDepartments.contains(dept),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedDepartments.add(dept);
                        } else {
                          selectedDepartments.remove(dept);
                        }
                        // Deselect volunteers not matching the filter
                        selectedVolunteerIds.removeWhere(
                          (id) => !filtered.any((v) => v.id == id),
                        );
                      });
                    },
                  ),
                )
                .toList(),
          ),
          const Divider(),

          // --- Scrollable Volunteer List with Checkboxes ---
          SizedBox(
            height: 300, // adjust for screen size
            child: filtered.isEmpty
                ? const Center(child: Text("No volunteers match selected filters"))
                : Scrollbar(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final v = filtered[index];
                        final isSelected = selectedVolunteerIds.contains(v.id);
                        return CheckboxListTile(
                          value: isSelected,
                          title: Text("${v.lastName}, ${v.firstName}"),
                          subtitle: Text("${v.volunteerType} | ${v.department}"),
                          onChanged: (_) {
                            setState(() {
                              if (isSelected) {
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
          ),
          const SizedBox(height: 16),

          // --- Action Buttons ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    // Select all visible volunteers
                    selectedVolunteerIds
                        .addAll(filtered.map((v) => v.id!).toList());
                  });
                },
                child: const Text("Select All"),
              ),
              ElevatedButton(
                onPressed: selectedVolunteerIds.isEmpty
                    ? null
                    : () async {
                        // Only export selected volunteers
                        final toExport = filtered
                            .where((v) => selectedVolunteerIds.contains(v.id))
                            .toList();
                        await VolunteerQrPdfExport.export(toExport);
                        Navigator.pop(context);
                      },
                child: const Text("Export QR PDF"),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}