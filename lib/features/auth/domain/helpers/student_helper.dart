import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:true_studentmgnt_mobapp/features/auth/data/models/student_model.dart';

class StudentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _studentsCollection = FirebaseFirestore.instance
      .collection('students');

  // Get all students as a list
  Future<List<StudentModel>> getAllStudents() async {
    try {
      final snapshot = await _studentsCollection.get();
      return snapshot.docs.map((doc) {
        return StudentModel.fromMap(doc.data() as Map, docId: doc.id);
      }).toList();
    } catch (e) {
      print('Error getting students: $e');
      return [];
    }
  }

  // Add a new student - direct save to Firebase
  Future<bool> addStudent(StudentModel student) async {
    try {
      await _studentsCollection.doc(student.uid).set(student.toMap());
      return true; // Operation succeeded
    } catch (e) {
      print('Error adding student: $e');
      return false; // Operation failed
    }
  }

  // Get a single student by UID
  Future<StudentModel?> getStudentById(String uid) async {
    try {
      final doc = await _studentsCollection.doc(uid).get();
      if (doc.exists) {
        return StudentModel.fromMap(doc.data() as Map, docId: doc.id);
      }
    } catch (e) {
      print('Error fetching student by ID: $e');
    }
    return null;
  }

  // Update student - direct save to Firebase without pending state
  Future<bool> updateStudent(StudentModel student) async {
    try {
      await _studentsCollection.doc(student.uid).update(student.toMap());
      return true; // Operation succeeded
    } catch (e) {
      print('Error updating student: $e');
      return false; // Operation failed
    }
  }

  // Delete student
  Future<bool> deleteStudent(String uid) async {
    try {
      await _studentsCollection.doc(uid).delete();
      return true; // Operation succeeded
    } catch (e) {
      print('Error deleting student: $e');
      return false; // Operation failed
    }
  }

  // Method to save student edits directly to Firebase
  Future<bool> saveStudentEdits(StudentModel updatedStudent) async {
    try {
      // Update the student document directly
      await _studentsCollection.doc(updatedStudent.uid).update({
        'firstName': updatedStudent.firstName,
        'lastName': updatedStudent.lastName,
        'email': updatedStudent.email,
        'phone': updatedStudent.phone,
        'middleName': updatedStudent.middleName,
        'studentNumber': updatedStudent.studentNumber,
        'address': updatedStudent.address,
        'course': updatedStudent.course,
        'dob': updatedStudent.dob?.toIso8601String(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true; // Operation succeeded
    } catch (e) {
      print('Error saving student edits: $e');
      return false; // Operation failed
    }
  }
}
