import 'package:flutter/material.dart';
import 'package:true_studentmgnt_mobapp/config/constants.dart';
import 'package:true_studentmgnt_mobapp/features/auth/presentation/screens/login_screen.dart';
import 'package:true_studentmgnt_mobapp/features/auth/presentation/screens/signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  static const String id = 'welcome_screen';

  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access theme colors
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  // Logo and App Name
                  Icon(
                    Icons.menu_book_rounded,
                    size: 80,
                    color: theme.colorScheme.onPrimary,
                  ),
                  const SizedBox(height: kDefaultPadding),
                  Text(
                    'Go Student',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),

                  // Tagline
                  const SizedBox(height: kSmallPadding),
                  Text(
                    'smart simple classroom app',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onPrimary.withOpacity(0.9),
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Student Card
                  _buildUserCard(
                    context,
                    'Student',
                    Icons.school,
                    'student-icon',
                    kComplementaryColor,
                    'student',
                  ),

                  const SizedBox(height: 20),

                  // Admin Card
                  _buildUserCard(
                    context,
                    'Admin',
                    Icons.admin_panel_settings,
                    'admin-icon',
                    kAccentColor,
                    'admin',
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(
    BuildContext context,
    String userType,
    IconData icon,
    String heroTag,
    Color accentColor,
    String routeParam,
  ) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(kLargeBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: heroTag,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 24, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  userType,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: kDefaultPadding),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    () => Navigator.pushNamed(
                      context,
                      LoginScreen.id,
                      arguments: {'userType': routeParam},
                    ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kDefaultBorderRadius),
                  ),
                ),
                child: const Text(
                  'LOGIN',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: kSmallPadding),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed:
                    () => Navigator.pushNamed(
                      context,
                      SignupScreen.id,
                      arguments: {'userType': routeParam},
                    ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kDefaultBorderRadius),
                    side: BorderSide(color: accentColor.withOpacity(0.5)),
                  ),
                ),
                child: Text(
                  'SIGN UP',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
