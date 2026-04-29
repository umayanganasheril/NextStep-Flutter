import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:developer' as dev;
import 'package:path/path.dart' as p;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a CV file to Firebase Storage and returns the download URL
  Future<String?> uploadCV(File file, String uid) async {
    try {
      final extension = p.extension(file.path);
      final fileName = 'cv_${DateTime.now().millisecondsSinceEpoch}$extension';
      final ref = _storage.ref().child('users/$uid/cvs/$fileName');

      dev.log('Starting upload to \${ref.fullPath}...');
      
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      dev.log('Upload complete! URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      dev.log('Error uploading CV: $e');
      return null;
    }
  }

  /// Uploads a profile picture to Firebase Storage and returns the download URL
  Future<String?> uploadProfilePicture(File file, String uid) async {
    try {
      final extension = p.extension(file.path);
      final fileName = 'profile_pic_${DateTime.now().millisecondsSinceEpoch}$extension';
      final ref = _storage.ref().child('users/$uid/profile/$fileName');

      dev.log('Starting profile pic upload to ${ref.fullPath}...');
      
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      dev.log('Profile pic upload complete! URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      dev.log('Error uploading profile pic: $e');
      return null;
    }
  }
}
