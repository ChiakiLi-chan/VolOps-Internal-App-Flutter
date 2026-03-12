import 'package:flutter/material.dart';
import '../../models/events.dart';
import '../../models/event_assignment.dart';
import 'event_pdf_filter_modal.dart';
import '../../helpers/pdf/event_pdf.dart';
import 'package:volopsip/helpers/excel/export_events_excel.dart';
import '../../helpers/pdf/event_pdf_filter.dart';

class EventExportFormatDialog extends StatefulWidget {
  final Event event;
  final List<EventAssignment> eventAssignments;

  const EventExportFormatDialog({
    super.key,
    required this.event,
    required this.eventAssignments,
  });

  @override
  State<EventExportFormatDialog> createState() =>
      _EventExportFormatDialogState();
}

class _EventExportFormatDialogState extends State<EventExportFormatDialog> {
  EventPdfFilter selectedFilter = const EventPdfFilter();
  String selectedFormat = 'PDF'; // default

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Export Format',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Format selection chips
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ChoiceChip(
                    label: const Text('PDF'),
                    selected: selectedFormat == 'PDF',
                    onSelected: (_) {
                      setState(() {
                        selectedFormat = 'PDF';
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('CSV'),
                    selected: selectedFormat == 'CSV',
                    onSelected: (_) {
                      setState(() {
                        selectedFormat = 'CSV';
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Filter form
              EventPdfFilterModal(
                initialFilter: selectedFilter,
                eventAttributes: widget.event.attributes,
                onApply: (filter) async {
                  if (selectedFormat == 'PDF') {
                    await EventPdfExporter.export(
                      event: widget.event,
                      assignments: widget.eventAssignments,
                      filter: filter,
                    );
                  } else if (selectedFormat == 'CSV') {
                    await EventCsvExporter.export(
                      event: widget.event,
                      assignments: widget.eventAssignments,
                      filter: filter,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}