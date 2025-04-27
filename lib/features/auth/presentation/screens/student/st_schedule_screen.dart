import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class StScheduleScreen extends StatefulWidget {
  static const String id = 'stschedule_screen';

  const StScheduleScreen({super.key});

  @override
  State<StScheduleScreen> createState() => _StScheduleScreenState();
}

class _StScheduleScreenState extends State<StScheduleScreen> {
  // Selected day for the weekly view
  int _selectedDayIndex = DateTime.now().weekday - 1; // 0 = Monday, 6 = Sunday
  late Timer _timer;

  // Mock data for today's classes
  final List<Map<String, dynamic>> _todayClasses = [
    {
      'id': '1',
      'name': 'Introduction to Computer Science',
      'professor': 'Dr. Jane Smith',
      'startTime': '09:00',
      'endTime': '10:30',
      'location': 'Room 101, Building A',
      'status': 'completed', // completed, ongoing, upcoming, canceled
    },
    {
      'id': '2',
      'name': 'Calculus II',
      'professor': 'Dr. Michael Johnson',
      'startTime': '11:00',
      'endTime': '12:30',
      'location': 'Room 205, Building C',
      'status': 'ongoing',
    },
    {
      'id': '3',
      'name': 'Digital Electronics',
      'professor': 'Prof. Robert Chen',
      'startTime': '14:00',
      'endTime': '15:30',
      'location': 'Lab 3, Engineering Block',
      'status': 'upcoming',
    },
    {
      'id': '4',
      'name': 'World Literature',
      'professor': 'Prof. Sarah Williams',
      'startTime': '16:00',
      'endTime': '17:30',
      'location': 'Room 110, Arts Building',
      'status': 'canceled',
    },
  ];

  // Mock data for weekly schedule
  final List<List<Map<String, dynamic>>> _weeklySchedule = [
    // Monday
    [
      {
        'name': 'Calculus II',
        'startTime': '09:00',
        'endTime': '10:30',
        'color': Colors.blue,
      },
      {
        'name': 'World Literature',
        'startTime': '13:00',
        'endTime': '14:30',
        'color': Colors.purple,
      },
    ],
    // Tuesday
    [
      {
        'name': 'Intro to CS',
        'startTime': '10:00',
        'endTime': '11:30',
        'color': Colors.green,
      },
      {
        'name': 'Digital Electronics',
        'startTime': '14:00',
        'endTime': '16:30',
        'color': Colors.orange,
      },
    ],
    // Wednesday
    [
      {
        'name': 'Calculus II',
        'startTime': '09:00',
        'endTime': '10:30',
        'color': Colors.blue,
      },
      {
        'name': 'Psychology',
        'startTime': '11:00',
        'endTime': '12:30',
        'color': Colors.red,
      },
    ],
    // Thursday
    [
      {
        'name': 'Intro to CS',
        'startTime': '10:00',
        'endTime': '11:30',
        'color': Colors.green,
      },
      {
        'name': 'Digital Electronics',
        'startTime': '14:00',
        'endTime': '16:30',
        'color': Colors.orange,
      },
    ],
    // Friday
    [
      {
        'name': 'World Literature',
        'startTime': '13:00',
        'endTime': '14:30',
        'color': Colors.purple,
      },
      {
        'name': 'Psychology',
        'startTime': '15:00',
        'endTime': '16:30',
        'color': Colors.red,
      },
    ],
    // Saturday
    [],
    // Sunday
    [],
  ];

  @override
  void initState() {
    super.initState();
    // Set up a timer to update countdowns every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Schedule',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              // Implement calendar view
              _showDatePicker(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Implement filter functionality
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTodaySection(theme),
              const SizedBox(height: 20),
              _buildWeeklyScheduleSection(theme),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add or modify schedule
        },
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTodaySection(ThemeData theme) {
    final today = DateTime.now();
    final dateFormat = DateFormat('EEEE, MMMM d');

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Today\'s Schedule',
                style: theme.textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            dateFormat.format(today),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          _todayClasses.isEmpty
              ? Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 64,
                        color: theme.colorScheme.secondary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No classes scheduled for today',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enjoy your free time!',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _todayClasses.length,
                  itemBuilder: (context, index) {
                    return _buildClassCard(_todayClasses[index], theme);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildClassCard(Map<String, dynamic> classData, ThemeData theme) {
    // Determine status color
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (classData['status']) {
      case 'completed':
        statusColor = Colors.grey;
        statusText = 'Completed';
        statusIcon = Icons.check_circle;
        break;
      case 'ongoing':
        statusColor = Colors.green;
        statusText = 'Ongoing';
        statusIcon = Icons.play_circle_filled;
        break;
      case 'upcoming':
        statusColor = Colors.orange;
        statusText = 'Upcoming';
        statusIcon = Icons.access_time;
        break;
      case 'canceled':
        statusColor = Colors.red;
        statusText = 'Canceled';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Unknown';
        statusIcon = Icons.help;
    }

    // Calculate remaining time for upcoming classes
    String timeText = '';
    if (classData['status'] == 'upcoming') {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final startTimeParts = classData['startTime'].split(':');
      final startHour = int.parse(startTimeParts[0]);
      final startMinute = int.parse(startTimeParts[1]);
      final startTime = today.add(Duration(hours: startHour, minutes: startMinute));

      final difference = startTime.difference(now);
      if (difference.inHours > 0) {
        timeText = '${difference.inHours}h ${difference.inMinutes % 60}m remaining';
      } else if (difference.inMinutes > 0) {
        timeText = '${difference.inMinutes}m ${difference.inSeconds % 60}s remaining';
      } else {
        timeText = '${difference.inSeconds}s remaining';
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withOpacity(0.3),
          width: classData['status'] == 'ongoing' ? 2 : 1,
        ),
      ),
      elevation: classData['status'] == 'ongoing' ? 4 : 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        size: 16,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '${classData['startTime']} - ${classData['endTime']}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              classData['name'],
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
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
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  classData['location'],
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            if (classData['status'] == 'upcoming') ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.timer,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (classData['status'] == 'canceled') ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Class has been canceled',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (classData['status'] == 'upcoming' || classData['status'] == 'ongoing')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Navigate to class details
                      },
                      icon: const Icon(Icons.details),
                      label: const Text('Details'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        side: BorderSide(color: theme.colorScheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Join the class
                      },
                      icon: const Icon(Icons.login),
                      label: const Text('Join Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyScheduleSection(ThemeData theme) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_view_week,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Weekly View',
                    style: theme.textTheme.titleLarge,
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      // Navigate to previous week
                    },
                  ),
                  Text(
                    'This Week',
                    style: theme.textTheme.bodyMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      // Navigate to next week
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Days of the week selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(7, (index) {
                final dayDate = startOfWeek.add(Duration(days: index));
                final isToday = dayDate.day == today.day &&
                                dayDate.month == today.month &&
                                dayDate.year == today.year;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDayIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: _selectedDayIndex == index
                          ? theme.colorScheme.primary
                          : isToday
                              ? theme.colorScheme.primary.withOpacity(0.1)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isToday || _selectedDayIndex == index
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onBackground.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          days[index],
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _selectedDayIndex == index
                                ? theme.colorScheme.onPrimary
                                : isToday
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onBackground,
                            fontWeight: isToday || _selectedDayIndex == index
                                ? FontWeight.bold
                                : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dayDate.day.toString(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: _selectedDayIndex == index
                                ? theme.colorScheme.onPrimary
                                : isToday
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onBackground,
                            fontWeight: isToday || _selectedDayIndex == index
                                ? FontWeight.bold
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
          // Schedule timeline view
          _buildDayScheduleView(theme),
        ],
      ),
    );
  }

  Widget _buildDayScheduleView(ThemeData theme) {
    final selectedDayClasses = _weeklySchedule[_selectedDayIndex];

    if (selectedDayClasses.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 48,
              color: theme.colorScheme.secondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No classes on this day',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    // Time slots from 8:00 to 18:00
    final timeSlots = List.generate(11, (index) => '${index + 8}:00');

    return Column(
      children: [
        // Header with hour markers
        Row(
          children: [
            // Left padding for labels
            SizedBox(
              width: 50,
              child: Text(
                'Time',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Container(
                height: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: timeSlots.map((time) {
                    return SizedBox(
                      width: 30,
                      child: Text(
                        time.split(':')[0],
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Timeline grid
        Container(
          height: 80,
          child: Row(
            children: [
              // Time labels column
              SizedBox(
                width: 50,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AM',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      'PM',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              // Schedule timeline
              Expanded(
                child: Stack(
                  children: [
                    // Background grid lines
                    ...List.generate(timeSlots.length, (index) {
                      return Positioned(
                        left: (index / (timeSlots.length - 1)) * 100 ,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 1,
                          color: theme.colorScheme.onBackground.withOpacity(0.1),
                        ),
                      );
                    }),
                    // Classes
                    ...selectedDayClasses.map((classData) {
                      // Parse class start and end times
                      final startTimeParts = classData['startTime'].split(':');
                      final endTimeParts = classData['endTime'].split(':');
                      final startHour = int.parse(startTimeParts[0]);
                      final endHour = int.parse(endTimeParts[0]);
                      final startMinute = int.parse(startTimeParts[1]);
                      final endMinute = int.parse(endTimeParts[1]);

                      // Convert to positions (8:00 = 0.0, 18:00 = 1.0)
                      final startPosition = (startHour - 8 + startMinute / 60) / 10;
                      final endPosition = (endHour - 8 + endMinute / 60) / 10;
                      final width = endPosition - startPosition;

                      return Positioned(
                        left: startPosition * 100,
                        width: width * 100,
                        top: 10,
                        height: 60,
                        child: Container(
                          decoration: BoxDecoration(
                            color: (classData['color'] as Color).withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                classData['name'],
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${classData['startTime']} - ${classData['endTime']}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    // Current time indicator
                    _buildCurrentTimeIndicator(theme),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Detailed class list for selected day
        ...selectedDayClasses.map((classData) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: (classData['color'] as Color).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: ListTile(
              leading: Container(
                width: 8,
                decoration: BoxDecoration(
                  color: classData['color'] as Color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
              ),
              title: Text(
                classData['name'],
                style: theme.textTheme.titleMedium,
              ),
              subtitle: Text(
                '${classData['startTime']} - ${classData['endTime']}',
                style: theme.textTheme.bodyMedium,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.navigate_next),
                onPressed: () {
                  // Navigate to class details
                },
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCurrentTimeIndicator(ThemeData theme) {
    final now = DateTime.now();
    if (now.weekday - 1 != _selectedDayIndex) {
      return const SizedBox.shrink();
    }

    // Calculate position (8:00 = 0.0, 18:00 = 1.0)
    final position = (now.hour - 8 + now.minute / 60) / 10;
    if (position < 0 || position > 1) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: position * 100,
      top: 0,
      bottom: 0,
      child: Container(
        width: 2,
        color: Colors.red,
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -6,
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker(BuildContext context) async {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 90)),
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
              onPrimary: theme.colorScheme.onPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected != null) {
      // Calculate the week day index
      final dayIndex = selected.weekday - 1;
      setState(() {
        _selectedDayIndex = dayIndex;
      });
    }
  }
}
