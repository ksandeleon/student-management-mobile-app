import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AdminModel extends ChangeNotifier{
  final String uid;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String phone;
  final String email;
  final String? address;
  final DateTime? dob;
  final String? department; //only hardcoded because have one. no updates planned. current is "College of Computing Science"
  final String? jobTitle; //this is basically subjectname.. e.g. "Digital Electronics or practical datascience"

  AdminModel({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.middleName,
    this.address,
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
      'middleName': middleName,
      'address': address,
      'dob': dob?.toIso8601String(),
      'department': department,
      'jobTitle': jobTitle,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Create from Firestore document
  factory AdminModel.fromMap(Map<String, dynamic> map) {
    return AdminModel(
      uid: map['uid'],
      email: map['email'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      phone: map['phone'],
      middleName: map['middleName'],
      address: map['address'],
      dob: map['dob'] != null ? DateTime.parse(map['dob']) : null,
      department: map['department'],
      jobTitle: map['jobTitle'],
    );
  }
}
