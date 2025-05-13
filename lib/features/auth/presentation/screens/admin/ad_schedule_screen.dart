import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:true_studentmgnt_mobapp/config/constants.dart';
import 'package:true_studentmgnt_mobapp/features/auth/data/models/admin_model.dart';
import 'package:true_studentmgnt_mobapp/features/auth/data/models/schedule_model.dart';
import 'package:true_studentmgnt_mobapp/features/auth/domain/helpers/schedule_helper.dart';

class AdScheduleScreen extends StatefulWidget {
  final AdminModel admin;

  const AdScheduleScreen({Key? key, required this.admin}) : super(key: key);

  @override
  State<AdScheduleScreen> createState() => _AdScheduleScreenState();
}

class _AdScheduleScreenState extends State<AdScheduleScreen> {
  final ScheduleRepository _repository = ScheduleRepository();
  final _formKey = GlobalKey<FormState>();
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late String _room;
  late String _status;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = TimeOfDay.now();
    _startTime = now;
    _endTime = now.replacing(
      hour: (now.hour + 1) % 24, // Ensure valid hour
      minute: now.minute,
    );
    _room = '';
    _status = 'scheduled';
    _selectedDate = DateTime.now();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Update the time selection methods to ensure valid times
  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final initialTime = isStartTime ? _startTime : _endTime;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
          // Ensure end time is after start time
          if (_endTime.hour < picked.hour ||
              (_endTime.hour == picked.hour &&
                  _endTime.minute <= picked.minute)) {
            _endTime = picked.replacing(
              hour: picked.hour + 1,
              minute: picked.minute,
            );
          }
        } else {
          // Validate end time is after start time
          if (picked.hour > _startTime.hour ||
              (picked.hour == _startTime.hour &&
                  picked.minute > _startTime.minute)) {
            _endTime = picked;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('End time must be after start time'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour =
        time.hourOfPeriod == 0
            ? 12
            : time.hourOfPeriod; // Handle 12-hour format
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _addSchedule() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final startTimeStr = _formatTimeOfDay(_startTime);
      final endTimeStr = _formatTimeOfDay(_endTime);

      try {
        final hasConflict = await _repository.checkScheduleConflict(
          subject: widget.admin.jobTitle ?? '',
          room: _room,
          date: _selectedDate,
          startTime: startTimeStr,
          endTime: endTimeStr,
        );

        if (hasConflict) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Schedule conflict detected!'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        await _repository.addSchedule(
          subject: widget.admin.jobTitle ?? '',
          startTime: startTimeStr,
          endTime: endTimeStr,
          room: _room,
          status: _status,
          adminId: widget.admin.uid,
          date: _selectedDate,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Schedule added successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        _formKey.currentState!.reset();
        setState(() {
          _room = '';
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteSchedule(String scheduleId) async {
    try {
      await _repository.deleteSchedule(scheduleId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Schedule deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateStatus(String scheduleId, String newStatus) async {
    try {
      await _repository.updateScheduleStatus(scheduleId, newStatus);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Schedule updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      case 'scheduled':
      default:
        return kPrimaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FACULTY SCHEDULE'),
        leading: Container(),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kPrimaryColor, kComplementaryColor],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Admin Info Header
              _buildAdminHeader(),
              const SizedBox(height: kLargePadding),
              // Date Picker
              _buildDatePicker(),
              const SizedBox(height: kLargePadding),
              // Schedule Form
              _buildScheduleForm(),
              const SizedBox(height: kLargePadding),
              // Schedule List Title
              Text(
                'Today\'s Schedule',
                style: kSubheadingTextStyle.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: kSmallPadding),
              // Schedule List
              Expanded(
                child: StreamBuilder<List<ScheduleModel>>(
                  stream: _repository.getSchedulesBySubject(
                    widget.admin.jobTitle ?? '',
                    _selectedDate,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final schedules = snapshot.data ?? [];
                    if (schedules.isEmpty) {
                      return _buildEmptyState();
                    }
                    return ListView.builder(
                      itemCount: schedules.length,
                      itemBuilder: (context, index) {
                        final schedule = schedules[index];
                        return _buildScheduleCard(schedule);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.admin.jobTitle ?? 'No Subject Assigned',
          style: kHeadingTextStyle.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          '${widget.admin.firstName} ${widget.admin.lastName}',
          style: kBodyTextStyle.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.all(kDefaultPadding),
        decoration: BoxDecoration(
          color: kComplementaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(kDefaultBorderRadius),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('EEEE, MMMM d, y').format(_selectedDate),
              style: kSubheadingTextStyle.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Time Selection Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Time',
                      style: kBodyTextStyle.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: kSmallPadding),
                    InkWell(
                      onTap: () => _selectTime(context, true),
                      child: Container(
                        padding: const EdgeInsets.all(kDefaultPadding),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                          borderRadius: BorderRadius.circular(
                            kDefaultBorderRadius,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatTimeOfDay(_startTime),
                              style: kBodyTextStyle,
                            ),
                            const Icon(Icons.access_time),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: kDefaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'End Time',
                      style: kBodyTextStyle.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: kSmallPadding),
                    InkWell(
                      onTap: () => _selectTime(context, false),
                      child: Container(
                        padding: const EdgeInsets.all(kDefaultPadding),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                          borderRadius: BorderRadius.circular(
                            kDefaultBorderRadius,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatTimeOfDay(_endTime),
                              style: kBodyTextStyle,
                            ),
                            const Icon(Icons.access_time),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: kDefaultPadding),

          // Room Input
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Room',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kDefaultBorderRadius),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a room';
              }
              return null;
            },
            onSaved: (value) => _room = value!,
          ),
          const SizedBox(height: kDefaultPadding),

          // Status Dropdown
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kDefaultBorderRadius),
              ),
            ),
            value: _status,
            items:
                ['scheduled', 'active', 'cancelled', 'completed']
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(
                          status[0].toUpperCase() + status.substring(1),
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              setState(() {
                _status = value!;
              });
            },
          ),
          const SizedBox(height: kDefaultPadding),

          // Add Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccentColor,
                padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kDefaultBorderRadius),
                ),
              ),
              onPressed: _addSchedule,
              child: const Text(
                'Add Schedule',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(ScheduleModel schedule) {
    return Card(
      margin: const EdgeInsets.only(bottom: kDefaultPadding),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  schedule.duration,
                  style: kSubheadingTextStyle.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deleteSchedule(schedule.id);
                    } else {
                      _updateStatus(schedule.id, value);
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'active',
                          child: Text('Mark as Active'),
                        ),
                        const PopupMenuItem(
                          value: 'cancelled',
                          child: Text('Cancel Schedule'),
                        ),
                        const PopupMenuItem(
                          value: 'completed',
                          child: Text('Mark as Completed'),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                ),
              ],
            ),
            const SizedBox(height: kSmallPadding),
            Row(
              children: [
                Icon(
                  Icons.room,
                  size: 16,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: kSmallPadding),
                Text(
                  schedule.room,
                  style: kBodyTextStyle.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kSmallPadding,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(schedule.status),
                    borderRadius: BorderRadius.circular(kDefaultBorderRadius),
                  ),
                  child: Text(
                    schedule.status.toUpperCase(),
                    style: kBodyTextStyle.copyWith(
                      color: Colors.white,
                      fontSize: 12,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: kDefaultPadding),
          Text(
            'No schedules for selected date',
            style: kBodyTextStyle.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
