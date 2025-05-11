class ScheduleModel {
  final String id;         // Firestore document ID
  final String subject;
  final String startTime;  // e.g., "08:00 AM"
  final String endTime;    // e.g., "10:00 AM"
  final String room;
  final String status;     // e.g., "active", "cancelled", "rescheduled"
  final String adminId;    // ID of the admin who created this schedule
  final DateTime? date;    // Optional date for the schedule
  final DateTime createdAt;
  final DateTime updatedAt;

  ScheduleModel({
    required this.id,
    required this.subject,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.status,
    required this.adminId,
    this.date,
    required this.createdAt,
    required this.updatedAt,
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
      adminId: data['adminId'] ?? '',
      date: data['date']?.toDate(),
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
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
      'adminId': adminId,
      'date': date,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Helper method to check if schedule is active
  bool get isActive => status == 'active';

  // Helper method to get duration
  String get duration => '$startTime - $endTime';

  // Convert to a shorter display string
  String toDisplayString() {
    return '$subject ($duration) in $room';
  }
}
