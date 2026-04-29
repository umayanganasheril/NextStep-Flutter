import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  Future<void> updateProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toJson(), SetOptions(merge: true));
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  Stream<UserModel?> profileStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromJson(doc.data()!) : null);
  }
}
