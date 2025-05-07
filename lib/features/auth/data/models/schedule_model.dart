import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleModel extends ChangeNotifier {
  String? scheduleId;
  String classId;
  String title;
  String? description;
  DateTime startDateTime;
  DateTime endDateTime;
  String? location;
  DateTime createdAt;

  // Internal state tracking
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ScheduleModel({
    this.scheduleId,
    required this.classId,
    required this.title,
    this.description,
    required this.startDateTime,
    required this.endDateTime,
    this.location,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'scheduleId': scheduleId,
      'classId': classId,
      'title': title,
      'description': description,
      'startDateTime': Timestamp.fromDate(startDateTime),
      'endDateTime': Timestamp.fromDate(endDateTime),
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create from Firestore document
  factory ScheduleModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ScheduleModel(
      scheduleId: doc.id,
      classId: data['classId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'],
      startDateTime: (data['startDateTime'] as Timestamp).toDate(),
      endDateTime: (data['endDateTime'] as Timestamp).toDate(),
      location: data['location'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Save to Firestore
  Future<void> saveToFirestore() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final firestore = FirebaseFirestore.instance;
      final schedulesRef = firestore.collection('schedules');

      if (scheduleId == null) {
        // Create new document
        final docRef = await schedulesRef.add(toMap());
        scheduleId = docRef.id;
      } else {
        // Update existing document
        await schedulesRef.doc(scheduleId).update(toMap());
      }
    } catch (e) {
      _errorMessage = 'Failed to save schedule: ${e.toString()}';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete from Firestore
  Future<void> deleteFromFirestore() async {
    if (scheduleId == null) return;

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await FirebaseFirestore.instance
          .collection('schedules')
          .doc(scheduleId)
          .delete();
    } catch (e) {
      _errorMessage = 'Failed to delete schedule: ${e.toString()}';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update schedule properties
  void updateSchedule({
    String? title,
    String? description,
    DateTime? startDateTime,
    DateTime? endDateTime,
    String? location,
  }) {
    if (title != null) this.title = title;
    if (description != null) this.description = description;
    if (startDateTime != null) this.startDateTime = startDateTime;
    if (endDateTime != null) this.endDateTime = endDateTime;
    if (location != null) this.location = location;

    notifyListeners();
  }
}
