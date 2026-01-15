import 'package:flutter/material.dart';
import '../repo/volunteer_repo.dart';
import '../models/volunteer.dart';
import 'package:volopsip/modal/add_volunteer.dart';
import 'package:volopsip/helpers/volunteer_page/list_item.dart';

class VolunteerPage extends StatefulWidget {
  const VolunteerPage({super.key});

  @override
  State<VolunteerPage> createState() => _VolunteerPageState();
}

class _VolunteerPageState extends State<VolunteerPage> {
  final VolunteerRepository _repo = VolunteerRepository();
  List<Volunteer> volunteers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVolunteers();
  }

  Future<void> fetchVolunteers() async {
    final data = await _repo.getAllVolunteers();
    setState(() {
      volunteers = data;
      isLoading = false;
    });
  }

  void _openAddVolunteerModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddVolunteerModal(
        onVolunteerAdded: fetchVolunteers,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : volunteers.isEmpty
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
                      childAspectRatio: 0.8, // adjust for square + name
                    ),
                    itemCount: volunteers.length,
                    itemBuilder: (context, index) {
                      return VolunteerListItem(volunteer: volunteers[index], onVolunteerUpdated: fetchVolunteers,);
                    },
                  ),
                ),
    );
  }
}
