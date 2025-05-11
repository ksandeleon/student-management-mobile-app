import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:true_studentmgnt_mobapp/features/auth/data/models/admin_model.dart';
import 'package:true_studentmgnt_mobapp/features/auth/data/models/announcement_model.dart';

class AnnouncementHelper {
  static final CollectionReference _announcementsRef =
      FirebaseFirestore.instance.collection('announcements');

  /// Post a new announcement
  static Future<void> postAnnouncement(String text, AdminModel admin) async {
    try {
      await _announcementsRef.add({
        'text': text,
        'author': '${admin.firstName} ${admin.lastName}',
        'timestamp': FieldValue.serverTimestamp(),
        'adminId': admin.uid,
        'subject': admin.jobTitle, // Using jobTitle as subject identifier
      });
    } catch (e) {
      throw Exception('Failed to post announcement: $e');
    }
  }

  /// Edit an existing announcement
  static Future<void> editAnnouncement(String announcementId, String newText) async {
    try {
      await _announcementsRef.doc(announcementId).update({
        'text': newText,
        'timestamp': FieldValue.serverTimestamp(), // Update timestamp on edit
      });
    } catch (e) {
      throw Exception('Failed to edit announcement: $e');
    }
  }

  /// Delete an announcement
  static Future<void> deleteAnnouncement(String announcementId) async {
    try {
      await _announcementsRef.doc(announcementId).delete();
    } catch (e) {
      throw Exception('Failed to delete announcement: $e');
    }
  }

  /// Get announcements stream for a specific subject (admin's jobTitle)
  static Stream<List<AnnouncementModel>> getAnnouncementsStream(String subject) {
    return _announcementsRef
        .where('subject', isEqualTo: subject)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AnnouncementModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  /// Get announcements for students (by subject)
  static Stream<List<AnnouncementModel>> getStudentAnnouncementsStream(String subject) {
    return _announcementsRef
        .where('subject', isEqualTo: subject)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AnnouncementModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }
}
