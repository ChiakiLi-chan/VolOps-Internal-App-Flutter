import 'package:flutter/material.dart';
import '../repo/volunteer_repo.dart';
import '../models/volunteer.dart';
import 'package:volopsip/modal/add_volunteer.dart';
import 'package:volopsip/helpers/volunteer_page/list_item.dart';
import 'package:provider/provider.dart';
import 'package:volopsip/helpers/volunteer_page/vol_provider.dart';


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
