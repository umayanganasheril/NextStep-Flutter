import 'package:flutter/material.dart';

class CareerPath {
  final String id;
  final String title;
  final String tagline;
  final List<String> skills;
  final String imageUrl;
  final String details;
  final IconData icon;
  final Color color;

  CareerPath({
    required this.id,
    required this.title,
    required this.tagline,
    required this.skills,
    this.imageUrl = '',
    this.details = '',
    this.icon = Icons.work_outline,
    this.color = const Color(0xFF2196F3),
  });

  /// Calculate skill match percentage against user skills
  double calculateMatchPercentage(List<String> userSkills) {
    if (skills.isEmpty) return 0;
    final userSkillsLower = userSkills.map((s) => s.toLowerCase()).toSet();
    final matchCount = skills
        .where((s) => userSkillsLower.contains(s.toLowerCase()))
        .length;
    return (matchCount / skills.length) * 100;
  }

  /// Get match label based on percentage
  String getMatchLabel(List<String> userSkills) {
    final pct = calculateMatchPercentage(userSkills);
    if (pct >= 80) return 'High Match';
    if (pct >= 50) return 'Medium Match';
    return 'Low Match';
  }

  Color getMatchColor(List<String> userSkills) {
    final pct = calculateMatchPercentage(userSkills);
    if (pct >= 80) return const Color(0xFF10B981);
    if (pct >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  static List<CareerPath> getSamplePaths() {
    return [
      CareerPath(
        id: '1',
        title: 'Full Stack Developer',
        tagline: 'Crafting Seamless Web Experiences',
        skills: ['JavaScript', 'React', 'Node.js', 'SQL', 'HTML/CSS', 'Git'],
        icon: Icons.code,
        color: const Color(0xFF6366F1),
        details:
            'Full Stack Developers build both the front-end and back-end of web applications. They work with databases, server logic, APIs, and user-facing interfaces to create complete web solutions.',
      ),
      CareerPath(
        id: '2',
        title: 'Data Scientist',
        tagline: 'Unlocking Insights from Data',
        skills: [
          'Python',
          'Machine Learning',
          'Data Analysis',
          'SQL',
          'Statistics',
          'TensorFlow'
        ],
        icon: Icons.analytics_outlined,
        color: const Color(0xFF8B5CF6),
        details:
            'Data Scientists analyze large datasets to find patterns and insights that drive business decisions. They use statistical methods, machine learning, and data visualization techniques.',
      ),
      CareerPath(
        id: '3',
        title: 'Cloud Engineer',
        tagline: 'Building Scalable Cloud Solutions',
        skills: ['AWS', 'Azure', 'DevOps', 'Docker', 'Kubernetes', 'Linux'],
        icon: Icons.cloud_outlined,
        color: const Color(0xFF0EA5E9),
        details:
            'Cloud Engineers design, implement, and manage cloud infrastructure. They work with cloud platforms to build scalable, reliable, and secure applications.',
      ),
      CareerPath(
        id: '4',
        title: 'Mobile App Developer',
        tagline: 'Creating Apps People Love',
        skills: [
          'Flutter',
          'Dart',
          'React Native',
          'Swift',
          'Kotlin',
          'Firebase'
        ],
        icon: Icons.phone_android,
        color: const Color(0xFF14B8A6),
        details:
            'Mobile App Developers build applications for smartphones and tablets. They create native or cross-platform apps that provide smooth, intuitive user experiences.',
      ),
      CareerPath(
        id: '5',
        title: 'AI/ML Engineer',
        tagline: 'Shaping the Future with AI',
        skills: [
          'Python',
          'TensorFlow',
          'PyTorch',
          'Machine Learning',
          'Deep Learning',
          'NLP'
        ],
        icon: Icons.psychology_outlined,
        color: const Color(0xFFEC4899),
        details:
            'AI/ML Engineers develop artificial intelligence and machine learning models. They design algorithms that enable machines to learn from data and make predictions.',
      ),
      CareerPath(
        id: '6',
        title: 'Cybersecurity Analyst',
        tagline: 'Defending the Digital World',
        skills: [
          'Network Security',
          'Ethical Hacking',
          'Linux',
          'Python',
          'SIEM',
          'Cryptography'
        ],
        icon: Icons.security_outlined,
        color: const Color(0xFFEF4444),
        details:
            'Cybersecurity Analysts protect organizations from cyber threats. They monitor systems, analyze vulnerabilities, and implement security measures to safeguard data.',
      ),
    ];
  }
}