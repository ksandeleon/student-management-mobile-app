import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:true_studentmgnt_mobapp/config/constants.dart';
import 'package:true_studentmgnt_mobapp/features/auth/data/models/admin_model.dart';
import 'package:true_studentmgnt_mobapp/features/auth/data/models/student_model.dart';
import 'package:true_studentmgnt_mobapp/features/auth/data/models/announcement_model.dart';
import 'package:true_studentmgnt_mobapp/features/auth/domain/helpers/announcement_helper.dart';
import 'package:true_studentmgnt_mobapp/features/auth/domain/helpers/enrollment_helper.dart';

class AdClassScreen extends StatefulWidget {
  final AdminModel admin;

  const AdClassScreen({Key? key, required this.admin}) : super(key: key);

  @override
  State<AdClassScreen> createState() => _AdClassScreenState();
}

class _AdClassScreenState extends State<AdClassScreen> {
  final TextEditingController _announcementController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isPosting = false;
  bool _isLoadingStudents = false;
  String? _errorMessage;
  List<StudentModel> _students = [];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    if (_isLoadingStudents || widget.admin.jobTitle == null) return;

    setState(() {
      _isLoadingStudents = true;
      _errorMessage = null;
    });

    try {
      final students = await EnrollmentHelper.getStudentsBySubject(
        widget.admin.jobTitle,
      );
      setState(() {
        _students = students;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load students: ${e.toString()}';
      });
      if (kDebugMode) {
        print('Error loading students: $e');
      }
    } finally {
      setState(() {
        _isLoadingStudents = false;
      });
    }
  }

  // Refactored to use AnnouncementHelper
  Future<void> _postAnnouncement() async {
    final text = _announcementController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isPosting = true;
      _errorMessage = null;
    });

    try {
      await AnnouncementHelper.postAnnouncement(text, widget.admin);
      _announcementController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement posted successfully')),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to post announcement: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post announcement: $e')),
      );
    } finally {
      setState(() {
        _isPosting = false;
      });
    }
  }

  // Using stream for real-time announcements updates
  Stream<List<AnnouncementModel>> _getAnnouncementsStream() {
    return FirebaseFirestore.instance
        .collection('announcements')
        .where('adminId', isEqualTo: widget.admin.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => AnnouncementModel.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Function to delete an announcement with confirmation
  Future<void> _deleteAnnouncement(String announcementId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Announcement'),
            content: const Text(
              'Are you sure you want to delete this announcement?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('DELETE'),
              ),
            ],
          ),
    );

    if (shouldDelete == true) {
      try {
        await AnnouncementHelper.deleteAnnouncement(announcementId);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Announcement deleted')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete announcement: $e')),
        );
      }
    }
  }

  // Function to edit an announcement
  Future<void> _editAnnouncement(AnnouncementModel announcement) async {
    final controller = TextEditingController(text: announcement.text);

    final newText = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Announcement'),
            content: TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "Edit your announcement here...",
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed:
                    () => Navigator.of(context).pop(controller.text.trim()),
                child: const Text('SAVE'),
              ),
            ],
          ),
    );

    if (newText != null && newText.isNotEmpty && newText != announcement.text) {
      try {
        await AnnouncementHelper.editAnnouncement(announcement.id, newText);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Announcement updated')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update announcement: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Builder(builder: (context) => _buildStudentsDrawer()),
      appBar: _buildAppBar(),
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

  // Split widget methods for better readability
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text("FACULTY CLASSROOM"),
      backgroundColor: kPrimaryColor,
      actions: [
        // IconButton(
        //   icon: const Icon(Icons.menu),
        //   onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        // ),
      ],
    );
  }

  Widget _buildStudentsDrawer() {
    return Drawer(
      child:
          _isLoadingStudents
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_errorMessage!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadStudents,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : ListView(
                padding: const EdgeInsets.all(kDefaultPadding),
                children: [
                  const Text("Enrolled Students", style: kHeadingTextStyle),
                  const SizedBox(height: kDefaultPadding),
                  if (_students.isEmpty)
                    const Center(child: Text("No students enrolled yet"))
                  else
                    ..._students.map(
                      (student) => ListTile(
                        title: Text("${student.firstName} ${student.lastName}"),
                        subtitle: Text(student.email),
                        leading: const Icon(Icons.person_outline),
                      ),
                    ),
                ],
              ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildClassInfoCard(),
          const SizedBox(height: kLargePadding),
          _buildAnnouncementInput(),
          const SizedBox(height: kLargePadding),
          _buildAnnouncementsList(),
        ],
      ),
    );
  }

  Widget _buildClassInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kLargeBorderRadius),
      ),
      elevation: 6,
      color: kSecondaryColor,
      child: Padding(
        padding: const EdgeInsets.all(kLargePadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.class_, size: 48, color: Colors.white),
            const SizedBox(width: kDefaultPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.admin.jobTitle ?? "Untitled Class",
                    style: kHeadingTextStyle.copyWith(color: Colors.white),
                  ),
                  Text(
                    "Professor: ${widget.admin.firstName} ${widget.admin.lastName}",
                    style: kSubheadingTextStyle.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "What's on your mind, Professor?",
          style: kSubheadingTextStyle,
        ),
        const SizedBox(height: kSmallPadding),
        TextField(
          controller: _announcementController,
          maxLines: 4,
          style: TextStyle(
            color: Colors.black,
          ), // 👈 this sets user input color
          decoration: InputDecoration(
            hintText: "Type your announcement here...",
            hintStyle: TextStyle(color: Colors.black45),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kDefaultBorderRadius),
            ),
          ),
        ),
        const SizedBox(height: kSmallPadding),
        Row(
          children: [
            ElevatedButton(
              onPressed: _isPosting ? null : _postAnnouncement,
              style: ElevatedButton.styleFrom(backgroundColor: kAccentColor),
              child: Text(_isPosting ? "Posting..." : "Submit"),
            ),
            const SizedBox(width: kSmallPadding),
            TextButton(
              onPressed: () => _announcementController.clear(),
              child: const Text("Clear",style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnnouncementsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Class Announcements", style: kHeadingTextStyle),
        const SizedBox(height: kSmallPadding),
        StreamBuilder<List<AnnouncementModel>>(
          stream: _getAnnouncementsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final announcements = snapshot.data ?? [];
            if (announcements.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 32.0),
                  child: Text(
                    "No announcements or reminders yet.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                final announcement = announcements[index];
                final date = DateFormat.yMMMd().add_jm().format(
                  announcement.timestamp.toDate(),
                );

                return Card(
                  elevation: 8,
                  shadowColor: kComplementaryColor,
                  margin: const EdgeInsets.symmetric(vertical: kSmallPadding),
                  child: Padding(
                    padding: const EdgeInsets.all(kDefaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(announcement.text, style: kBodyTextStyle),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Posted by ${announcement.author}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              date,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: kSmallPadding),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18),
                              onPressed: () => _editAnnouncement(announcement),
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 18),
                              onPressed:
                                  () => _deleteAnnouncement(announcement.id),
                              tooltip: 'Delete',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _announcementController.dispose();
    super.dispose();
  }
}
