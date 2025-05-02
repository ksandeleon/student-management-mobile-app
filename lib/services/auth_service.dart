import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:true_studentmgnt_mobapp/features/auth/data/models/student_model.dart';
import 'package:true_studentmgnt_mobapp/features/auth/data/models/admin_model.dart';
import 'package:true_studentmgnt_mobapp/features/auth/data/models/student_model.dart';
import 'package:true_studentmgnt_mobapp/features/auth/presentation/screens/student/st_wrapper_screen.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String> _createFirebaseUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user!.uid;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e.code);
    }
  }

  Future<void> signUpStudent({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    String? middleName,
    String? studentNumber,
    String? address,
    String? course,
    DateTime? dob,
  }) async {
    try {
      final uid = await _createFirebaseUser(email, password);

      final student = StudentModel(
        uid: uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        middleName: middleName,
        studentNumber: studentNumber,
        address: address,
        course: course,
        dob: dob,
      );

      await _firestore.collection('students').doc(uid).set(student.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUpAdmin({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    String? middleName,
    String? address,
    DateTime? dob,
    String? department,
    String? jobTitle,
  }) async {
    try {
      final uid = await _createFirebaseUser(email, password);

      final admin = AdminModel(
        uid: uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        middleName: middleName,
        address: address,
        dob: dob,
        department: department,
        jobTitle: jobTitle,
      );

      await _firestore.collection('admins').doc(uid).set(admin.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /// Login logic for both student and admin
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;

      final studentDoc = await _firestore.collection('students').doc(uid).get();
      if (studentDoc.exists) {
        return 'student';
      }

      final adminDoc = await _firestore.collection('admins').doc(uid).get();
      if (adminDoc.exists) {
        return 'admin';
      }

      throw 'No role assigned to this account.';
    } on FirebaseAuthException catch (e) {
      throw _handleSignInError(e.code);
    }
  }

  String _handleAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'The email address is already in use.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'The password is too weak.';
      default:
        return 'An unknown error occurred. Please try again.';
    }
  }

  String _handleSignInError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      default:
        return 'An unknown error occurred. Please try again.';
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleSignInError(e.code);
    }
  }

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Improved login with navigation
  Future<void> handleLoginAndNavigation({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final role = await signIn(email: email, password: password);
      final uid = _auth.currentUser!.uid;

      if (role == 'student') {
        final doc = await _firestore.collection('students').doc(uid).get();
        if (!doc.exists) throw 'Student record not found';

        final student = StudentModel.fromMap(doc.data()!);

        // Remove loading indicator
        Navigator.of(context).pop();
        print("student login success");



        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => Provider<StudentModel>.value(
              value: student,
              child: const StudentWrapper(),
            ),
          ),
        );




      } else if (role == 'admin') {
        final doc = await _firestore.collection('admins').doc(uid).get();
        if (!doc.exists) throw 'Admin record not found';

        // Navigate to admin screen
        print("admin loggin success");
        // Navigator.of(context).pushReplacementNamed(AdminDashboardScreen.id);
      } else {
        await _auth.signOut();
        throw 'Unknown user role';
      }
    } catch (e) {
      // Ensure loading dialog is dismissed
      Navigator.of(context).pop();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}
