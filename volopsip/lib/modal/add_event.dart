// modal/add_event.dart
import 'package:flutter/material.dart';
import 'package:volopsip/models/events.dart';
import 'package:volopsip/models/volunteer.dart';
import 'package:volopsip/repo/events_repo.dart';
import 'package:volopsip/repo/volunteer_repo.dart';
import 'package:volopsip/helpers/events_page/vol_selector.dart';

class AddEventModal extends StatefulWidget {
  final VoidCallback onEventAdded;
  const AddEventModal({super.key, required this.onEventAdded});

  @override
  State<AddEventModal> createState() => _AddEventModalState();
}

class _AddEventModalState extends State<AddEventModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final EventRepository _repo = EventRepository();
  final VolunteerRepository _volRepo = VolunteerRepository();

  List<TextEditingController> _attributeControllers = [];
  int _numAttributes = 1; // initial number of attributes

  List<Volunteer> _allVolunteers = [];
  List<Volunteer> _selectedVolunteers = [];

  @override
  void initState() {
    super.initState();
    _attributeControllers = List.generate(_numAttributes, (_) => TextEditingController());
    _fetchVolunteers();
  }

  Future<void> _fetchVolunteers() async {
    final data = await _volRepo.getAllVolunteers();
    setState(() {
      _allVolunteers = data;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (var c in _attributeControllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add Event',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Event Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Event Name'),
                validator: (v) => v == null || v.isEmpty ? 'Enter event name' : null,
              ),

              const SizedBox(height: 16),

              // Number of Attributes
              Row(
                children: [
                  const Text('Number of Attributes:'),
                  const SizedBox(width: 12),
                  DropdownButton<int>(
                    value: _numAttributes,
                    items: List.generate(10, (i) => i + 1)
                        .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        _numAttributes = v;
                        // adjust controllers
                        if (_attributeControllers.length < v) {
                          _attributeControllers.addAll(
                              List.generate(v - _attributeControllers.length, (_) => TextEditingController()));
                        } else if (_attributeControllers.length > v) {
                          _attributeControllers = _attributeControllers.sublist(0, v);
                        }
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Attribute input fields
              ...List.generate(_numAttributes, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: TextFormField(
                    controller: _attributeControllers[i],
                    decoration: InputDecoration(labelText: 'Attribute ${i + 1}'),
                    validator: (v) => v == null || v.isEmpty ? 'Enter attribute' : null,
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Select volunteers
              ElevatedButton(
                child: const Text('Select Volunteers'),
                onPressed: () async {
                  if (_allVolunteers.isEmpty) return;

                  // Convert volunteers to options
                  final volunteerOptions = _allVolunteers
                      .map((v) => VolunteerOption(id: v.id!, name: v.firstName))
                      .toList();

                  final selectedIds = await showVolunteerSelector(
                    context,
                    volunteers: volunteerOptions,
                    initiallySelected: _selectedVolunteers.map((v) => v.id!).toList(),
                  );

                  setState(() {
                    _selectedVolunteers = _allVolunteers
                        .where((v) => selectedIds.contains(v.id))
                        .toList();
                  });
                },
              ),

              // Display selected volunteers
              if (_selectedVolunteers.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Selected: ${_selectedVolunteers.map((v) => v.firstName).join(', ')}',
                  ),
                ),

              const SizedBox(height: 16),

              // Create Event button
              ElevatedButton(
                child: const Text('Create Event'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final attributes = _attributeControllers.map((c) => c.text.trim()).toList();

                    final event = Event(
                      name: _nameController.text.trim(),
                      attributes: attributes,
                    );

                    // pass volunteer IDs to repo
                    await _repo.createEvent(
                      event,
                      volunteerIds: _selectedVolunteers.map((v) => v.id!).toList(),
                    );

                    widget.onEventAdded();
                    Navigator.pop(context);
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
