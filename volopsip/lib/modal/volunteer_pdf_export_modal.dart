import 'package:flutter/material.dart';
import '../helpers/pdf/volunteer_pdf_columns.dart';
import '../helpers/pdf/volunteer_pdf_exporter.dart';
import '../models/volunteer.dart';

class VolunteerPdfExportModal extends StatefulWidget {
  final List<Volunteer> volunteers;
  final String? volunteerTypeFilter;
  final Set<String> departmentFilter;

  const VolunteerPdfExportModal({
    super.key,
    required this.volunteers,
    required this.volunteerTypeFilter,
    required this.departmentFilter,
  });

  @override
  State<VolunteerPdfExportModal> createState() =>
      _VolunteerPdfExportModalState();
}

class _VolunteerPdfExportModalState
    extends State<VolunteerPdfExportModal> {
  late Set<VolunteerPdfColumn> _selectedColumns;

  @override
  void initState() {
    super.initState();
    _selectedColumns = VolunteerPdfColumn.values.toSet();
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
              'Export Volunteer PDF',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            ...VolunteerPdfColumn.values.map(
              (col) => CheckboxListTile(
                title: Text(_label(col)),
                value: _selectedColumns.contains(col),
                onChanged: (checked) {
                  setState(() {
                    checked == true
                        ? _selectedColumns.add(col)
                        : _selectedColumns.remove(col);
                  });
                },
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    child: const Text('Export'),
                    onPressed: () async {
                      await VolunteerPdfExporter.export(
                        volunteers: widget.volunteers,
                        columns: _selectedColumns,
                        volunteerTypeFilter:
                            widget.volunteerTypeFilter,
                        departmentFilter:
                            widget.departmentFilter,
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

  String _label(VolunteerPdfColumn col) {
    switch (col) {
      case VolunteerPdfColumn.fullName:
        return 'Full Name';
      case VolunteerPdfColumn.nickname:
        return 'Nickname';
      case VolunteerPdfColumn.age:
        return 'Age';
      case VolunteerPdfColumn.email:
        return 'Email';
      case VolunteerPdfColumn.contactNumber:
        return 'Contact Number';
      case VolunteerPdfColumn.volunteerType:
        return 'Volunteer Type';
      case VolunteerPdfColumn.department:
        return 'Department';
    }
  }
}
