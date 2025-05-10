import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

// App Colors for easier preview without constants.dart
const Color kPrimaryColor = Color(0xFF210F37);
const Color kSecondaryColor = Color(0xFF4F1C51);
const Color kAccentColor = Color(0xFFA55B4B);
const Color kComplementaryColor = Color(0xFFDCA06D);

// Text Styles
const TextStyle kHeadingTextStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
);

const TextStyle kSubheadingTextStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w600,
);

const TextStyle kBodyTextStyle = TextStyle(
  fontSize: 16,
);

// Spacing
const double kDefaultPadding = 16.0;
const double kSmallPadding = 8.0;
const double kLargePadding = 24.0;

// Border Radius
const double kDefaultBorderRadius = 8.0;
const double kLargeBorderRadius = 16.0;

// Models with defaults for easier preview
class ClassAnnouncement {
  final String content;
  final DateTime timestamp;
  final String professorName;

  ClassAnnouncement({
    this.content = "Sample announcement content. This is what an announcement would look like when posted by a professor.",
    DateTime? timestamp,
    this.professorName = "John Smith",
  }) : timestamp = timestamp ?? DateTime.now();
}

class Student {
  final String name;
  final String id;
  final String? avatarUrl;

  Student({
    this.name = "Student Name",
    this.id = "ID12345",
    this.avatarUrl,
  });
}

class ClassScreen extends StatefulWidget {
  static const String id = 'class_screen';

  final String className;
  final String classCode;
  final String professorName;
  final List<Student> enrolledStudents;

  // Constructor with default values for easier preview
  const ClassScreen({
    Key? key,
    this.className = "Introduction to Computer Science",
    this.classCode = "CS101",
    this.professorName = "Prof. John Smith",
    this.enrolledStudents = const [],
  }) : super(key: key);

  @override
  _ClassScreenState createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen> {
  // List to store announcements with sample data for preview
  List<ClassAnnouncement> announcements = [
    ClassAnnouncement(
      content: "Welcome to the class! Please make sure to review the syllabus available on the course portal.",
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      professorName: "Prof. John Smith",
    ),
    ClassAnnouncement(
      content: "Reminder: Assignment 1 is due this Friday by 11:59 PM. Let me know if you have any questions!",
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      professorName: "Prof. John Smith",
    ),
    ClassAnnouncement(
      content: "Office hours today are cancelled. I'll be available tomorrow from 2-4 PM instead.",
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      professorName: "Prof. John Smith",
    ),
  ];

  // Controller for the announcement text field
  final TextEditingController _announcementController = TextEditingController();

  // Scaffold key to control the drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Sample enrolled students data for preview
  List<Student> get _sampleStudents {
    if (widget.enrolledStudents.isNotEmpty) return widget.enrolledStudents;

    return [
      Student(name: "Alex Johnson", id: "SID22001"),
      Student(name: "Jamie Smith", id: "SID22002"),
      Student(name: "Taylor Brown", id: "SID22003"),
      Student(name: "Casey Garcia", id: "SID22004"),
      Student(name: "Jordan Lee", id: "SID22005"),
      Student(name: "Quinn Wilson", id: "SID22006"),
      Student(name: "Riley Martinez", id: "SID22007"),
      Student(name: "Morgan Thompson", id: "SID22008"),
    ];
  }

  @override
  void dispose() {
    _announcementController.dispose();
    super.dispose();
  }

  // Method to add a new announcement
  void _addAnnouncement(String content) {
    if (content.trim().isNotEmpty) {
      setState(() {
        announcements.add(
          ClassAnnouncement(
            content: content.trim(),
            timestamp: DateTime.now(),
            professorName: widget.professorName,
          ),
        );
      });
      _announcementController.clear();
    }
  }

  // Method to show the announcement input dialog
  void _showAnnouncementDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Announcement'),
        content: TextField(
          controller: _announcementController,
          decoration: const InputDecoration(
            hintText: "What's on your mind, professor?",
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
        ),
        actions: [
          // Clear button
          TextButton(
            onPressed: () {
              _announcementController.clear();
            },
            child: const Text('CLEAR'),
          ),
          // Submit button
          ElevatedButton(
            onPressed: () {
              _addAnnouncement(_announcementController.text);
              Navigator.pop(context);
            },
            child: const Text('POST'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // App bar with class code and menu button
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          "Class Code: ${widget.classCode}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          // Additional action buttons if needed
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // Show more options - sample dialog for preview
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(kLargeBorderRadius)),
                ),
                builder: (context) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: kLargePadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.assignment, color: kPrimaryColor),
                        title: const Text('Manage Assignments'),
                        onTap: () => Navigator.pop(context),
                      ),
                      ListTile(
                        leading: const Icon(Icons.people, color: kPrimaryColor),
                        title: const Text('Manage Enrollment'),
                        onTap: () => Navigator.pop(context),
                      ),
                      ListTile(
                        leading: const Icon(Icons.grade, color: kPrimaryColor),
                        title: const Text('Grade Book'),
                        onTap: () => Navigator.pop(context),
                      ),
                      ListTile(
                        leading: const Icon(Icons.settings, color: kPrimaryColor),
                        title: const Text('Class Settings'),
                        onTap: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),

      // Side drawer with enrolled students
      drawer: Drawer(
        child: Column(
          children: [
            // Drawer header
            DrawerHeader(
              decoration: const BoxDecoration(color: kPrimaryColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enrolled Students',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: kSmallPadding),
                  Text(
                    '${_sampleStudents.length} students',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),

            // List of enrolled students
            Expanded(
              child: ListView.builder(
                itemCount: _sampleStudents.length,
                itemBuilder: (context, index) {
                  final Student student = _sampleStudents[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: kSecondaryColor,
                      backgroundImage:
                          student.avatarUrl != null
                              ? NetworkImage(student.avatarUrl!)
                              : null,
                      child:
                          student.avatarUrl == null
                              ? Text(
                                student.name[0],
                                style: const TextStyle(color: Colors.white),
                              )
                              : null,
                    ),
                    title: Text(student.name),
                    subtitle: Text('ID: ${student.id}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.mail_outline),
                      onPressed: () {
                        // Message student functionality (preview only)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Message to ${student.name}')),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Body of the class screen
      body: Column(
        children: [
          // Hero class card with class name and professor
          Hero(
            tag: 'class_${widget.classCode}',
            child: Card(
              margin: const EdgeInsets.all(kDefaultPadding),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kLargeBorderRadius),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(kLargePadding),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kPrimaryColor, kSecondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(kLargeBorderRadius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.className,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: kSmallPadding),
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          color: kComplementaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Professor: ${widget.professorName}",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: kComplementaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Spring Semester 2025",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Announcement input prompt
          InkWell(
            onTap: _showAnnouncementDialog,
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: kDefaultPadding,
                vertical: kSmallPadding,
              ),
              padding: const EdgeInsets.all(kDefaultPadding),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(kDefaultBorderRadius),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: kSecondaryColor,
                    child: Text(
                      widget.professorName[0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: kDefaultPadding),
                  const Expanded(
                    child: Text(
                      "What's on your mind, professor?",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                  const Icon(Icons.edit, color: kAccentColor),
                ],
              ),
            ),
          ),

          // Section title for announcements
          Padding(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.announcement, color: kSecondaryColor),
                    SizedBox(width: kSmallPadding),
                    Text("Class Announcements", style: kSubheadingTextStyle),
                  ],
                ),
                // Filter option for demonstration
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: const [
                      Text("Latest", style: TextStyle(fontSize: 12)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_drop_down, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // List of announcements or empty state
          Expanded(
            child:
                announcements.isEmpty
                    // Empty state
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.speaker_notes_off,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: kDefaultPadding),
                          Text(
                            "No announcements or reminders yet",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: kSmallPadding),
                          Text(
                            "Posted announcements will appear here",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                    // List of announcements
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kDefaultPadding,
                      ),
                      itemCount: announcements.length,
                      itemBuilder: (context, index) {
                        // Display in reverse chronological order (newest first)
                        final announcement =
                            announcements[announcements.length - 1 - index];
                        return _buildAnnouncementCard(announcement);
                      },
                    ),
          ),
        ],
      ),

      // Floating action button for quick announcement
      floatingActionButton: FloatingActionButton(
        onPressed: _showAnnouncementDialog,
        backgroundColor: kAccentColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Helper method to build announcement cards
  Widget _buildAnnouncementCard(ClassAnnouncement announcement) {
    // Format the date for display
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');
    final formattedDate = dateFormat.format(announcement.timestamp);

    return Card(
      margin: const EdgeInsets.only(bottom: kDefaultPadding),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with professor info and timestamp
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: kSecondaryColor,
                  radius: 20,
                  child: Text(
                    announcement.professorName[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: kSmallPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        announcement.professorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Add popup menu for post options
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, size: 20),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'pin',
                      child: Text('Pin to top'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                  onSelected: (value) {
                    // Actions for demonstration purposes
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Selected: $value')),
                    );
                  },
                )
              ],
            ),

            const Divider(height: 24),

            // Announcement content
            // Using SelectableText to enable copying and link detection
            SelectableText(
              announcement.content,
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: kDefaultPadding),

            // Action buttons for the announcement
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Comment button (for demonstration)
                TextButton.icon(
                  onPressed: () {
                    // Show comment dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Comment feature')),
                    );
                  },
                  icon: const Icon(Icons.comment_outlined, size: 16),
                  label: const Text("Comment"),
                ),
                const SizedBox(width: 8),
                // Details button
                TextButton.icon(
                  onPressed: () {
                    // Show full announcement or take other action
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('View details')),
                    );
                  },
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text("Details"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
