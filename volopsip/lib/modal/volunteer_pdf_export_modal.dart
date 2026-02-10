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

    /// Default: everything EXCEPT QR
    _selectedColumns = {
      VolunteerPdfColumn.fullName,
      VolunteerPdfColumn.nickname,
      VolunteerPdfColumn.age,
      VolunteerPdfColumn.email,
      VolunteerPdfColumn.contactNumber,
      VolunteerPdfColumn.volunteerType,
      VolunteerPdfColumn.department,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Center(
              child: Text(
                'Export Volunteer PDF',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Columns',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            ...VolunteerPdfColumn.values.map(
              (col) => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
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
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedColumns.isEmpty
                        ? null
                        : () async {
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
                    child: const Text('Export'),
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
      case VolunteerPdfColumn.qr:
        return 'QR Code';
    }
  }
}
