import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'st_classes_screen.dart';
import 'st_profile_screen.dart';
import 'st_schedule_screen.dart';

import '../../../data/models/student_model.dart';

class StudentWrapper extends StatefulWidget {
  static const String id = 'stwrapper_screen';

  const StudentWrapper({Key? key}) : super(key: key);

  @override
  State<StudentWrapper> createState() => _StudentWrapperState();
}

class _StudentWrapperState extends State<StudentWrapper> {
  int _selectedIndex = 0;
  late List<Widget> _pages;
  late StudentModel student;
  bool _initialized = false;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      student = Provider.of<StudentModel>(context, listen: false);
      _pages = [
        StClassesScreen(),
        StScheduleScreen(),
        StudentProfileScreen(
          student: student,
          onSubmitChanges: _handleProfileChanges,
        ),
      ];
      _initialized = true;
    }
  }

  void _handleProfileChanges(StudentModel updatedStudent) {
    // You can update the local student model if needed
    setState(() {
      student = updatedStudent;
      // You can also update _pages if needed
    });
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
        selectedItemColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }
}
