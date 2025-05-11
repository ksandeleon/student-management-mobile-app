import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:true_studentmgnt_mobapp/features/auth/data/models/schedule_model.dart';

class ScheduleFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _schedulesCollection =>
      _firestore.collection('schedules');
  CollectionReference get _adminsCollection => _firestore.collection('admins');

  // Add a new schedule
  Future<String> addSchedule({
    required String subject,
    required String startTime,
    required String endTime,
    required String room,
    required String status,
    required String adminId,
  }) async {
    try {
      final docRef = await _schedulesCollection.add({
        'subject': subject,
        'startTime': startTime,
        'endTime': endTime,
        'room': room,
        'status': status,
        'adminId': adminId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update the admin document with the new schedule reference
      await _adminsCollection.doc(adminId).update({
        'scheduleIds': FieldValue.arrayUnion([docRef.id]),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add schedule: $e');
    }
  }

  // Update a schedule
  Future<void> updateSchedule(ScheduleModel schedule) async {
    try {
      await _schedulesCollection.doc(schedule.id).update({
        'startTime': schedule.startTime,
        'endTime': schedule.endTime,
        'room': schedule.room,
        'status': schedule.status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update schedule: $e');
    }
  }

  // Delete a schedule
  Future<void> deleteSchedule(String scheduleId, String adminId) async {
    try {
      // Remove from schedules collection
      await _schedulesCollection.doc(scheduleId).delete();

      // Remove reference from admin document
      await _adminsCollection.doc(adminId).update({
        'scheduleIds': FieldValue.arrayRemove([scheduleId]),
      });
    } catch (e) {
      throw Exception('Failed to delete schedule: $e');
    }
  }

  // Get all schedules for a specific subject (admin.jobTitle)
  Stream<List<ScheduleModel>> getSchedulesBySubject(String subject) {
    return _schedulesCollection
        .where('subject', isEqualTo: subject)
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ScheduleModel.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ))
            .toList());
  }

  // Get today's schedules for a subject
  Stream<List<ScheduleModel>> getTodaySchedulesBySubject(String subject) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _schedulesCollection
        .where('subject', isEqualTo: subject)
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .orderBy('date')
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ScheduleModel.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ))
            .toList());
  }

  // Get schedules by status
  Stream<List<ScheduleModel>> getSchedulesByStatus(
      String subject, String status) {
    return _schedulesCollection
        .where('subject', isEqualTo: subject)
        .where('status', isEqualTo: status)
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ScheduleModel.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ))
            .toList());
  }

  // Batch update status for multiple schedules
  Future<void> batchUpdateStatus(
      List<String> scheduleIds, String newStatus) async {
    final batch = _firestore.batch();

    for (final id in scheduleIds) {
      final docRef = _schedulesCollection.doc(id);
      batch.update(docRef, {
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    try {
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch update schedules: $e');
    }
  }

  // Check for schedule conflicts
  Future<bool> checkScheduleConflict({
    required String subject,
    required String startTime,
    required String endTime,
    required String room,
    DateTime? date,
    String? excludeScheduleId,
  }) async {
    try {
      Query query = _schedulesCollection
          .where('subject', isEqualTo: subject)
          .where('room', isEqualTo: room);

      if (date != null) {
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
        query = query
            .where('date', isGreaterThanOrEqualTo: startOfDay)
            .where('date', isLessThanOrEqualTo: endOfDay);
      }

      final snapshot = await query.get();

      // Convert time strings to minutes for comparison
      int newStart = _timeToMinutes(startTime);
      int newEnd = _timeToMinutes(endTime);

      for (final doc in snapshot.docs) {
        // Skip the schedule we're excluding (for updates)
        if (excludeScheduleId != null && doc.id == excludeScheduleId) {
          continue;
        }

        int existingStart = _timeToMinutes(doc['startTime']);
        int existingEnd = _timeToMinutes(doc['endTime']);

        // Check for time overlap
        if ((newStart >= existingStart && newStart < existingEnd) ||
            (newEnd > existingStart && newEnd <= existingEnd) ||
            (newStart <= existingStart && newEnd >= existingEnd)) {
          return true; // Conflict exists
        }
      }

      return false; // No conflict
    } catch (e) {
      throw Exception('Failed to check schedule conflict: $e');
    }
  }

  // Helper method to convert time string to minutes
  int _timeToMinutes(String time) {
    final parts = time.split(' ');
    final timeParts = parts[0].split(':');
    int hours = int.parse(timeParts[0]);
    final minutes = int.parse(timeParts[1]);

    // Handle 12-hour format
    if (parts.length > 1 && parts[1] == 'PM' && hours != 12) {
      hours += 12;
    } else if (parts.length > 1 && parts[1] == 'AM' && hours == 12) {
      hours = 0;
    }

    return hours * 60 + minutes;
  }
}
