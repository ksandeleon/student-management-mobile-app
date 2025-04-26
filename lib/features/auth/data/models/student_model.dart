import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String? middleName;
  final String? studentNumber;
  final String? address;
  final String? course;
  final DateTime? dob;

  StudentModel({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.middleName,
    this.studentNumber,
    this.address,
    this.course,
    this.dob,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'middleName': middleName,
      'studentNumber': studentNumber,
      'address': address,
      'course': course,
      'dob': dob?.toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Create from Firestore document
  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      uid: map['uid'],
      email: map['email'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      phone: map['phone'],
      middleName: map['middleName'],
      studentNumber: map['studentNumber'],
      address: map['address'],
      course: map['course'],
      dob: map['dob'] != null ? DateTime.parse(map['dob']) : null,
    );
  }
}
