import 'package:flutter/material.dart';
import '../models/volunteer.dart';
import '../repo/volunteer_repo.dart';
//import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

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
  final TextEditingController _driveLinkController = TextEditingController();

  String volunteerType = 'Core';
  String department = 'Finance';

 /// Image state
  String? _localImagePath;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nicknameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _driveLinkController.dispose();
    super.dispose();
  }

  Future<void> _pickLocalImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _localImagePath = result.files.single.path!;
        _driveLinkController.clear();
      });
    }
  }

  String? get _finalPhotoPath {
    if (_localImagePath != null) return _localImagePath;
    if (_driveLinkController.text.trim().isNotEmpty) {
      return _driveLinkController.text.trim();
    }
    return null;
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

            /// IMAGE PREVIEW
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _localImagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_localImagePath!),
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.person, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Pick Image'),
                    onPressed: _pickLocalImage,
                  ),
                ],
              ),

              /// DRIVE LINK
              TextFormField(
                controller: _driveLinkController,
                decoration: const InputDecoration(
                  labelText: 'Google Drive Image Link (optional)',
                ),
                onChanged: (_) {
                  if (_driveLinkController.text.isNotEmpty) {
                    setState(() => _localImagePath = null);
                  }
                },
              ),

              const Divider(height: 32),

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
              DropdownButtonFormField<String>(
                value: department,
                items: const [
                  DropdownMenuItem(value: 'Finance', child: Text('Finance')),
                  DropdownMenuItem(value: 'Marketing', child: Text('Marketing')),
                  DropdownMenuItem(value: 'Talents', child: Text('Talents')),
                  DropdownMenuItem(value: 'Production', child: Text('Production')),
                  DropdownMenuItem(value: 'Logistics', child: Text('Logistics')),
                  DropdownMenuItem(value: 'Security and Sanitation', child: Text('Security and Sanitation')),
                  DropdownMenuItem(value: 'Volunteer Operations', child: Text('Volunteer Operations')),
                ],
                onChanged: (val) => department = val!,
                decoration: const InputDecoration(labelText: 'Department'),
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
                      department: department,
                      photoPath: _finalPhotoPath, 
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
