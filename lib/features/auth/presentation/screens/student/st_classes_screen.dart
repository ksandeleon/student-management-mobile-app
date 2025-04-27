import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StClassesScreen extends StatefulWidget {
  static const String id = 'stclasses_screen';

  const StClassesScreen({super.key});

  @override
  State<StClassesScreen> createState() => _StClassesScreenState();
}

class _StClassesScreenState extends State<StClassesScreen> {
  // Mock data for classes (would come from API in real app)
  final List<Map<String, dynamic>> _classes = [
    {
      'id': '1',
      'name': 'Introduction to Computer Science',
      'professor': 'Dr. Jane Smith',
      'isActive': true,
      'assignments': 3,
      'assignmentsList': [
        {
          'title': 'Algorithm Analysis',
          'dueDate': '2025-05-10',
          'completed': false,
        },
        {
          'title': 'Data Structures Quiz',
          'dueDate': '2025-05-05',
          'completed': true,
        },
        {
          'title': 'Binary Tree Implementation',
          'dueDate': '2025-05-15',
          'completed': false,
        },
      ]
    },
    {
      'id': '2',
      'name': 'Calculus II',
      'professor': 'Dr. Michael Johnson',
      'isActive': false,
      'assignments': 2,
      'assignmentsList': [
        {
          'title': 'Integration Techniques',
          'dueDate': '2025-05-08',
          'completed': false,
        },
        {
          'title': 'Series and Sequences',
          'dueDate': '2025-05-20',
          'completed': false,
        },
      ]
    },
    {
      'id': '3',
      'name': 'Digital Electronics',
      'professor': 'Prof. Robert Chen',
      'isActive': true,
      'assignments': 4,
      'assignmentsList': [
        {
          'title': 'Logic Gates Lab',
          'dueDate': '2025-05-03',
          'completed': true,
        },
        {
          'title': 'Flip-Flop Circuits',
          'dueDate': '2025-05-12',
          'completed': false,
        },
        {
          'title': 'Karnaugh Maps',
          'dueDate': '2025-05-18',
          'completed': false,
        },
        {
          'title': 'Microprocessor Design',
          'dueDate': '2025-05-25',
          'completed': false,
        },
      ]
    },
    {
      'id': '4',
      'name': 'World Literature',
      'professor': 'Prof. Sarah Williams',
      'isActive': false,
      'assignments': 1,
      'assignmentsList': [
        {
          'title': 'Comparative Essay',
          'dueDate': '2025-05-23',
          'completed': false,
        },
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Classes',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
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
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Implement notification functionality
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: theme.colorScheme.primary,
        onRefresh: () async {
          // Implement refresh functionality
          await Future.delayed(const Duration(seconds: 1));
        },
        child: _classes.isEmpty
            ? _buildEmptyClassesView(theme)
            : _buildClassesListView(theme),
      ),
    );
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
          Text(
            'No classes yet',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Your enrolled classes will appear here',
            style: theme.textTheme.bodyMedium,
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

  Widget _buildClassCard(Map<String, dynamic> classData, ThemeData theme, BuildContext context) {
    return Hero(
      tag: 'class-${classData['id']}',
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
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
                        classData['name'],
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (classData['isActive'])
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 4,
                              spreadRadius: 1,
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
                      classData['professor'],
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (classData['isActive'])
                      Row(
                        children: [
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Active',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 16,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${classData['assignments']} Assignment${classData['assignments'] > 1 ? 's' : ''}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _showAssignmentsSheet(context, classData, theme);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.visibility),
                        const SizedBox(width: 8),
                        Text('View Assignments'),
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

  void _showAssignmentsSheet(BuildContext context, Map<String, dynamic> classData, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AssignmentsBottomSheet(classData: classData),
    );
  }
}

class AssignmentsBottomSheet extends StatelessWidget {
  final Map<String, dynamic> classData;

  const AssignmentsBottomSheet({Key? key, required this.classData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Map<String, dynamic>> assignments = List<Map<String, dynamic>>.from(classData['assignmentsList']);

    // Sort assignments by due date (soonest first)
    assignments.sort((a, b) => a['dueDate'].compareTo(b['dueDate']));

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.class_outlined,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Assignments for ${classData['name']}',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Assignments list
              Expanded(
                child: assignments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 64,
                              color: theme.colorScheme.secondary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No assignments yet',
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: assignments.length,
                        itemBuilder: (context, index) {
                          final assignment = assignments[index];

                          // Parse due date
                          final dueDate = DateTime.parse(assignment['dueDate']);
                          final now = DateTime.now();
                          final isOverdue = dueDate.isBefore(now) && !assignment['completed'];
                          final isToday = dueDate.year == now.year &&
                                        dueDate.month == now.month &&
                                        dueDate.day == now.day;

                          // Format date for display
                          final formattedDate = '${dueDate.day}/${dueDate.month}/${dueDate.year}';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: assignment['completed']
                                    ? Colors.green.withOpacity(0.5)
                                    : isOverdue
                                        ? Colors.red.withOpacity(0.5)
                                        : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        assignment['completed']
                                            ? Icons.check_circle
                                            : Icons.assignment_outlined,
                                        color: assignment['completed']
                                            ? Colors.green
                                            : isOverdue
                                                ? Colors.red
                                                : theme.colorScheme.secondary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          assignment['title'],
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            decoration: assignment['completed']
                                                ? TextDecoration.lineThrough
                                                : null,
                                            color: assignment['completed']
                                                ? theme.textTheme.bodyMedium?.color?.withOpacity(0.7)
                                                : theme.textTheme.titleMedium?.color,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: 16,
                                            color: isOverdue
                                                ? Colors.red
                                                : isToday
                                                    ? Colors.orange
                                                    : theme.colorScheme.secondary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Due: $formattedDate',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: isOverdue
                                                  ? Colors.red
                                                  : isToday
                                                      ? Colors.orange
                                                      : theme.textTheme.bodySmall?.color,
                                              fontWeight: isOverdue || isToday
                                                  ? FontWeight.bold
                                                  : null,
                                            ),
                                          ),
                                          if (isOverdue)
                                            Container(
                                              margin: const EdgeInsets.only(left: 8),
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'OVERDUE',
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          if (isToday && !isOverdue && !assignment['completed'])
                                            Container(
                                              margin: const EdgeInsets.only(left: 8),
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'TODAY',
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: Colors.orange,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: assignment['completed']
                                              ? Colors.green.withOpacity(0.1)
                                              : theme.colorScheme.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          assignment['completed'] ? 'Completed' : 'Pending',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: assignment['completed']
                                                ? Colors.green
                                                : theme.colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  if (!assignment['completed'])
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // Handle "Do Assignment" button press
                                          Navigator.pop(context);
                                          // Navigate to assignment page (placeholder)
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Opening ${assignment['title']}'),
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: theme.colorScheme.primary,
                                          foregroundColor: theme.colorScheme.onPrimary,
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                        ),
                                        child: const Text('Do Assignment'),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
