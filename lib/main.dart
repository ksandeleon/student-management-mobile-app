import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:true_studentmgnt_mobapp/frontend/dashboard_screen.dart';

import 'package:true_studentmgnt_mobapp/frontend/login_screen.dart';
import 'package:true_studentmgnt_mobapp/frontend/signup_screen.dart';
import 'package:true_studentmgnt_mobapp/frontend/welcome_screen.dart';
import 'package:true_studentmgnt_mobapp/utilities/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(

    options: DefaultFirebaseOptions.currentPlatform,
);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GO STUDENT',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      initialRoute: 'welcome_screen',
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(), // id = "welcome_screen"
        LoginScreen.id: (context) => LoginScreen(), //id = "login_screen"
        SignupScreen.id: (context) => SignupScreen(), //id = "signup_screen"
        DashboardScreen.id: (context) => DashboardScreen(), // id = "dashboard_screen"

      },
    );
  }
}
