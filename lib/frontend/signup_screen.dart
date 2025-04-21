import 'package:flutter/material.dart';
import 'package:true_studentmgnt_mobapp/utilities/constants.dart';
import 'package:intl/intl.dart';

class SignupScreen extends StatefulWidget {
  static const String id = 'signup_screen';

  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _userType = 'student'; // Default
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  DateTime? _selectedDate;
  String? _selectedJobTitle;

  // Text editing controllers
  final _studentNumberController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _courseController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _departmentController = TextEditingController();

  // List of job titles for admin dropdown
  final List<String> _jobTitles = [
    'Department Head',
    'Professor',
    'Assistant Professor',
    'Instructor',
    'Academic Coordinator',
    'Dean',
    'IT Administrator',
    'Registrar',
    'Guidance Counselor',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Extract the user type from the route arguments
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (arguments != null && arguments.containsKey('userType')) {
      _userType = arguments['userType'] as String;
    }
  }

  @override
  void dispose() {
    _studentNumberController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _courseController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ??
          DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary:
                  _userType == 'admin' ? kAccentColor : kComplementaryColor,
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

  void _handleSignup() {
    if (_formKey.currentState!.validate()) {
      // Handle signup with Firebase
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAdmin = _userType == 'admin';

    // Define user-specific styling
    final Color primaryColor = isAdmin ? kAccentColor : kComplementaryColor;
    final IconData userIcon =
        isAdmin ? Icons.admin_panel_settings : Icons.school;
    final String heroTag = isAdmin ? 'admin-icon' : 'student-icon';
    final String userTypeText = isAdmin ? 'Admin' : 'Student';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: Column(
                children: [
                  // Back button and title row
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: theme.colorScheme.onPrimary,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Sign Up',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Hero animated icon
                  Hero(
                    tag: heroTag,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(userIcon, size: 60, color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: kDefaultPadding),

                  // Welcome text
                  Text(
                    'Create Account',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 28,
                    ),
                  ),

                  Text(
                    'Sign up as $userTypeText',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onPrimary.withOpacity(0.8),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Signup Form Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(kLargeBorderRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(kDefaultPadding),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Student Form Fields
                            if (!isAdmin) ...[
                              _buildTextField(
                                controller: _studentNumberController,
                                labelText: 'Student Number',
                                prefixIcon: Icons.badge,
                                primaryColor: primaryColor,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your student number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: kDefaultPadding),
                            ],

                            // Common fields for both student and admin
                            _buildTextField(
                              controller: _firstNameController,
                              labelText: 'First Name',
                              prefixIcon: Icons.person,
                              primaryColor: primaryColor,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your first name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: kDefaultPadding),

                            _buildTextField(
                              controller: _middleNameController,
                              labelText: 'Middle Name (Optional)',
                              prefixIcon: Icons.person_outline,
                              primaryColor: primaryColor,
                            ),
                            const SizedBox(height: kDefaultPadding),

                            _buildTextField(
                              controller: _lastNameController,
                              labelText: 'Last Name',
                              prefixIcon: Icons.person,
                              primaryColor: primaryColor,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your last name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: kDefaultPadding),

                            // Student-specific fields
                            if (!isAdmin) ...[
                              // Date of Birth
                              InkWell(
                                onTap: () => _selectDate(context),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Date of Birth',
                                    prefixIcon: Icon(
                                      Icons.calendar_today,
                                      color: primaryColor,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        kDefaultBorderRadius,
                                      ),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        kDefaultBorderRadius,
                                      ),
                                      borderSide: BorderSide(
                                        color: primaryColor,
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                  child: Text(
                                    _selectedDate == null
                                        ? 'Select Date'
                                        : DateFormat(
                                          'MMMM dd, yyyy',
                                        ).format(_selectedDate!),
                                    style: TextStyle(
                                      color:
                                          _selectedDate == null
                                              ? Colors.grey.shade600
                                              : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: kDefaultPadding),

                              _buildTextField(
                                controller: _addressController,
                                labelText: 'Address',
                                prefixIcon: Icons.home,
                                primaryColor: primaryColor,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your address';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: kDefaultPadding),

                              _buildTextField(
                                controller: _courseController,
                                labelText: 'Course/Program',
                                prefixIcon: Icons.school,
                                primaryColor: primaryColor,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your course/program';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: kDefaultPadding),
                            ],

                            // Phone number for both
                            _buildTextField(
                              controller: _phoneController,
                              labelText: 'Phone Number',
                              prefixIcon: Icons.phone,
                              primaryColor: primaryColor,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: kDefaultPadding),

                            // Email for both
                            _buildTextField(
                              controller: _emailController,
                              labelText: 'Email',
                              prefixIcon: Icons.email,
                              primaryColor: primaryColor,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: kDefaultPadding),

                            // Admin-specific fields
                            if (isAdmin) ...[
                              _buildTextField(
                                controller: _departmentController,
                                labelText: 'Department',
                                prefixIcon: Icons.business,
                                primaryColor: primaryColor,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your department';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: kDefaultPadding),

                              // Job Title Dropdown
                              DropdownButtonFormField<String>(
                                value: _selectedJobTitle,
                                decoration: InputDecoration(
                                  labelText: 'Job Title',
                                  prefixIcon: Icon(
                                    Icons.work,
                                    color: primaryColor,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      kDefaultBorderRadius,
                                    ),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      kDefaultBorderRadius,
                                    ),
                                    borderSide: BorderSide(
                                      color: primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                items:
                                    _jobTitles.map((String title) {
                                      return DropdownMenuItem<String>(
                                        value: title,
                                        child: Text(title),
                                      );
                                    }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedJobTitle = newValue;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select a job title';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: kDefaultPadding),
                            ],

                            // Password fields for both
                            _buildPasswordField(
                              controller: _passwordController,
                              labelText: 'Password',
                              isVisible: _isPasswordVisible,
                              toggleVisibility: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              primaryColor: primaryColor,
                            ),
                            const SizedBox(height: kDefaultPadding),

                            // Confirm password (only for students)
                            if (!isAdmin)
                              _buildPasswordField(
                                controller: _confirmPasswordController,
                                labelText: 'Confirm Password',
                                isVisible: _isConfirmPasswordVisible,
                                toggleVisibility: () {
                                  setState(() {
                                    _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible;
                                  });
                                },
                                primaryColor: primaryColor,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),

                            const SizedBox(height: kLargePadding),

                            // Sign Up Button
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _handleSignup,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      kDefaultBorderRadius,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'SIGN UP',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: kDefaultPadding),

                            // Login link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Already have an account?",
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pushNamed(
                                      context,
                                      'login_screen',
                                      arguments: {'userType': _userType},
                                    );
                                  },
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    required Color primaryColor,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon, color: primaryColor),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kDefaultBorderRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kDefaultBorderRadius),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kDefaultBorderRadius),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kDefaultBorderRadius),
          borderSide: BorderSide(color: Colors.red.shade300, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required bool isVisible,
    required VoidCallback toggleVisibility,
    required Color primaryColor,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(Icons.lock, color: primaryColor),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility_off : Icons.visibility,
            color: primaryColor,
          ),
          onPressed: toggleVisibility,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kDefaultBorderRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kDefaultBorderRadius),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kDefaultBorderRadius),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kDefaultBorderRadius),
          borderSide: BorderSide(color: Colors.red.shade300, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
    );
  }
}
