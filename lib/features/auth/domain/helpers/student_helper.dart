import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:true_studentmgnt_mobapp/features/auth/data/models/student_model.dart';

class StudentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _studentsCollection =
      FirebaseFirestore.instance.collection('students');

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

  // Add a new studentsssss
  Future<void> addStudent(StudentModel student) async {
    try {
      await _studentsCollection.doc(student.uid).set(student.toMap());
    } catch (e) {
      print('Error adding student: $e');
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

  // Update student
  Future<void> updateStudent(StudentModel student) async {
    try {
      await _studentsCollection.doc(student.uid).update(student.toMap());
    } catch (e) {
      print('Error updating student: $e');
    }
  }

  // Delete student
  Future<void> deleteStudent(String uid) async {
    try {
      await _studentsCollection.doc(uid).delete();
    } catch (e) {
      print('Error deleting student: $e');
    }
  }
}
