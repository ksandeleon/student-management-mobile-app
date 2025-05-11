class ScheduleModel {
  final String id;         // Firestore document ID
  final String subject;
  final String startTime;  // e.g., "08:00 AM"
  final String endTime;    // e.g., "10:00 AM"
  final String room;
  final String status;     // e.g., "active", "cancelled", "rescheduled"

  ScheduleModel({
    required this.id,
    required this.subject,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.status,
  });

  // From Firestore document
  factory ScheduleModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ScheduleModel(
      id: id,
      subject: data['subject'] ?? '',
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      room: data['room'] ?? '',
      status: data['status'] ?? 'active',
    );
  }

  // To Firestore document
  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'startTime': startTime,
      'endTime': endTime,
      'room': room,
      'status': status,
    };
  }
}
