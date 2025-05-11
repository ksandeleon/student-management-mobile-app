import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:true_studentmgnt_mobapp/features/auth/data/models/admin_model.dart';


class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _adminCollection =
      FirebaseFirestore.instance.collection('admins');

  // Get all admins
  Future<List<AdminModel>> getAllAdmins() async {
    try {
      final snapshot = await _adminCollection.get();
      return snapshot.docs.map((doc) {
        final map = doc.data() as Map<String, dynamic>;
        map['uid'] = doc.id; // ensure doc ID is used as uid
        return AdminModel.fromMap(map);
      }).toList();
    } catch (e) {
      print('Error getting admins: $e');
      return [];
    }
  }

  // Add a new admin
  Future<void> addAdmin(AdminModel admin) async {
    try {
      await _adminCollection.doc(admin.uid).set(admin.toMap());
    } catch (e) {
      print('Error adding admin: $e');
    }
  }

  // Get a single admin by UID
  Future<AdminModel?> getAdminById(String uid) async {
    try {
      final doc = await _adminCollection.doc(uid).get();
      if (doc.exists) {
        final map = doc.data() as Map<String, dynamic>;
        map['uid'] = doc.id;
        return AdminModel.fromMap(map);
      }
    } catch (e) {
      print('Error fetching admin by ID: $e');
    }
    return null;
  }

  // Update admin
  Future<void> updateAdmin(AdminModel admin) async {
    try {
      await _adminCollection.doc(admin.uid).update(admin.toMap());
    } catch (e) {
      print('Error updating admin: $e');
    }
  }

  // Delete admin
  Future<void> deleteAdmin(String uid) async {
    try {
      await _adminCollection.doc(uid).delete();
    } catch (e) {
      print('Error deleting admin: $e');
    }
  }
}
