import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:true_studentmgnt_mobapp/features/auth/presentation/screens/admin/ad_classes_screen.dart';
import 'package:true_studentmgnt_mobapp/features/auth/presentation/screens/student/st_schedule_screen.dart';
import 'package:true_studentmgnt_mobapp/features/auth/presentation/screens/student/st_wrapper_screen.dart';
import 'firebase/firebase_options.dart';

import 'package:true_studentmgnt_mobapp/features/auth/presentation/screens/login_screen.dart';
import 'package:true_studentmgnt_mobapp/features/auth/presentation/screens/signup_screen.dart';
import 'package:true_studentmgnt_mobapp/features/auth/presentation/screens/welcome_screen.dart';
import 'package:true_studentmgnt_mobapp/features/auth/presentation/screens/student/st_classes_screen.dart';
import 'package:true_studentmgnt_mobapp/config/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GO STUDENT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

    //   initialRoute: 'class_screen',
      initialRoute: 'welcome_screen',
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(), // id = "welcome_screen"
        LoginScreen.id: (context) => LoginScreen(), //id = "login_screen"
        SignupScreen.id: (context) => SignupScreen(), //id = "signup_screen"

        StudentWrapper.id:
            (context) => StudentWrapper(), //id = stwrapper_screen

        StClassesScreen.id:
            (context) => StClassesScreen(), // id = "stclasses_screen"
        StScheduleScreen.id:
            (context) => StScheduleScreen(), // id = "stschedule_screen"
        // StudentProfileScreen.id: (context) => StudentProfileScreen(student: student, onSubmitChanges: onSubmitChanges), //stprofile_screen
        // ClassScreen.id: (context) => ClassScreen();
        
      },
    );
  }
}
