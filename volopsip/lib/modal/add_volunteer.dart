import 'package:flutter/material.dart';
import '../models/volunteer.dart';
import '../repo/volunteer_repo.dart';
//import 'package:uuid/uuid.dart';

class AddVolunteerModal extends StatefulWidget {
  final VoidCallback onVolunteerAdded;

  const AddVolunteerModal({super.key, required this.onVolunteerAdded});

  @override
  State<AddVolunteerModal> createState() => _AddVolunteerModalState();
}

class _AddVolunteerModalState extends State<AddVolunteerModal> {
  final _formKey = GlobalKey<FormState>();
  final VolunteerRepository _repo = VolunteerRepository();

  // Controllers for first name, last name, nickname
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  String volunteerType = 'OTD';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nicknameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
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
                'Add Volunteer',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // First Name
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter first name' : null,
              ),

              // Last Name
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter last name' : null,
              ),

              // Nickname (optional)
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(labelText: 'Nickname (optional)'),
              ),

              // Age
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    val == null || int.tryParse(val) == null ? 'Enter valid age' : null,
              ),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter email' : null,
              ),

              // Contact Number
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(labelText: 'Contact Number'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter contact number' : null,
              ),

              // Volunteer Type
              DropdownButtonFormField<String>(
                value: volunteerType,
                items: const [
                  DropdownMenuItem(value: 'Core', child: Text('Core')),
                  DropdownMenuItem(value: 'OTD', child: Text('OTD')),
                ],
                onChanged: (val) => volunteerType = val!,
                decoration: const InputDecoration(labelText: 'Volunteer Type'),
              ),

              const SizedBox(height: 16),

              // Add Button
              ElevatedButton(
                child: const Text('Add Volunteer'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final newVolunteer = Volunteer(
                      //uuid: const Uuid().v4(),
                      firstName: _firstNameController.text.trim(),
                      lastName: _lastNameController.text.trim(),
                      nickname: _nicknameController.text.trim().isEmpty
                          ? null
                          : _nicknameController.text.trim(),
                      age: int.parse(_ageController.text.trim()),
                      email: _emailController.text.trim(),
                      contactNumber: _contactController.text.trim(),
                      volunteerType: volunteerType,
                    );

                    await _repo.createVolunteer(newVolunteer);

                    Navigator.pop(context); // close modal
                    widget.onVolunteerAdded(); // refresh parent list
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
