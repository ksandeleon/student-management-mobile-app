// services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:true_studentmgnt_mobapp/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up with email and password
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String userType,
    String? middleName,
    String? studentNumber,
    String? address,
    String? course,
    DateTime? dob,
    String? department,
    String? jobTitle,
  }) async {
    try {
      // Create user with email and password
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Create user document in Firestore
      UserModel user = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        userType: userType,
        middleName: middleName,
        studentNumber: studentNumber,
        address: address,
        course: course,
        dob: dob,
        department: department,
        jobTitle: jobTitle,
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(user.toMap());

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e.code);
    } catch (e) {
      throw 'An error occurred. Please try again.';
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
        return 'An error occurred. Please try again.';
    }
  }
}
