import 'package:flutter/material.dart';
import '../repo/volunteer_repo.dart';
import '../models/volunteer.dart';
import 'package:volopsip/modal/add_volunteer.dart';
import 'package:volopsip/modal/add_volunteer_excel_modal.dart';
import 'package:volopsip/modal/filter_volunteer_modal.dart';
import 'package:volopsip/helpers/volunteer_page/list_item.dart';
import 'package:provider/provider.dart';
import 'package:volopsip/helpers/volunteer_page/vol_provider.dart';
import 'package:volopsip/modal/volunteer_pdf_export_modal.dart';


class VolunteerPage extends StatefulWidget {
  const VolunteerPage({super.key});

  @override
  State<VolunteerPage> createState() => _VolunteerPageState();
}

class _VolunteerPageState extends State<VolunteerPage> {
  @override
  void initState() {
    super.initState();
    // Fetch volunteers when page is first opened
    Future.microtask(() {
      context.read<VolunteerProvider>().fetchVolunteers();
    });
  }

  void _openAddVolunteerModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddVolunteerModal(
        onVolunteerAdded: () {
          context.read<VolunteerProvider>().refresh();
        },
      ),
    );
  }

  void _openAddVolunteerExcelModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddVolunteerExcelModal(
        onVolunteersAdded: () {
          context.read<VolunteerProvider>().refresh();
        },
      ),
    );
  }

  void _openFilterModal() {
  final provider = context.read<VolunteerProvider>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => FilterVolunteerModal(
      selectedVolunteerType: provider.filterVolunteerType,
      selectedDepartments: provider.filterDepartments,
      departments: provider.availableDepartments,
      onApply: ({
        String? volunteerType,
        Set<String>? departments,
      }) {
        provider.applyFilters(
          volunteerType: volunteerType,
          departments: departments,
        );
      },
    ),
  );
}




  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VolunteerProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteers'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: _openAddVolunteerModal,
              icon: const Icon(Icons.add),
              label: const Text('Add Volunteer'),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: _openAddVolunteerExcelModal,
              icon: const Icon(Icons.upload_file),
              label: const Text('Import Excel'),
            ),
          ),

          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onPressed: _openFilterModal,
          ),

          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export PDF',
            onPressed: () {
              final provider = context.read<VolunteerProvider>();

              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => VolunteerPdfExportModal(
                  volunteers: provider.volunteers, // 🔑 already filtered
                  volunteerTypeFilter: provider.filterVolunteerType,
                  departmentFilter: provider.filterDepartments,
                ),
              );
            },
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.volunteers.isEmpty
              ? const Center(
                  child: Text(
                    'No volunteer information in database',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, // 4 columns
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: provider.volunteers.length,
                    itemBuilder: (context, index) {
                      return VolunteerListItem(
                        volunteer: provider.volunteers[index],
                        onVolunteerUpdated: provider.refresh, // refresh after edit/delete
                      );
                    },
                  ),
                ),
    );
  }
}
