import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as dev;
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates or updates a user profile in Firestore
  Future<void> saveUserProfile(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      dev.log('Error saving user profile: $e');
      throw Exception('Failed to save profile');
    }
  }

  /// Retrieves a user profile from Firestore by UID
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      dev.log('Error getting user profile: $e');
      return null;
    }
  }

  /// Real-time stream of user profile data
  Stream<UserModel?> getUserProfileStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists && doc.data() != null ? UserModel.fromMap(doc.data()!) : null);
  }
}
