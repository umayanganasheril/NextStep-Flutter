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
  final List<Map<String, dynamic>>? aiSuggestions;
  final int? aiEvaluationScore;
  int? get cvScore => aiEvaluationScore;
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
    this.aiSuggestions,
    this.aiEvaluationScore,
    this.aiRecommendedInternships,
  });

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
      aiSuggestions: (map['aiSuggestions'] as List?)?.map((e) => Map<String, dynamic>.from(e)).toList(),
      aiEvaluationScore: map['aiEvaluationScore'],
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
      'aiSuggestions': aiSuggestions,
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
    List<Map<String, dynamic>>? aiSuggestions,
    int? aiEvaluationScore,
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
      aiSuggestions: aiSuggestions ?? this.aiSuggestions,
      aiEvaluationScore: aiEvaluationScore ?? this.aiEvaluationScore,
      aiRecommendedInternships: aiRecommendedInternships ?? this.aiRecommendedInternships,
    );
  }
}
