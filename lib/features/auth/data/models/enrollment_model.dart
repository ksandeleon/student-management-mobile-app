import 'package:cloud_firestore/cloud_firestore.dart';

class EnrollmentModel {
  final String id; // Firestore doc ID
  final String studentId; // UID from StudentModel
  final String subject; // e.g. "Digital Electronics"
  final DateTime enrolledAt;

  EnrollmentModel({
    required this.id,
    required this.studentId,
    required this.subject,
    required this.enrolledAt,
  });

  // From Firestore
  factory EnrollmentModel.fromMap(Map<String, dynamic> map, String docId) {
    return EnrollmentModel(
      id: docId,
      studentId: map['studentId'],
      subject: map['subject'],
      enrolledAt: (map['enrolledAt'] as Timestamp).toDate(),
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'subject': subject,
      'enrolledAt': Timestamp.fromDate(enrolledAt),
    };
  }
}
