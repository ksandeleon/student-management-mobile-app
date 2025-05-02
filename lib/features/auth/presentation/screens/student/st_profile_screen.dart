import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/student_model.dart';

class StudentProfileScreen extends StatefulWidget {
  final StudentModel student;
  final Function(StudentModel) onSubmitChanges;

  static const String id = 'stprofile_screen';

  const StudentProfileScreen({
    Key? key,
    required this.student,
    required this.onSubmitChanges,
  }) : super(key: key);

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  bool _isEditing = false;
  Map<String, bool> _pendingFields = {};
  late StudentModel _editedStudent;

  // Controllers for text fields
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _studentNumberController;
  late TextEditingController _addressController;
  late TextEditingController _courseController;
  DateTime? _selectedDate;


  @override
  void initState() {
    super.initState();
    _editedStudent = widget.student;
    _selectedDate = widget.student.dob;

    // Initialize controllers with current data
    _firstNameController = TextEditingController(
      text: widget.student.firstName,
    );
    _lastNameController = TextEditingController(text: widget.student.lastName);
    _middleNameController = TextEditingController(
      text: widget.student.middleName ?? '',
    );
    _emailController = TextEditingController(text: widget.student.email);
    _phoneController = TextEditingController(text: widget.student.phone);
    _studentNumberController = TextEditingController(
      text: widget.student.studentNumber ?? '',
    );
    _addressController = TextEditingController(
      text: widget.student.address ?? '',
    );
    _courseController = TextEditingController(
      text: widget.student.course ?? '',
    );
  }


  @override
  void dispose() {
    // Dispose controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _studentNumberController.dispose();
    _addressController.dispose();
    _courseController.dispose();
    super.dispose();
  }


  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // If canceling edit mode, revert changes
        _firstNameController.text = widget.student.firstName;
        _lastNameController.text = widget.student.lastName;
        _middleNameController.text = widget.student.middleName ?? '';
        _emailController.text = widget.student.email;
        _phoneController.text = widget.student.phone;
        _studentNumberController.text = widget.student.studentNumber ?? '';
        _addressController.text = widget.student.address ?? '';
        _courseController.text = widget.student.course ?? '';
        _selectedDate = widget.student.dob;
      }
    });
  }


  void _submitChanges() {
    // Check which fields have changed
    _pendingFields.clear();

    if (_firstNameController.text != widget.student.firstName) {
      _pendingFields['firstName'] = true;
    }

    if (_lastNameController.text != widget.student.lastName) {
      _pendingFields['lastName'] = true;
    }

    if (_middleNameController.text != (widget.student.middleName ?? '')) {
      _pendingFields['middleName'] = true;
    }

    if (_emailController.text != widget.student.email) {
      _pendingFields['email'] = true;
    }

    if (_phoneController.text != widget.student.phone) {
      _pendingFields['phone'] = true;
    }

    if (_studentNumberController.text != (widget.student.studentNumber ?? '')) {
      _pendingFields['studentNumber'] = true;
    }

    if (_addressController.text != (widget.student.address ?? '')) {
      _pendingFields['address'] = true;
    }

    if (_courseController.text != (widget.student.course ?? '')) {
      _pendingFields['course'] = true;
    }

    if (_selectedDate != widget.student.dob) {
      _pendingFields['dob'] = true;
    }

    // Create updated student model
    final updatedStudent = StudentModel(
      uid: widget.student.uid,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      middleName:
          _middleNameController.text.isEmpty
              ? null
              : _middleNameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      studentNumber:
          _studentNumberController.text.isEmpty
              ? null
              : _studentNumberController.text,
      address: _addressController.text.isEmpty ? null : _addressController.text,
      course: _courseController.text.isEmpty ? null : _courseController.text,
      dob: _selectedDate,
    );

    // Call the callback with updated model
    widget.onSubmitChanges(updatedStudent);

    // Toggle edit mode
    setState(() {
      _isEditing = false;
      _editedStudent = updatedStudent;
    });
  }


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not set';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom app bar with school logo and name
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Student Profile'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // School logo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.school_rounded,
                          color: Theme.of(context).primaryColor,
                          size: 50,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // School name
                    const Text(
                      'Tech University',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Profile content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile card
                  Card(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.2),
                                child: Text(
                                  '${widget.student.firstName[0]}${widget.student.lastName[0]}',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${widget.student.firstName} ${widget.student.lastName}',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.student.studentNumber ??
                                          'No Student ID',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.student.course ??
                                          'No Course Selected',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.copyWith(
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Student details
                  Text(
                    'Student Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  // Actual profile fields
                  _isEditing ? _buildEditableFields() : _buildDisplayFields(),

                  const SizedBox(height: 30),

                  // Edit/Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isEditing ? _submitChanges : _toggleEditMode,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _isEditing ? 'Submit Changes' : 'Edit Profile',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  if (_isEditing)
                    TextButton(
                      onPressed: _toggleEditMode,
                      child: const Text('Cancel'),
                    ),

                  // Pending approval indicators
                  if (_pendingFields.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.pending_actions,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Changes Pending Approval',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: Colors.amber[800]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'The following fields have been edited and are awaiting admin approval:',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                _pendingFields.keys.map((field) {
                                  return Chip(
                                    label: Text(_formatFieldName(field)),
                                    backgroundColor: Colors.amber.withOpacity(
                                      0.3,
                                    ),
                                    side: BorderSide.none,
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatFieldName(String field) {
    // Convert camelCase to readable format
    final result = field.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    );
    return result[0].toUpperCase() + result.substring(1);
  }

  Widget _buildDisplayFields() {
    return Column(
      children: [
        _buildInfoRow(
          'First Name',
          _editedStudent.firstName,
          isPending: _pendingFields.containsKey('firstName'),
        ),
        _buildInfoRow(
          'Middle Name',
          _editedStudent.middleName ?? 'Not provided',
          isPending: _pendingFields.containsKey('middleName'),
        ),
        _buildInfoRow(
          'Last Name',
          _editedStudent.lastName,
          isPending: _pendingFields.containsKey('lastName'),
        ),
        _buildInfoRow(
          'Email',
          _editedStudent.email,
          isPending: _pendingFields.containsKey('email'),
        ),
        _buildInfoRow(
          'Phone',
          _editedStudent.phone,
          isPending: _pendingFields.containsKey('phone'),
        ),
        _buildInfoRow(
          'Student Number',
          _editedStudent.studentNumber ?? 'Not provided',
          isPending: _pendingFields.containsKey('studentNumber'),
        ),
        _buildInfoRow(
          'Date of Birth',
          _formatDate(_editedStudent.dob),
          isPending: _pendingFields.containsKey('dob'),
        ),
        _buildInfoRow(
          'Course',
          _editedStudent.course ?? 'Not provided',
          isPending: _pendingFields.containsKey('course'),
        ),
        _buildInfoRow(
          'Address',
          _editedStudent.address ?? 'Not provided',
          isPending: _pendingFields.containsKey('address'),
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isPending = false,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border:
            isLast
                ? null
                : Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor.withOpacity(0.3),
                  ),
                ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                if (isPending)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Tooltip(
                      message: 'Pending approval',
                      child: Icon(
                        Icons.pending_outlined,
                        size: 18,
                        color: Colors.amber[700],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableFields() {
    return Column(
      children: [
        _buildTextField(
          label: 'First Name',
          controller: _firstNameController,
          required: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Middle Name',
          controller: _middleNameController,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Last Name',
          controller: _lastNameController,
          required: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Email',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          required: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Phone',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          required: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Student Number',
          controller: _studentNumberController,
        ),
        const SizedBox(height: 16),
        _buildDatePicker(),
        const SizedBox(height: 16),
        _buildTextField(label: 'Course', controller: _courseController),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Address',
          controller: _addressController,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool required = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon:
            required
                ? const Padding(
                  padding: EdgeInsets.only(top: 12.0),
                  child: Text(
                    '*',
                    style: TextStyle(color: Colors.red, fontSize: 18),
                  ),
                )
                : null,
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'Date of Birth',
            suffixIcon: Icon(
              Icons.calendar_today,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          controller: TextEditingController(
            text:
                _selectedDate != null ? _formatDate(_selectedDate) : 'Not set',
          ),
        ),
      ),
    );
  }
}
