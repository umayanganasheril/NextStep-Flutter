import 'package:flutter/material.dart';

class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String? photoURL;
  final String bio;
  final bool profileComplete;
  final List<String> technicalSkills;
  final List<String> careerInterests;
  final String? university;
  final String? degreeProgram;
  final String? yearOfStudy;
  final String? cvText;
  final String? cvUrl;
  final String? cvFileName;
  final DateTime? cvUploadDate;
  final int? cvFileSize;
  final String? aiEvaluationSummary;
  final List<Map<String, dynamic>>? aiSuggestions;
  final List<Map<String, dynamic>>? aiCareerPaths;
  final double? aiEvaluationScore;
  final List<Map<String, dynamic>>? aiRecommendedInternships;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoURL,
    this.bio = '',
    this.profileComplete = false,
    this.technicalSkills = const [],
    this.careerInterests = const [],
    this.university,
    this.degreeProgram,
    this.yearOfStudy,
    this.cvText,
    this.cvUrl,
    this.cvFileName,
    this.cvUploadDate,
    this.cvFileSize,
    this.aiEvaluationSummary,
    this.aiSuggestions,
    this.aiCareerPaths,
    this.aiEvaluationScore,
    this.aiRecommendedInternships,
  });

  int? get cvScore => aiEvaluationScore?.round();

  double calculateEvaluationScore() {
    return aiEvaluationScore ?? 0.0;
  }

  String getScoreLabel() {
    final score = calculateEvaluationScore();
    if (score >= 8.0) return 'EXCELLENT';
    if (score >= 6.0) return 'GOOD';
    if (score >= 4.0) return 'AVERAGE';
    return 'WEAK';
  }

  dynamic getScoreColor() {
    final score = calculateEvaluationScore();
    if (score >= 8.0) return const Color(0xFF10B981);
    if (score >= 6.0) return const Color(0xFF3B82F6);
    if (score >= 4.0) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      displayName: map['displayName'] ?? '',
      email: map['email'] ?? '',
      photoURL: map['photoURL'],
      bio: map['bio'] ?? '',
      profileComplete: map['profileComplete'] ?? false,
      technicalSkills: List<String>.from(map['technicalSkills'] ?? []),
      careerInterests: List<String>.from(map['careerInterests'] ?? []),
      university: map['university'],
      degreeProgram: map['degreeProgram'],
      yearOfStudy: map['yearOfStudy'],
      cvText: map['cvText'],
      cvUrl: map['cvUrl'],
      cvFileName: map['cvFileName'],
      cvUploadDate: map['cvUploadDate'] != null ? DateTime.tryParse(map['cvUploadDate']) : null,
      cvFileSize: map['cvFileSize'],
      aiEvaluationSummary: map['aiEvaluationSummary'],
      aiSuggestions: (map['aiSuggestions'] as List?)?.map((e) => Map<String, dynamic>.from(e)).toList(),
      aiCareerPaths: (map['aiCareerPaths'] as List?)?.map((e) => Map<String, dynamic>.from(e)).toList(),
      aiEvaluationScore: (map['aiEvaluationScore'] as num?)?.toDouble(),
      aiRecommendedInternships: (map['aiRecommendedInternships'] as List?)?.map((e) => Map<String, dynamic>.from(e)).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
      'bio': bio,
      'profileComplete': profileComplete,
      'technicalSkills': technicalSkills,
      'careerInterests': careerInterests,
      'university': university,
      'degreeProgram': degreeProgram,
      'yearOfStudy': yearOfStudy,
      'cvText': cvText,
      'cvUrl': cvUrl,
      'cvFileName': cvFileName,
      'cvUploadDate': cvUploadDate?.toIso8601String(),
      'cvFileSize': cvFileSize,
      'aiEvaluationSummary': aiEvaluationSummary,
      'aiSuggestions': aiSuggestions,
      'aiCareerPaths': aiCareerPaths,
      'aiEvaluationScore': aiEvaluationScore,
      'aiRecommendedInternships': aiRecommendedInternships,
    };
  }

  UserModel copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoURL,
    String? bio,
    bool? profileComplete,
    List<String>? technicalSkills,
    List<String>? careerInterests,
    String? university,
    String? degreeProgram,
    String? yearOfStudy,
    String? cvText,
    String? cvUrl,
    String? cvFileName,
    DateTime? cvUploadDate,
    int? cvFileSize,
    String? aiEvaluationSummary,
    List<Map<String, dynamic>>? aiSuggestions,
    List<Map<String, dynamic>>? aiCareerPaths,
    double? aiEvaluationScore,
    List<Map<String, dynamic>>? aiRecommendedInternships,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoURL: photoURL ?? this.photoURL,
      bio: bio ?? this.bio,
      profileComplete: profileComplete ?? this.profileComplete,
      technicalSkills: technicalSkills ?? this.technicalSkills,
      careerInterests: careerInterests ?? this.careerInterests,
      university: university ?? this.university,
      degreeProgram: degreeProgram ?? this.degreeProgram,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      cvText: cvText ?? this.cvText,
      cvUrl: cvUrl ?? this.cvUrl,
      cvFileName: cvFileName ?? this.cvFileName,
      cvUploadDate: cvUploadDate ?? this.cvUploadDate,
      cvFileSize: cvFileSize ?? this.cvFileSize,
      aiEvaluationSummary: aiEvaluationSummary ?? this.aiEvaluationSummary,
      aiSuggestions: aiSuggestions ?? this.aiSuggestions,
      aiCareerPaths: aiCareerPaths ?? this.aiCareerPaths,
      aiEvaluationScore: aiEvaluationScore ?? this.aiEvaluationScore,
      aiRecommendedInternships: aiRecommendedInternships ?? this.aiRecommendedInternships,
    );
  }
}
