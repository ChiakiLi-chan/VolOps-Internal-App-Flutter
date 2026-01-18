import 'package:flutter/material.dart';
import '../helpers/pdf/event_pdf_filter.dart';

class EventPdfFilterModal extends StatefulWidget {
  final EventPdfFilter initialFilter;
  final void Function(EventPdfFilter filter) onApply;

  const EventPdfFilterModal({
    super.key,
    required this.initialFilter,
    required this.onApply,
  });

  @override
  State<EventPdfFilterModal> createState() => _EventPdfFilterModalState();
}

class _EventPdfFilterModalState extends State<EventPdfFilterModal> {
  String? _volunteerType;
  late Set<String> _departments;

  // ✅ FIXED department list
  static const List<String> _allDepartments = [
    'Finance',
    'Marketing',
    'Talents',
    'Production',
    'Logistics',
    'Security and Sanitation',
    'Volunteer Operations',
  ];

  @override
  void initState() {
    super.initState();
    _volunteerType = widget.initialFilter.volunteerType;
    _departments = {...widget.initialFilter.departments};
  }

  Widget _buildVolunteerTypeColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Volunteer Type',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        CheckboxListTile(
          title: const Text('Core'),
          value: _volunteerType == 'Core',
          onChanged: (checked) {
            setState(() {
              _volunteerType = checked == true ? 'Core' : null;
            });
          },
          dense: true,
        ),

        CheckboxListTile(
          title: const Text('OTD'),
          value: _volunteerType == 'OTD',
          onChanged: (checked) {
            setState(() {
              _volunteerType = checked == true ? 'OTD' : null;
            });
          },
          dense: true,
        ),
      ],
    );
  }

  Widget _buildDepartmentColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Departments',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        ..._allDepartments.map(
          (dept) => CheckboxListTile(
            title: Text(dept),
            value: _departments.contains(dept),
            onChanged: (checked) {
              setState(() {
                checked == true
                    ? _departments.add(dept)
                    : _departments.remove(dept);
              });
            },
            dense: true,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'PDF Export Filters',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildVolunteerTypeColumn()),
                const SizedBox(width: 16),
                Expanded(child: _buildDepartmentColumn()),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    child: const Text('Clear'),
                    onPressed: () {
                      widget.onApply(const EventPdfFilter());
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    child: const Text('Apply'),
                    onPressed: () {
                      widget.onApply(
                        EventPdfFilter(
                          volunteerType: _volunteerType,
                          departments: _departments,
                        ),
                      );
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
