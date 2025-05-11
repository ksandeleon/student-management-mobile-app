import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:true_studentmgnt_mobapp/features/auth/data/models/admin_model.dart';
import 'package:true_studentmgnt_mobapp/features/auth/data/models/announcement_model.dart';

class AnnouncementHelper {
  static final CollectionReference _announcementsRef =
      FirebaseFirestore.instance.collection('announcements');

  /// POST a new announcement
  static Future<void> postAnnouncement(String text, AdminModel admin) async {
    await _announcementsRef.add({
      'text': text.trim(),
      'author': '${admin.firstName} ${admin.lastName}',
      'timestamp': FieldValue.serverTimestamp(),
      'adminId': admin.uid,
      'subject': admin.jobTitle,
    });
  }

  /// GET all announcements by job title (subject)
  static Future<List<AnnouncementModel>> getAnnouncementsByJobTitle(String jobTitle) async {
    final querySnapshot = await _announcementsRef
        .where('subject', isEqualTo: jobTitle)
        .orderBy('timestamp', descending: true)
        .get();

    return querySnapshot.docs.map((doc) {
      return AnnouncementModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  /// EDIT an announcement by document ID
  static Future<void> editAnnouncement(String id, String newText) async {
    await _announcementsRef.doc(id).update({
      'text': newText.trim(),
      'timestamp': FieldValue.serverTimestamp(), // optional: update time
    });
  }

  /// DELETE an announcement by document ID
  static Future<void> deleteAnnouncement(String id) async {
    await _announcementsRef.doc(id).delete();
  }
}
