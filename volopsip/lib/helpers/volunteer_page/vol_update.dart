import 'dart:io';
import 'package:flutter/material.dart';
import 'package:volopsip/models/volunteer.dart';
import 'package:file_picker/file_picker.dart';

class EditVolunteerForm extends StatefulWidget {
  final Volunteer volunteer;
  final Function(Volunteer) onSave;

  const EditVolunteerForm({
    super.key,
    required this.volunteer,
    required this.onSave,
  });

  @override
  State<EditVolunteerForm> createState() => _EditVolunteerFormState();
}

class _EditVolunteerFormState extends State<EditVolunteerForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _nicknameController;
  late TextEditingController _ageController;
  late TextEditingController _emailController;
  late TextEditingController _contactController;
  late TextEditingController _imageLinkController;

  late String volunteerType;
  late String department;

  String? _localImagePath;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.volunteer.firstName);
    _lastNameController = TextEditingController(text: widget.volunteer.lastName);
    _nicknameController = TextEditingController(text: widget.volunteer.nickname ?? '');
    _ageController = TextEditingController(text: widget.volunteer.age.toString());
    _emailController = TextEditingController(text: widget.volunteer.email);
    _contactController = TextEditingController(text: widget.volunteer.contactNumber);
    _imageLinkController = TextEditingController(
      text: widget.volunteer.photoPath?.startsWith('http') == true ? widget.volunteer.photoPath : '',
    );
    volunteerType = widget.volunteer.volunteerType;
    department = widget.volunteer.department;
    if (widget.volunteer.photoPath != null && !widget.volunteer.photoPath!.startsWith('http')) {
      _localImagePath = widget.volunteer.photoPath;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nicknameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _imageLinkController.dispose();
    super.dispose();
  }

  Future<void> _pickLocalImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _localImagePath = result.files.single.path!;
        _imageLinkController.clear();
      });
    }
  }

  String? get _finalPhotoPath {
    if (_localImagePath != null) return _localImagePath;
    if (_imageLinkController.text.trim().isNotEmpty) {
      return _imageLinkController.text.trim();
    }
    return null;
  }

  Widget _buildImagePreview() {
    final path = _finalPhotoPath;

    if (path == null || path.isEmpty) {
      return const Icon(Icons.person, size: 60, color: Colors.grey);
    }

    if (path.startsWith('http')) {
      return Image.network(path, fit: BoxFit.cover);
    }

    return Image.file(File(path), fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.orange, width: 2),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Image
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildImagePreview(),
                ),
              ),
              const SizedBox(width: 16),

              // Right: Details and bottom image controls
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Details
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(labelText: 'First Name'),
                      validator: (v) => v == null || v.isEmpty ? 'Enter first name' : null,
                    ),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: 'Last Name'),
                      validator: (v) => v == null || v.isEmpty ? 'Enter last name' : null,
                    ),
                    TextFormField(
                      controller: _nicknameController,
                      decoration: const InputDecoration(labelText: 'Nickname (optional)'),
                    ),
                    TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(labelText: 'Age'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || int.tryParse(v) == null ? 'Enter valid age' : null,
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (v) => v == null || v.isEmpty ? 'Enter email' : null,
                    ),
                    TextFormField(
                      controller: _contactController,
                      decoration: const InputDecoration(labelText: 'Contact Number'),
                      validator: (v) => v == null || v.isEmpty ? 'Enter contact number' : null,
                    ),
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

                    // BOTTOM: Image picker + link
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.folder_open),
                          label: const Text('Pick Image'),
                          onPressed: _pickLocalImage,
                        ),
                        TextFormField(
                          controller: _imageLinkController,
                          decoration: const InputDecoration(
                            labelText: 'Image Link (Cloudinary / optional)',
                          ),
                          onChanged: (_) {
                            if (_imageLinkController.text.isNotEmpty) {
                              setState(() => _localImagePath = null);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final updatedVolunteer = Volunteer(
                            uuid: widget.volunteer.uuid,
                            id: widget.volunteer.id,
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
                          widget.onSave(updatedVolunteer);
                        }
                      },
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
