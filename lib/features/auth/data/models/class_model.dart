import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:true_studentmgnt_mobapp/features/auth/data/models/schedule_model.dart';


class ClassModel extends ChangeNotifier {
  String? classId;
  String className;
  String? description;
  String adminId;
  Map<String, dynamic> schedule;
  DateTime createdAt;
  DateTime updatedAt;

  // Internal state tracking
  bool _isLoading = false;
  String? _errorMessage;
  List<ScheduleModel> _schedules = [];
  List<String> _enrolledStudentIds = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ScheduleModel> get schedules => _schedules;
  List<String> get enrolledStudentIds => _enrolledStudentIds;

  ClassModel({
    this.classId,
    required this.className,
    this.description,
    required this.adminId,
    required this.schedule,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) :
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'classId': classId,
      'className': className,
      'description': description,
      'adminId': adminId,
      'schedule': schedule,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  // Create from Firestore document
  factory ClassModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ClassModel(
      classId: doc.id,
      className: data['className'] ?? '',
      description: data['description'],
      adminId: data['adminId'] ?? '',
      schedule: data['schedule'] ?? {},
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Save to Firestore
  Future<void> saveToFirestore() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final firestore = FirebaseFirestore.instance;
      final classesRef = firestore.collection('classes');

      if (classId == null) {
        // Create new document
        final docRef = await classesRef.add(toMap());
        classId = docRef.id;
      } else {
        // Update existing document
        await classesRef.doc(classId).update(toMap());
      }
    } catch (e) {
      _errorMessage = 'Failed to save class: ${e.toString()}';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete class from Firestore
  Future<void> deleteFromFirestore() async {
    if (classId == null) return;

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // First, we should delete all related enrollments and schedules
      // This is a cascading delete operation

      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      // Delete class document
      batch.delete(firestore.collection('classes').doc(classId));

      // Commit the batch
      await batch.commit();
    } catch (e) {
      _errorMessage = 'Failed to delete class: ${e.toString()}';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch schedules for this class
  Future<void> fetchSchedules() async {
    if (classId == null) return;

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('schedules')
          .where('classId', isEqualTo: classId)
          .orderBy('startDateTime')
          .get();

      _schedules = querySnapshot.docs
          .map((doc) => ScheduleModel.fromDocument(doc))
          .toList();
    } catch (e) {
      _errorMessage = 'Failed to fetch schedules: ${e.toString()}';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch enrolled students
  Future<void> fetchEnrolledStudents() async {
    if (classId == null) return;

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final querySnapshot = await FirebaseFirestore.instance
          .collection('classEnrollments')
          .where('classId', isEqualTo: classId)
          .where('status', isEqualTo: 'active')
          .get();

      _enrolledStudentIds = querySnapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['studentId'] as String)
          .toList();
    } catch (e) {
      _errorMessage = 'Failed to fetch enrolled students: ${e.toString()}';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update class properties
  void updateClass({
    String? className,
    String? description,
    Map<String, dynamic>? schedule,
  }) {
    if (className != null) this.className = className;
    if (description != null) this.description = description;
    if (schedule != null) this.schedule = schedule;

    updatedAt = DateTime.now();
    notifyListeners();
  }

  // Add a schedule to this class
  Future<void> addSchedule(ScheduleModel schedule) async {
    if (classId == null) {
      _errorMessage = 'Cannot add schedule: Class not saved yet';
      notifyListeners();
      return;
    }

    // Ensure the schedule is associated with this class
    schedule.classId = classId!;

    // Save the schedule to Firestore
    await schedule.saveToFirestore();

    // Refresh schedules
    await fetchSchedules();
  }
}
