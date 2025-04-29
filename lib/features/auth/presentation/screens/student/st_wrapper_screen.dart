import 'package:flutter/material.dart';
import 'st_classes_screen.dart';
import 'st_profile_screen.dart';
import 'st_schedule_screen.dart';

class StudentWrapper extends StatefulWidget {
  static const String id = 'stwrapper_screen';
  final Student student;

  const StudentWrapper({Key? key, required this.student}) : super(key: key);

  @override
  State<StudentWrapper> createState() => _StudentWrapperState();
}

class _StudentWrapperState extends State<StudentWrapper> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      StClassesScreen(),
      StScheduleScreen(),
      StudentProfileScreen(
        student: widget.student,
        onSubmitChanges: _handleProfileChanges,
      ),
    ];
  }

  void _handleProfileChanges(Student updatedStudent) {
    // Handle any profile updates if needed
    // This would be passed to the StudentProfileScreen
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.class_), label: 'Classes'),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // Customize the styling to match your app theme
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }
}
