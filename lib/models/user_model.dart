// models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String userType; // 'student' or 'admin'
  final String? middleName;
  final String? studentNumber;
  final String? address;
  final String? course;
  final DateTime? dob;
  final String? department;
  final String? jobTitle;

  UserModel({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.userType,
    this.middleName,
    this.studentNumber,
    this.address,
    this.course,
    this.dob,
    this.department,
    this.jobTitle,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'userType': userType,
      'middleName': middleName,
      'studentNumber': studentNumber,
      'address': address,
      'course': course,
      'dob': dob?.toIso8601String(),
      'department': department,
      'jobTitle': jobTitle,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Create from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      phone: map['phone'],
      userType: map['userType'],
      middleName: map['middleName'],
      studentNumber: map['studentNumber'],
      address: map['address'],
      course: map['course'],
      dob: map['dob'] != null ? DateTime.parse(map['dob']) : null,
      department: map['department'],
      jobTitle: map['jobTitle'],
    );
  }
}
