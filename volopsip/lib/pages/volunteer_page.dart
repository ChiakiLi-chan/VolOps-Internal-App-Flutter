import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../repo/volunteer_repo.dart';
import '../models/volunteer.dart';
import 'package:volopsip/modal/add_volunteer.dart';
import 'package:volopsip/modal/add_volunteer_excel_modal.dart';
import 'package:volopsip/modal/filter_volunteer_modal.dart';
import 'package:volopsip/helpers/volunteer_page/list_item.dart';
import 'package:volopsip/helpers/volunteer_page/vol_provider.dart';
import 'package:volopsip/modal/volunteer_pdf_export_modal.dart';
import 'package:volopsip/helpers/volunteer_page/vol_details.dart';
import 'package:volopsip/helpers/excel/export_volunteers.dart'; 
import 'package:volopsip/helpers/pdf/VolunteerQrpdfExport.dart';  
import 'package:volopsip/modal/selectVolunteerForQRID.dart';  

class VolunteerPage extends StatefulWidget {
  const VolunteerPage({super.key});

  @override
  State<VolunteerPage> createState() => _VolunteerPageState();
}

class _VolunteerPageState extends State<VolunteerPage> {
  final Set<int> _selectedIds = {};
  bool get _isSelectionMode => _selectedIds.isNotEmpty;

  // --- New: Search query & filtered list ---
  String _searchQuery = '';
  List<Volunteer> _filteredVolunteers = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = context.read<VolunteerProvider>();
      provider.fetchVolunteers().then((_) {
        setState(() {
          _filteredVolunteers = provider.volunteers;
        });
      });
    });
  }

  void _updateSearch(String query) {
    final provider = context.read<VolunteerProvider>();
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredVolunteers = provider.volunteers
          .where((v) =>
              v.firstName.toLowerCase().contains(_searchQuery) ||
              v.lastName.toLowerCase().contains(_searchQuery))
          .toList();
    });
  }

  void _toggleSelection(Volunteer v) {
    setState(() {
      if (_selectedIds.contains(v.id)) {
        _selectedIds.remove(v.id);
      } else {
        _selectedIds.add(v.id!);
      }
    });
  }

  Future<void> _deleteSelected(BuildContext context) async {
    final repo = VolunteerRepository();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Volunteers'),
        content: Text(
          'Delete ${_selectedIds.length} selected volunteers?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    for (final id in _selectedIds) {
      await repo.deleteVolunteer(id);
    }

    setState(() => _selectedIds.clear());
    context.read<VolunteerProvider>().refresh();
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

    if (_searchQuery.isEmpty) {
      _filteredVolunteers = provider.volunteers;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isSelectionMode
              ? '${_selectedIds.length} selected'
              : 'Volunteers',
        ),
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() => _selectedIds.clear());
                },
              )
            : null,
        actions: _isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteSelected(context),
                ),
              ]
            : [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 8.0),
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
                IconButton(
                  icon: const Icon(Icons.badge), // ID card icon
                  tooltip: 'Export QR IDs',
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => VolunteerQrExportFilterModal(
                        volunteers: _filteredVolunteers,
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.upload_file),
                  onPressed: _openAddVolunteerExcelModal,
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _openFilterModal,
                ),
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => VolunteerPdfExportModal(
                        volunteers: provider.volunteers,
                        volunteerTypeFilter: provider.filterVolunteerType,
                        departmentFilter: provider.filterDepartments,
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.table_view),
                  onPressed: () async {
                    await VolunteerExcelExport.export(
                      volunteers: provider.volunteers,
                      volunteerTypeFilter: provider.filterVolunteerType,
                      departmentFilter: provider.filterDepartments,
                    );
                  },
                ),
              ],
      ),
      body: Column(
        children: [
          // --- Search Bar ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search volunteers...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _updateSearch,
            ),
          ),

          // --- Volunteer Grid ---
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.volunteers.isEmpty
                    ? const Center(
                        child: Text(
                          'No volunteer information in database',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 8,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: _filteredVolunteers.length,
                          itemBuilder: (context, index) {
                            final v = _filteredVolunteers[index];
                            final isSelected = _selectedIds.contains(v.id);

                            return VolunteerListItem(
                              volunteer: v,
                              isSelected: isSelected,
                              onTap: () {
                                if (_isSelectionMode) {
                                  _toggleSelection(v);
                                } else {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (_) => VolunteerDetailsModal(
                                      volunteer: v,
                                      onVolunteerUpdated: provider.refresh,
                                    ),
                                  );
                                }
                              },
                              onLongPress: () => _toggleSelection(v),
                              onVolunteerUpdated: provider.refresh,
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
