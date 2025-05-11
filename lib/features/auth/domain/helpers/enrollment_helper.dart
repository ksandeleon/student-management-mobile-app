import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:true_studentmgnt_mobapp/features/auth/data/models/admin_model.dart';
import 'package:true_studentmgnt_mobapp/features/auth/data/models/student_model.dart';
import 'package:true_studentmgnt_mobapp/features/auth/data/models/enrollment_model.dart';

class EnrollmentHelper {
  static final CollectionReference _enrollmentsRef =
      FirebaseFirestore.instance.collection('enrollments');
  static final CollectionReference _studentsRef =
      FirebaseFirestore.instance.collection('students');


  static Future<List<StudentModel>> getStudentsBySubject(String? subjectName) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('students')
        .where('enrolledSubjects', arrayContains: subjectName)
        .get();

    return querySnapshot.docs
        .map((doc) => StudentModel.fromMap(doc.data(), docId: doc.id))
        .toList();
  }

  /// Get all enrollments for a specific subject/class
  static Future<List<EnrollmentModel>> getEnrollmentsBySubject(String subject) async {
    final querySnapshot = await _enrollmentsRef
        .where('subject', isEqualTo: subject)
        .orderBy('enrolledAt', descending: true)
        .get();

    return querySnapshot.docs.map((doc) {
      return EnrollmentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  /// Get enrolled students for a subject
  static Future<List<StudentModel>> getEnrolledStudents(String subject) async {
    // First get enrollments
    final enrollments = await getEnrollmentsBySubject(subject);

    // Then get student data for each enrollment
    final List<StudentModel> students = [];

    for (var enrollment in enrollments) {
      final studentDoc = await _studentsRef.doc(enrollment.studentId).get();

      if (studentDoc.exists) {
        students.add(StudentModel.fromMap(
          studentDoc.data() as Map<String, dynamic>,
          docId: studentDoc.id
        ));
      }
    }

    return students;
  }

  /// Get unenrolled students for a subject
  static Future<List<StudentModel>> getUnenrolledStudents(String subject) async {
    // Get all enrollments for this subject
    final enrollmentsSnapshot = await _enrollmentsRef
        .where('subject', isEqualTo: subject)
        .get();

    // Create a set of enrolled student IDs for efficient lookup
    final enrolledIds = enrollmentsSnapshot.docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['studentId'] as String)
        .toSet();

    // Get all students
    final studentsSnapshot = await _studentsRef.get();

    // Filter out already enrolled students
    final allStudents = studentsSnapshot.docs
        .map((doc) => StudentModel.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id))
        .toList();

    return allStudents
        .where((student) => !enrolledIds.contains(student.uid))
        .toList();
  }

  /// Enroll a student in a class
  static Future<void> enrollStudent(StudentModel student, AdminModel admin) async {
    // Create enrollment data
    final enrollmentData = {
      'studentId': student.uid,
      'subject': admin.jobTitle,
      'enrolledAt': FieldValue.serverTimestamp(),
      'enrolledBy': admin.uid,
      'adminName': '${admin.firstName} ${admin.lastName}',
    };

    // Add to Firestore
    await _enrollmentsRef.add(enrollmentData);
  }

  /// Unenroll a student from a class
  static Future<void> unenrollStudent(String enrollmentId) async {
    await _enrollmentsRef.doc(enrollmentId).delete();
  }

  /// Check if a student is enrolled in a specific class
  static Future<bool> isStudentEnrolled(String studentId, String subject) async {
    final querySnapshot = await _enrollmentsRef
        .where('studentId', isEqualTo: studentId)
        .where('subject', isEqualTo: subject)
        .limit(1)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  /// Get enrollment document ID by student ID and subject
  static Future<String?> getEnrollmentId(String studentId, String subject) async {
    final querySnapshot = await _enrollmentsRef
        .where('studentId', isEqualTo: studentId)
        .where('subject', isEqualTo: subject)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    }

    return querySnapshot.docs.first.id;
  }

  /// Get total number of students enrolled in a class
  static Future<int> getStudentCountForSubject(String subject) async {
    final querySnapshot = await _enrollmentsRef
        .where('subject', isEqualTo: subject)
        .count()
        .get();

   return querySnapshot.count ?? 0;
  }
}
