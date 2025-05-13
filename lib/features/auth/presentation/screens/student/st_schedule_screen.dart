import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:true_studentmgnt_mobapp/features/auth/data/models/admin_model.dart';
import 'package:true_studentmgnt_mobapp/features/auth/data/models/schedule_model.dart';
import 'package:true_studentmgnt_mobapp/features/auth/data/models/student_model.dart';
import 'package:true_studentmgnt_mobapp/features/auth/domain/helpers/schedule_helper.dart';

class StScheduleScreen extends StatefulWidget {
  static const String id = 'stschedule_screen';

  const StScheduleScreen({super.key});

  @override
  State<StScheduleScreen> createState() => _StScheduleScreenState();
}

class _StScheduleScreenState extends State<StScheduleScreen> {
  final ScheduleRepository _scheduleRepo = ScheduleRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _selectedDayIndex = DateTime.now().weekday - 1; // 0 = Monday, 6 = Sunday
  late Timer _timer;
  DateTime _selectedWeekStart = _getStartOfWeek(DateTime.now());
  bool _isLoading = true;
  List<ScheduleModel> _todaySchedules = [];
  Map<int, List<ScheduleModel>> _weeklySchedules = {};

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
    _loadSchedules();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  static DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  Future<void> _loadSchedules() async {
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
        });
        return;
      }

      // Get unique subjects from enrollments
      final subjects =
          enrollments.docs
              .map((doc) => doc.data()['subject'] as String)
              .toSet()
              .toList();

      // Load today's schedules
      final today = DateTime.now();
      final todaySchedules = await _fetchSchedulesForDate(today, subjects);

      // Load weekly schedules
      final weeklySchedules = await _fetchWeeklySchedules(subjects);

      setState(() {
        _todaySchedules = todaySchedules;
        _weeklySchedules = weeklySchedules;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading schedules: $e')));
    }
  }

  Future<List<ScheduleModel>> _fetchSchedulesForDate(
    DateTime date,
    List<String> subjects,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final querySnapshot =
        await _firestore
            .collection('schedules')
            .where('subject', whereIn: subjects)
            .where('date', isGreaterThanOrEqualTo: startOfDay)
            .where('date', isLessThanOrEqualTo: endOfDay)
            .where('status', isNotEqualTo: 'canceled')
            .orderBy('date')
            .orderBy('startTime')
            .get();

    return querySnapshot.docs
        .map((doc) => ScheduleModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<Map<int, List<ScheduleModel>>> _fetchWeeklySchedules(
    List<String> subjects,
  ) async {
    final Map<int, List<ScheduleModel>> weeklySchedules = {};
    final startOfWeek = _selectedWeekStart;

    for (int i = 0; i < 7; i++) {
      final dayDate = startOfWeek.add(Duration(days: i));
      final daySchedules = await _fetchSchedulesForDate(dayDate, subjects);
      weeklySchedules[i] = daySchedules;
    }

    return weeklySchedules;
  }

  String _getScheduleStatus(ScheduleModel schedule) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    try {
      final startTimeParts = schedule.startTime.split(' ');
      final timeParts = startTimeParts[0].split(':');
      int hours = int.parse(timeParts[0]);
      final minutes = int.parse(timeParts[1]);

      // Handle 12-hour format if present
      if (startTimeParts.length > 1) {
        if (startTimeParts[1] == 'PM' && hours != 12) {
          hours += 12;
        } else if (startTimeParts[1] == 'AM' && hours == 12) {
          hours = 0;
        }
      }

      final scheduleDateTime = today.add(
        Duration(hours: hours, minutes: minutes),
      );
      final endTimeParts = schedule.endTime.split(' ');
      final endTimePartsTime = endTimeParts[0].split(':');
      int endHours = int.parse(endTimePartsTime[0]);
      final endMinutes = int.parse(endTimePartsTime[1]);

      if (endTimeParts.length > 1) {
        if (endTimeParts[1] == 'PM' && endHours != 12) {
          endHours += 12;
        } else if (endTimeParts[1] == 'AM' && endHours == 12) {
          endHours = 0;
        }
      }

      final endDateTime = today.add(
        Duration(hours: endHours, minutes: endMinutes),
      );

      if (schedule.status == 'canceled') return 'canceled';
      if (now.isAfter(endDateTime)) return 'completed';
      if (now.isAfter(scheduleDateTime) && now.isBefore(endDateTime))
        return 'ongoing';
      return 'upcoming';
    } catch (e) {
      return 'upcoming'; // Default if time parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        title: Text(
          'My Schedule',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => _showDatePicker(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSchedules,
          ),
        ],
      ),
      body: Container(
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
        child: RefreshIndicator(
          color: theme.colorScheme.primary,
          onRefresh: _loadSchedules,
          child:
              _isLoading
                  ? _buildLoadingView()
                  : SingleChildScrollView(
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
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(child: CircularProgressIndicator());
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
              Icon(Icons.event, color: theme.colorScheme.secondary),
              const SizedBox(width: 8),
              Text('Today\'s Schedule', style: theme.textTheme.titleLarge),
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
          _todaySchedules.isEmpty
              ? _buildEmptyScheduleCard(theme, 'No classes scheduled for today')
              : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _todaySchedules.length,
                itemBuilder: (context, index) {
                  final schedule = _todaySchedules[index];
                  final status = _getScheduleStatus(schedule);
                  return _buildScheduleCard(schedule, status, theme);
                },
              ),
        ],
      ),
    );
  }

  Widget _buildWeeklyScheduleSection(ThemeData theme) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final today = DateTime.now();

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
                  Text('Weekly View', style: theme.textTheme.titleLarge),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      setState(() {
                        _selectedWeekStart = _selectedWeekStart.subtract(
                          const Duration(days: 7),
                        );
                        _loadSchedules();
                      });
                    },
                  ),
                  Text(
                    'Week ${_selectedWeekStart.day}/${_selectedWeekStart.month}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      setState(() {
                        _selectedWeekStart = _selectedWeekStart.add(
                          const Duration(days: 7),
                        );
                        _loadSchedules();
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(7, (index) {
                final dayDate = _selectedWeekStart.add(Duration(days: index));
                final isToday =
                    dayDate.day == today.day &&
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
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _selectedDayIndex == index
                              ? theme.colorScheme.primary
                              : isToday
                              ? theme.colorScheme.primary.withOpacity(0.1)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isToday || _selectedDayIndex == index
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onBackground.withOpacity(
                                  0.2,
                                ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          days[index],
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color:
                                _selectedDayIndex == index
                                    ? theme.colorScheme.onPrimary
                                    : isToday
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onBackground,
                            fontWeight:
                                isToday || _selectedDayIndex == index
                                    ? FontWeight.bold
                                    : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dayDate.day.toString(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color:
                                _selectedDayIndex == index
                                    ? theme.colorScheme.onPrimary
                                    : isToday
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onBackground,
                            fontWeight:
                                isToday || _selectedDayIndex == index
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
          const SizedBox(height: 16),
          _weeklySchedules[_selectedDayIndex]?.isEmpty ?? true
              ? _buildEmptyScheduleCard(
                theme,
                'No classes scheduled for this day',
              )
              : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _weeklySchedules[_selectedDayIndex]?.length ?? 0,
                itemBuilder: (context, index) {
                  final schedule = _weeklySchedules[_selectedDayIndex]![index];
                  return _buildScheduleCard(schedule, 'upcoming', theme);
                },
              ),
        ],
      ),
    );
  }

  Widget _buildEmptyScheduleCard(ThemeData theme, String message) {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: theme.colorScheme.secondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(message, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Enjoy your free time!', style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(
    ScheduleModel schedule,
    String status,
    ThemeData theme,
  ) {
    // Determine status color
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
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
    if (status == 'upcoming') {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      try {
        final startTimeParts = schedule.startTime.split(' ');
        final timeParts = startTimeParts[0].split(':');
        int hours = int.parse(timeParts[0]);
        final minutes = int.parse(timeParts[1]);

        // Handle 12-hour format if present
        if (startTimeParts.length > 1) {
          if (startTimeParts[1] == 'PM' && hours != 12) {
            hours += 12;
          } else if (startTimeParts[1] == 'AM' && hours == 12) {
            hours = 0;
          }
        }

        final startTime = today.add(Duration(hours: hours, minutes: minutes));
        final difference = startTime.difference(now);

        if (difference.inHours > 0) {
          timeText =
              '${difference.inHours}h ${difference.inMinutes % 60}m remaining';
        } else if (difference.inMinutes > 0) {
          timeText =
              '${difference.inMinutes}m ${difference.inSeconds % 60}s remaining';
        } else {
          timeText = '${difference.inSeconds}s remaining';
        }
      } catch (e) {
        timeText = 'Time not available';
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withOpacity(0.3),
          width: status == 'ongoing' ? 2 : 1,
        ),
      ),
      elevation: status == 'ongoing' ? 4 : 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
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
                  '${schedule.startTime} - ${schedule.endTime}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              schedule.subject,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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
                Text(schedule.room, style: theme.textTheme.bodyMedium),
              ],
            ),
            if (status == 'upcoming') ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer, size: 16, color: Colors.orange),
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
            if (status == 'canceled') ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Colors.red),
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
            if (status == 'upcoming' || status == 'ongoing')
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
                        foregroundColor: Colors.white,
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

  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedWeekStart = _getStartOfWeek(picked);
        _selectedDayIndex = picked.weekday - 1;
        _loadSchedules();
      });
    }
  }
}
