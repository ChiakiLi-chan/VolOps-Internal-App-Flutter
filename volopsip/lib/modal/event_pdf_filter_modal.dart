import 'package:flutter/material.dart';
import '../helpers/pdf/event_pdf_filter.dart';
import '../helpers/pdf/event_pdf_sort.dart';

class EventPdfFilterModal extends StatefulWidget {
  final EventPdfFilter initialFilter;
  final void Function(EventPdfFilter filter) onApply;
  final List<String> eventAttributes; // ✅ NEW

  const EventPdfFilterModal({
    super.key,
    required this.initialFilter,
    required this.eventAttributes, // ✅ NEW
    required this.onApply,
  });

  @override
  State<EventPdfFilterModal> createState() => _EventPdfFilterModalState();
}

class _EventPdfFilterModalState extends State<EventPdfFilterModal> {
  String? _volunteerType;
  late Set<String> _departments;
  late EventPdfSortType _sortType;
  late Set<String> _attributes;

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
    _sortType = widget.initialFilter.sortType;
    _attributes = {...widget.initialFilter.attributes};
  }

  Widget _buildAttributeColumn() {
  if (widget.eventAttributes.isEmpty) {
    return const SizedBox();
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Event Status',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      ...widget.eventAttributes.map(
        (attr) => CheckboxListTile(
          title: Text(attr),
          value: _attributes.contains(attr),
          onChanged: (v) {
            setState(() {
              v == true ? _attributes.add(attr) : _attributes.remove(attr);
            });
          },
          dense: true,
        ),
      ),
    ],
  );
}

  Widget _buildVolunteerTypeColumn() {
    if (widget.eventAttributes.isEmpty) {
    return const SizedBox();
  }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Volunteer Type',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        CheckboxListTile(
          title: const Text('Core'),
          value: _volunteerType == 'Core',
          onChanged: (v) =>
              setState(() => _volunteerType = v == true ? 'Core' : null),
          dense: true,
        ),
        CheckboxListTile(
          title: const Text('OTD'),
          value: _volunteerType == 'OTD',
          onChanged: (v) =>
              setState(() => _volunteerType = v == true ? 'OTD' : null),
          dense: true,
        ),
      ],
    );
  }

  Widget _buildDepartmentColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Departments',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ..._allDepartments.map(
          (dept) => CheckboxListTile(
            title: Text(dept),
            value: _departments.contains(dept),
            onChanged: (v) => setState(() =>
                v == true ? _departments.add(dept) : _departments.remove(dept)),
            dense: true,
          ),
        ),
      ],
    );
  }

  Widget _buildSortSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sort By',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        RadioListTile(
          title: const Text('Alphabetical'),
          value: EventPdfSortType.alphabetical,
          groupValue: _sortType,
          onChanged: (v) => setState(() => _sortType = v!),
        ),
        RadioListTile(
          title: const Text('Status'),
          value: EventPdfSortType.status,
          groupValue: _sortType,
          onChanged: (v) => setState(() => _sortType = v!),
        ),
        RadioListTile(
          title: const Text('Department'),
          value: EventPdfSortType.department,
          groupValue: _sortType,
          onChanged: (v) => setState(() => _sortType = v!),
        ),
        RadioListTile(
          title: const Text('Volunteer Type'),
          value: EventPdfSortType.volunteerType,
          groupValue: _sortType,
          onChanged: (v) => setState(() => _sortType = v!),
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
          children: [
            const Text('PDF Export Filters',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildVolunteerTypeColumn()),
                const SizedBox(width: 16),
                Expanded(child: _buildDepartmentColumn()),
                const SizedBox(height: 16),
                Expanded(child:_buildAttributeColumn()),
              ],
            ),

            const SizedBox(height: 16),
            _buildSortSection(),

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
                          attributes: _attributes, // ✅ NEW
                          sortType: _sortType,
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
