import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as dev;

class AIService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Saves a chat message to Firestore
  Future<void> saveChatMessage(String userId, Map<String, dynamic> message) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('chat_history')
          .add({
        ...message,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      dev.log('Error saving chat message: $e');
    }
  }

  /// Saves a mock interview session
  Future<void> saveInterviewSession(String userId, Map<String, dynamic> sessionData) async {
    try {
      await _firestore
          .collection('mock_interviews')
          .add({
        'userId': userId,
        ...sessionData,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      dev.log('Error saving interview session: $e');
    }
  }

  /// Saves an AI evaluation result
  Future<void> saveEvaluation(String userId, Map<String, dynamic> evaluationData) async {
    try {
      await _firestore
          .collection('ai_evaluations')
          .add({
        'userId': userId,
        ...evaluationData,
        'date': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      dev.log('Error saving evaluation: $e');
    }
  }

  /// Streams chat history for a user
  Stream<QuerySnapshot> getChatHistory(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('chat_history')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  /// Generates AI career insights based on text
  static Future<Map<String, dynamic>?> generateCareerInsights(String text) async {
    await Future.delayed(const Duration(seconds: 2));
    return {
      'evaluationScore': 85.0,
      'evaluationSummary': 'Excellent background in software engineering with strong Flutter skills.',
      'suggestions': [
        {'title': 'Add more projects', 'description': 'Try to add more real-world projects to your portfolio.', 'isPositive': false},
        {'title': 'Strong technical skills', 'description': 'Your technical skills are impressive.', 'isPositive': true},
      ],
      'careerPaths': [
        {'title': 'Full-stack Developer', 'description': 'Developing both frontend and backend.'},
        {'title': 'Mobile App Developer', 'description': 'Specializing in Flutter and Native apps.'},
      ],
      'extractedSkills': ['Flutter', 'Dart', 'Firebase', 'Git'],
      'recommendedInternships': [
        {'jobTitle': 'Frontend Intern', 'companyName': 'Tech Corp', 'location': 'Remote'},
      ],
    };
  }
}
