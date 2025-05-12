import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:true_studentmgnt_mobapp/features/auth/data/models/admin_model.dart';
import 'package:true_studentmgnt_mobapp/features/auth/data/models/student_model.dart';
import 'package:true_studentmgnt_mobapp/features/auth/presentation/screens/admin/ad_classes_screen.dart';

class StClassesScreen extends StatefulWidget {
  static const String id = 'stclasses_screen';

  const StClassesScreen({super.key});

  @override
  State<StClassesScreen> createState() => _StClassesScreenState();
}

class _StClassesScreenState extends State<StClassesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<AdminModel> _classes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    try {
      final student = Provider.of<StudentModel>(context, listen: false);

      // Get all enrollments for this student
      final enrollments =
          await _firestore
              .collection('enrollments')
              .where('studentId', isEqualTo: student.uid)
              .get();

      if (enrollments.docs.isEmpty) {
        setState(() {
          _isLoading = false;
          _classes = [];
        });
        return;
      }

      // Get unique subjects from enrollments
      final subjects =
          enrollments.docs
              .map((doc) => doc.data()['subject'] as String)
              .toSet()
              .toList();

      // Get admins (teachers) for these subjects
      final admins =
          await _firestore
              .collection('admins')
              .where('jobTitle', whereIn: subjects)
              .get();

      setState(() {
        _classes =
            admins.docs
                .map((doc) => AdminModel.fromMap(doc.data()..['uid'] = doc.id))
                .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading classes: $e')));
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate to login screen or root
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error logging out: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Classes',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: theme.primaryColor,
          statusBarIconBrightness: Brightness.light,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: true,
              label: const Text('3'),
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () {
              // Implement notification functionality
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: theme.colorScheme.primary,
        onRefresh: _fetchClasses,
        child:
            _isLoading
                ? _buildLoadingView()
                : _classes.isEmpty
                ? _buildEmptyClassesView(theme)
                : _buildClassesListView(theme),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildEmptyClassesView(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 80,
            color: theme.colorScheme.secondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text('No classes yet', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Your enrolled classes will appear here',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Add action for joining a class
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Join a Class'),
          ),
        ],
      ),
    );
  }

  Widget _buildClassesListView(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _classes.length,
      itemBuilder: (context, index) {
        final classData = _classes[index];
        return _buildClassCard(classData, theme, context);
      },
    );
  }

  Widget _buildClassCard(
    AdminModel classData,
    ThemeData theme,
    BuildContext context,
  ) {
    return Hero(
      tag: 'class-${classData.uid}',
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Navigate to class details
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        classData.jobTitle ?? 'No Subject',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Active',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${classData.firstName} ${classData.lastName}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FutureBuilder<int?>(
                  future: _getAnnouncementCount(classData.jobTitle ?? ''),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(); // or a placeholder widget
                    } else if (snapshot.hasError) {
                      return const Text(
                        'Failed to load announcements',
                      ); // handle error nicely
                    } else {
                      final count = snapshot.data ?? 0;
                      return _buildInfoChip(
                        icon: Icons.announcement_outlined,
                        count: count,
                        label: 'Announcements',
                        theme: theme,
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdClassScreen(admin: classData),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.announcement_outlined, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'View Class',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required int count,
    required String label,
    required ThemeData theme,
    bool hasUnread = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: hasUnread ? Colors.red : theme.colorScheme.secondary,
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: hasUnread ? Colors.red : theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<int?> _getAnnouncementCount(String subject) async {
    try {
      final snapshot =
          await _firestore
              .collection('announcements')
              .where('subject', isEqualTo: subject)
              .count()
              .get();
      return snapshot.count;
    } catch (e) {
      return 0;
    }
  }
}
