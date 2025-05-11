import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:true_studentmgnt_mobapp/features/auth/data/models/schedule_model.dart';

class ScheduleRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ScheduleModel>> getSchedulesBySubject(
    String subject,
    DateTime date,
  ) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _firestore
        .collection('schedules')
        .where('subject', isEqualTo: subject)
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .orderBy('date')
        .orderBy('startTime')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) => ScheduleModel.fromFirestore(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    ),
                  )
                  .toList(),
        );
  }

  Future<void> addSchedule({
    required String subject,
    required String startTime,
    required String endTime,
    required String room,
    required String status,
    required String adminId,
    required DateTime date,
  }) async {
    await _firestore.collection('schedules').add({
      'subject': subject,
      'startTime': startTime,
      'endTime': endTime,
      'room': room,
      'status': status,
      'adminId': adminId,
      'date': date,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateScheduleStatus(String scheduleId, String newStatus) async {
    await _firestore.collection('schedules').doc(scheduleId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteSchedule(String scheduleId) async {
    await _firestore.collection('schedules').doc(scheduleId).delete();
  }

  Future<bool> checkScheduleConflict({
    required String subject,
    required String room,
    required DateTime date,
    required String startTime,
    required String endTime,
    String? excludeScheduleId,
  }) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final querySnapshot =
        await _firestore
            .collection('schedules')
            .where('subject', isEqualTo: subject)
            .where('room', isEqualTo: room)
            .where('date', isGreaterThanOrEqualTo: startOfDay)
            .where('date', isLessThanOrEqualTo: endOfDay)
            .get();

    final newStart = _timeToMinutes(startTime);
    final newEnd = _timeToMinutes(endTime);

    for (final doc in querySnapshot.docs) {
      if (excludeScheduleId != null && doc.id == excludeScheduleId) continue;

      final data = doc.data();
      final existingStart = _timeToMinutes(data['startTime']);
      final existingEnd = _timeToMinutes(data['endTime']);

      if ((newStart >= existingStart && newStart < existingEnd) ||
          (newEnd > existingStart && newEnd <= existingEnd) ||
          (newStart <= existingStart && newEnd >= existingEnd)) {
        return true;
      }
    }

    return false;
  }

  int _timeToMinutes(String time) {
    try {
      final parts = time.split(' ');
      final timeParts = parts[0].split(':');
      int hours = int.parse(timeParts[0]);
      final minutes = int.parse(timeParts[1]);

      // Handle 12-hour format
      if (parts.length > 1) {
        if (parts[1] == 'PM' && hours != 12) {
          hours += 12;
        } else if (parts[1] == 'AM' && hours == 12) {
          hours = 0;
        }
      }

      // Ensure valid hours (0-23)
      hours = hours.clamp(0, 23);

      return hours * 60 + minutes;
    } catch (e) {
      debugPrint('Error parsing time: $time');
      return 0; // Return default value if parsing fails
    }
  }
}
