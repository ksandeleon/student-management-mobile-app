import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementModel {
  final String id; // Firestore doc ID
  final String text;
  final String author;
  final Timestamp timestamp;
  final String adminId;
  final String subject;

  AnnouncementModel({
    required this.id,
    required this.text,
    required this.author,
    required this.timestamp,
    required this.adminId,
    required this.subject,
  });

  // Firestore -> Model
  factory AnnouncementModel.fromMap(Map<String, dynamic> map, String docId) {
    return AnnouncementModel(
      id: docId,
      text: map['text'] ?? '',
      author: map['author'] ?? '',
      timestamp: map['timestamp'] ?? Timestamp.now(),
      adminId: map['adminId'] ?? '',
      subject: map['subject'] ?? '',
    );
  }

  // Model -> Firestore (without ID)
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'author': author,
      'timestamp': timestamp,
      'adminId': adminId,
      'subject': subject,
    };
  }
}
