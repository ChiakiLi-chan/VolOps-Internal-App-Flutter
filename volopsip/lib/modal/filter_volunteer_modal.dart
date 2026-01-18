import 'package:flutter/material.dart';

class FilterVolunteerModal extends StatefulWidget {
  final String? selectedVolunteerType;
  final Set<String> selectedDepartments;
  final List<String> departments;
  final void Function({
    String? volunteerType,
    Set<String>? departments,
  }) onApply;

  const FilterVolunteerModal({
    super.key,
    required this.selectedVolunteerType,
    required this.selectedDepartments,
    required this.departments,
    required this.onApply,
  });

  @override
  State<FilterVolunteerModal> createState() => _FilterVolunteerModalState();
}

class _FilterVolunteerModalState extends State<FilterVolunteerModal> {
  String? _volunteerType;
  late Set<String> _departments;

  @override
  void initState() {
    super.initState();
    _volunteerType = widget.selectedVolunteerType;
    _departments = {...widget.selectedDepartments};
  }

  Widget _buildVolunteerTypeColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Volunteer Type',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        CheckboxListTile(
          title: const Text('Core'),
          value: _volunteerType == 'Core',
          onChanged: (checked) {
            setState(() {
              _volunteerType = checked == true ? 'Core' : null;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
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
          controlAffinity: ListTileControlAffinity.leading,
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
          'Department',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        ...widget.departments.map(
          (dept) => CheckboxListTile(
            title: Text(dept),
            value: _departments.contains(dept),
            onChanged: (checked) {
              setState(() {
                if (checked == true) {
                  _departments.add(dept);
                } else {
                  _departments.remove(dept);
                }
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filter Volunteers',
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
                      widget.onApply(
                        volunteerType: null,
                        departments: {},
                      );
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
                        volunteerType: _volunteerType,
                        departments: _departments,
                      );
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
