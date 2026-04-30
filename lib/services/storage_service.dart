import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:developer' as dev;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a file to Firebase Storage and returns the download URL
  Future<String?> uploadProfileImage(String uid, File image) async {
    try {
      final ref = _storage.ref().child('profiles').child('$uid.jpg');
      final uploadTask = await ref.putFile(image);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      dev.log('Error uploading image: $e');
      return null;
    }
  }

  /// Deletes a file from Firebase Storage
  Future<void> deleteProfileImage(String uid) async {
    try {
      await _storage.ref().child('profiles').child('$uid.jpg').delete();
    } catch (e) {
      dev.log('Error deleting image: $e');
    }
  }
}
