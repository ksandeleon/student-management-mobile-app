import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:true_studentmgnt_mobapp/features/auth/presentation/screens/admin/ad_classes_screen.dart';
import 'package:true_studentmgnt_mobapp/features/auth/presentation/screens/admin/ad_profile_screen.dart';
import 'package:true_studentmgnt_mobapp/features/auth/presentation/screens/admin/ad_schedule_screen.dart';

import '../../../data/models/admin_model.dart';


class AdminWrapper extends StatefulWidget {
  static const String id = 'admin_wrapper_screen';

  const AdminWrapper({Key? key}) : super(key: key);

  @override
  State<AdminWrapper> createState() => _AdminWrapperState();
}

class _AdminWrapperState extends State<AdminWrapper> {
  int _selectedIndex = 0;
  late List<Widget> _pages;
  late AdminModel admin;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      admin = Provider.of<AdminModel>(context, listen: false);
      _pages = [
        AdClassScreen(admin: admin), // <- Add AdminClassesScreen here
        AdScheduleScreen(admin: admin),
        AdEnrollmentScreen(admin: admin),
      ];
      _initialized = true;
    }
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
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Classes'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Schedules'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Enrollments'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }
}
