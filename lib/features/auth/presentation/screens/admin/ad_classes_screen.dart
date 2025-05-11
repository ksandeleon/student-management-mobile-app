import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:true_studentmgnt_mobapp/config/constants.dart';
import 'package:true_studentmgnt_mobapp/features/auth/data/models/admin_model.dart';
import 'package:true_studentmgnt_mobapp/features/auth/data/models/student_model.dart';


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

  Future<void> _postAnnouncement() async {
    if (_announcementController.text.trim().isEmpty) return;
    setState(() => _isPosting = true);

    await FirebaseFirestore.instance.collection('announcements').add({
      'text': _announcementController.text.trim(),
      'author': '${widget.admin.firstName} ${widget.admin.lastName}',
      'timestamp': FieldValue.serverTimestamp(),
      'adminId': widget.admin.uid,
      'subject': widget.admin.jobTitle,
    });

    _announcementController.clear();
    setState(() => _isPosting = false);
  }

  Future<List<StudentModel>> _fetchStudents() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('students').get();
    return querySnapshot.docs.map((doc) => StudentModel.fromMap(doc.data(), docId: doc.id)).toList();
  }

  Stream<QuerySnapshot> _getAnnouncements() {
    return FirebaseFirestore.instance
        .collection('announcements')
        .where('adminId', isEqualTo: widget.admin.uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: FutureBuilder<List<StudentModel>>(
          future: _fetchStudents(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
            final students = snapshot.data!;
            return ListView(
              padding: EdgeInsets.all(kDefaultPadding),
              children: [
                Text("Enrolled Students", style: kHeadingTextStyle),
                ...students.map((student) => ListTile(
                      title: Text("${student.firstName} ${student.lastName}"),
                      subtitle: Text(student.email),
                      leading: Icon(Icons.person_outline),
                    )),
              ],
            );
          },
        ),
      ),
      appBar: AppBar(
        title: Text("Classroom"),
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Subject Card
            Card(
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
                    Icon(Icons.class_, size: 48, color: Colors.white),
                    SizedBox(width: kDefaultPadding),
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
                    )
                  ],
                ),
              ),
            ),

            SizedBox(height: kLargePadding),

            // Announcement Input
            Text(
              "What's on your mind, Professor?",
              style: kSubheadingTextStyle,
            ),
            SizedBox(height: kSmallPadding),
            TextField(
              controller: _announcementController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Type your announcement here...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(kDefaultBorderRadius),
                ),
              ),
            ),
            SizedBox(height: kSmallPadding),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isPosting ? null : _postAnnouncement,
                  style: ElevatedButton.styleFrom(backgroundColor: kAccentColor),
                  child: Text(_isPosting ? "Posting..." : "Submit"),
                ),
                SizedBox(width: kSmallPadding),
                TextButton(
                  onPressed: () => _announcementController.clear(),
                  child: Text("Clear"),
                ),
              ],
            ),

            SizedBox(height: kLargePadding),

            // Announcements List
            Text(
              "Class Announcements",
              style: kHeadingTextStyle,
            ),
            SizedBox(height: kSmallPadding),
            StreamBuilder<QuerySnapshot>(
              stream: _getAnnouncements(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                final announcements = snapshot.data!.docs;
                if (announcements.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 32.0),
                      child: Text(
                        "No announcements or reminders yet.",
                        style: kBodyTextStyle.copyWith(color: Colors.grey),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: announcements.length,
                  itemBuilder: (context, index) {
                    final data = announcements[index].data() as Map<String, dynamic>;
                    final date = data['timestamp'] != null
                        ? DateFormat.yMMMd().add_jm().format((data['timestamp'] as Timestamp).toDate())
                        : "Unknown time";
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: kSmallPadding),
                      child: Padding(
                        padding: const EdgeInsets.all(kDefaultPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['text'], style: kBodyTextStyle),
                            SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Posted by ${data['author']}",
                                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                                Text(date, style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
