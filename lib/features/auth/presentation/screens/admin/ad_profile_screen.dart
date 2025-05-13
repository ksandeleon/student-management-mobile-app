import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:true_studentmgnt_mobapp/config/constants.dart';
import 'package:true_studentmgnt_mobapp/features/auth/data/models/admin_model.dart';
import 'package:true_studentmgnt_mobapp/features/auth/data/models/student_model.dart';
import 'package:true_studentmgnt_mobapp/features/auth/data/models/enrollment_model.dart';
import 'package:true_studentmgnt_mobapp/features/auth/presentation/screens/welcome_screen.dart';

class AdEnrollmentScreen extends StatefulWidget {
  final AdminModel admin;

  const AdEnrollmentScreen({Key? key, required this.admin}) : super(key: key);

  @override
  State<AdEnrollmentScreen> createState() => _AdEnrollmentScreenState();
}

class _AdEnrollmentScreenState extends State<AdEnrollmentScreen> {
  bool _isLoading = false;
  bool _isEnrolling = false;
  String? _errorMessage;
  List<StudentModel> _unenrolledStudents = [];
  List<String> _enrolledStudentIds = [];
  TextEditingController _searchController = TextEditingController();
  List<StudentModel> _filteredStudents = [];

  @override
  void initState() {
    super.initState();
    _loadUnenrolledStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Function to load unenrolled students
  Future<void> _loadUnenrolledStudents() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // First, get students who are already enrolled in this class
      final enrollmentsSnapshot =
          await FirebaseFirestore.instance
              .collection('enrollments')
              .where('subject', isEqualTo: widget.admin.jobTitle)
              .get();

      // Create a set of enrolled student IDs for efficient lookup
      final enrolledIds =
          enrollmentsSnapshot.docs
              .map((doc) => doc.data()['studentId'] as String)
              .toSet();

      // Get all students
      final studentsSnapshot =
          await FirebaseFirestore.instance.collection('students').get();

      // Filter out already enrolled students
      final allStudents =
          studentsSnapshot.docs
              .map((doc) => StudentModel.fromMap(doc.data(), docId: doc.id))
              .toList();

      final unenrolledStudents =
          allStudents
              .where((student) => !enrolledIds.contains(student.uid))
              .toList();

      setState(() {
        _enrolledStudentIds = enrolledIds.toList();
        _unenrolledStudents = unenrolledStudents;
        _filteredStudents = unenrolledStudents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load students: $e';
        _isLoading = false;
      });
      debugPrint('Error loading unenrolled students: $e');
    }
  }

  // Function to filter students based on search text
  void _filterStudents(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStudents = _unenrolledStudents;
      } else {
        _filteredStudents =
            _unenrolledStudents
                .where(
                  (student) =>
                      '${student.firstName} ${student.lastName}'
                          .toLowerCase()
                          .contains(query.toLowerCase()) ||
                      student.email.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
      }
    });
  }

  // Enroll a student in the class
  Future<void> _enrollStudent(StudentModel student) async {
    if (_isEnrolling) return;

    setState(() {
      _isEnrolling = true;
    });

    try {
      // Check if already enrolled (double-check)
      final existingEnrollment =
          await FirebaseFirestore.instance
              .collection('enrollments')
              .where('studentId', isEqualTo: student.uid)
              .where('subject', isEqualTo: widget.admin.jobTitle)
              .get();

      if (existingEnrollment.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${student.firstName} is already enrolled in this class',
            ),
          ),
        );
        setState(() {
          _isEnrolling = false;
        });
        return;
      }

      // Create the enrollment document in Firestore
      final enrollmentData = {
        'studentId': student.uid,
        'subject': widget.admin.jobTitle,
        'enrolledAt': FieldValue.serverTimestamp(),
        'enrolledBy': widget.admin.uid, // Track who enrolled the student
        'adminName':
            '${widget.admin.firstName} ${widget.admin.lastName}', // For easier querying
      };

      await FirebaseFirestore.instance
          .collection('enrollments')
          .add(enrollmentData);

      // Update our local lists to reflect the change
      setState(() {
        _enrolledStudentIds.add(student.uid);
        _unenrolledStudents.removeWhere((s) => s.uid == student.uid);
        _filteredStudents.removeWhere((s) => s.uid == student.uid);
        _isEnrolling = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${student.firstName} enrolled successfully in ${widget.admin.jobTitle}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isEnrolling = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error enrolling student: $e'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Error enrolling student: $e');
    }
  }

  // Unenroll a student (if needed)
  Future<void> _unenrollStudent(String enrollmentId, String studentName) async {
    try {
      await FirebaseFirestore.instance
          .collection('enrollments')
          .doc(enrollmentId)
          .delete();

      // Refresh student list
      _loadUnenrolledStudents();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$studentName unenrolled successfully'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error unenrolling student: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await FirebaseAuth.instance.signOut(); // 🔐 Sign out from Firebase
            Navigator.pushReplacementNamed(
              context,
              WelcomeScreen.id,
            ); // ⬅️ Redirect to WelcomeScreen
          },
        ),
        title: const Text("ENROLL STUDENTS"),
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUnenrolledStudents,
            tooltip: 'Refresh student list',
          ),
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: _showEnrolledStudents,
            tooltip: 'View enrolled students',
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kPrimaryColor, kComplementaryColor],
          ),
        ),
        child: _buildBody(), // Your actual body content
      ),
    );
  }

  // Show dialog with enrolled students
  Future<void> _showEnrolledStudents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get enrollments for this class
      final enrollmentsSnapshot =
          await FirebaseFirestore.instance
              .collection('enrollments')
              .where('subject', isEqualTo: widget.admin.jobTitle)
              .get();

      if (enrollmentsSnapshot.docs.isEmpty) {
        // No enrolled students
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('${widget.admin.jobTitle} - Enrolled Students'),
              content: const Text('No students enrolled in this class yet.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get student details for each enrollment
      final enrollments = enrollmentsSnapshot.docs;
      final enrolledStudentsList = <Map<String, dynamic>>[];

      for (var enrollment in enrollments) {
        final enrollmentData = enrollment.data();
        final studentId = enrollmentData['studentId'] as String;

        final studentDoc =
            await FirebaseFirestore.instance
                .collection('students')
                .doc(studentId)
                .get();

        if (studentDoc.exists) {
          final student = StudentModel.fromMap(
            studentDoc.data()!,
            docId: studentDoc.id,
          );

          enrolledStudentsList.add({
            'student': student,
            'enrollmentId': enrollment.id,
            'enrolledAt':
                enrollmentData['enrolledAt'] != null
                    ? (enrollmentData['enrolledAt'] as Timestamp).toDate()
                    : DateTime.now(),
          });
        }
      }

      // Sort by enrollment date (newest first)
      enrolledStudentsList.sort(
        (a, b) => (b['enrolledAt'] as DateTime).compareTo(
          a['enrolledAt'] as DateTime,
        ),
      );

      // Show dialog with enrolled students
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              '${widget.admin.jobTitle} - Enrolled Students (${enrolledStudentsList.length})',
            ),
            content: Container(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: enrolledStudentsList.length,
                itemBuilder: (context, index) {
                  final data = enrolledStudentsList[index];
                  final student = data['student'] as StudentModel;
                  final enrollmentId = data['enrollmentId'] as String;
                  final enrolledAt = data['enrolledAt'] as DateTime;

                  return ListTile(
                    title: Text('${student.firstName} ${student.lastName}'),
                    subtitle: Text('Enrolled on: ${_formatDate(enrolledAt)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.person_remove, color: Colors.red),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _confirmUnenroll(enrollmentId, student);
                      },
                      tooltip: 'Unenroll student',
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('CLOSE'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading enrolled students: $e'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Error loading enrolled students: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Confirm before unenrolling a student
  Future<void> _confirmUnenroll(
    String enrollmentId,
    StudentModel student,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Unenroll Student'),
            content: Text(
              'Are you sure you want to unenroll ${student.firstName} ${student.lastName} from ${widget.admin.jobTitle}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'UNENROLL',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (result == true) {
      await _unenrollStudent(
        enrollmentId,
        '${student.firstName} ${student.lastName}',
      );
    }
  }

  // Format date for display
  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _loadUnenrolledStudents,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildClassInfoCard(),
          _buildSearchBar(),
          _buildEnrollmentStats(),
          Expanded(child: _buildStudentsList()),
        ],
      ),
    );
  }

  Widget _buildEnrollmentStats() {
    return Container(
      padding: const EdgeInsets.all(kDefaultPadding),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: "Unenrolled",
              count: _unenrolledStudents.length.toString(),
              icon: Icons.person_outline,
              color: kAccentColor,
            ),
          ),
          const SizedBox(width: kDefaultPadding),
          Expanded(
            child: _buildStatCard(
              title: "Enrolled",
              count: _enrolledStudentIds.length.toString(),
              icon: Icons.how_to_reg,
              color: kPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(kDefaultPadding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: kSmallPadding),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                count,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClassInfoCard() {
    return Container(
      padding: const EdgeInsets.all(kLargePadding),
      color: kPrimaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school, size: 48, color: Colors.white),
              const SizedBox(width: kDefaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.admin.jobTitle ?? "Untitled Class",
                      style: kHeadingTextStyle.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: kSmallPadding),
                    Text(
                      "Professor: ${widget.admin.firstName} ${widget.admin.lastName}",
                      style: kSubheadingTextStyle.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: kDefaultPadding),
          const Text(
            "Enroll students in your class",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(kDefaultPadding),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: _filterStudents,
        decoration: InputDecoration(
          hintText: "Search students...",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kDefaultBorderRadius),
          ),
          filled: true,
          fillColor: Colors.grey,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: kDefaultPadding,
          ),
        ),
      ),
    );
  }

  Widget _buildStudentsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!, style: kBodyTextStyle));
    }

    if (_filteredStudents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_off, size: 64, color: Colors.grey),
            const SizedBox(height: kDefaultPadding),
            const Text(
              "No students available for enrollment",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: kDefaultPadding),
            ElevatedButton.icon(
              onPressed: _loadUnenrolledStudents,
              icon: const Icon(Icons.refresh),
              label: const Text("Refresh"),
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(kDefaultPadding),
      itemCount: _filteredStudents.length,
      itemBuilder: (context, index) {
        final student = _filteredStudents[index];
        return _buildStudentCard(student);
      },
    );
  }

  Widget _buildStudentCard(StudentModel student) {
    return Card(
      margin: const EdgeInsets.only(bottom: kDefaultPadding),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: kPrimaryColor.withOpacity(0.2),
              child: Text(
                '${student.firstName[0]}${student.lastName[0]}',
                style: const TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: kDefaultPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${student.firstName} ${student.lastName}",
                    style: kSubheadingTextStyle,
                  ),
                  Text(
                    student.email,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _isEnrolling ? null : () => _enrollStudent(student),
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kDefaultBorderRadius),
                ),
                disabledBackgroundColor: Colors.grey,
              ),
              child:
                  _isEnrolling
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Text(
                        "Enroll",
                        style: TextStyle(color: Colors.white),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
