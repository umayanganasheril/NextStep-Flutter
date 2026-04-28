import 'dart:convert';

class InternshipModel {
  final String jobId;
  final String jobTitle;
  final String companyName;
  final String? companyLogo;
  final String location;
  final bool isRemote;
  final bool isPaid;
  final String? salary;
  final String jobDescription;
  final List<String> requiredSkills;
  final String applyLink;
  final DateTime postedDate;
  final String? deadline;
  final String employmentType;
  final String source;

  InternshipModel({
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    this.companyLogo,
    required this.location,
    this.isRemote = false,
    this.isPaid = true,
    this.salary,
    required this.jobDescription,
    this.requiredSkills = const [],
    required this.applyLink,
    required this.postedDate,
    this.deadline,
    this.employmentType = 'INTERN',
    this.source = 'JSearch',
  });

  /// Known skills to detect in job descriptions
  static const List<String> _knownSkills = [
    'Python', 'Java', 'JavaScript', 'React', 'Flutter', 'SQL',
    'AWS', 'Azure', 'Node.js', 'Machine Learning', 'Data Analysis',
    'UI/UX', 'Git', 'Docker', 'Kotlin', 'Swift', 'PHP', 'MongoDB',
    'TypeScript', 'React Native', 'Django', 'Spring Boot',
    'HTML', 'CSS', 'C++', 'C#', '.NET', 'Angular', 'Vue.js',
    'Kubernetes', 'Linux', 'Firebase', 'GraphQL', 'REST API',
    'Figma', 'TensorFlow', 'PyTorch', 'Pandas', 'NumPy',
    'PostgreSQL', 'MySQL', 'Redis', 'Jenkins', 'CI/CD',
    'Agile', 'Scrum', 'Jira', 'Selenium', 'DevOps',
  ];

  /// Extract skills from job description text
  static List<String> extractSkillsFromDescription(String description) {
    final descLower = description.toLowerCase();
    final found = <String>[];
    for (final skill in _knownSkills) {
      if (descLower.contains(skill.toLowerCase())) {
        found.add(skill);
      }
    }
    return found;
  }

  /// Parse from JSearch API response JSON
  factory InternshipModel.fromJSearchJson(Map<String, dynamic> json) {
    final description = json['job_description'] as String? ?? '';
    final title = json['job_title'] as String? ?? 'Untitled Position';
    final combinedText = '$title $description';

    // Determine source from publisher
    final publisher = json['job_publisher'] as String? ?? '';
    String source = 'JSearch';
    if (publisher.toLowerCase().contains('linkedin')) {
      source = 'LinkedIn';
    } else if (publisher.toLowerCase().contains('indeed')) {
      source = 'Indeed';
    } else if (publisher.toLowerCase().contains('glassdoor')) {
      source = 'Glassdoor';
    } else if (publisher.isNotEmpty) {
      source = publisher;
    }

    // Determine if remote
    final isRemote = (json['job_is_remote'] == true) ||
        (json['job_city'] ?? '').toString().toLowerCase().contains('remote');

    // Determine location
    String location = 'Not specified';
    final city = json['job_city'] as String? ?? '';
    final state = json['job_state'] as String? ?? '';
    final country = json['job_country'] as String? ?? '';
    if (city.isNotEmpty) {
      location = city;
      if (state.isNotEmpty) location += ', $state';
      if (country.isNotEmpty) location += ', $country';
    } else if (country.isNotEmpty) {
      location = country;
    }
    if (isRemote && location == 'Not specified') {
      location = 'Remote';
    }

    // Determine if paid (check for salary info)
    final minSalary = json['job_min_salary'];
    final maxSalary = json['job_max_salary'];
    final salaryPeriod = json['job_salary_period'] as String? ?? '';
    bool isPaid = false;
    String? salary;
    if (minSalary != null || maxSalary != null) {
      isPaid = true;
      final currency = json['job_salary_currency'] ?? 'USD';
      if (minSalary != null && maxSalary != null) {
        salary = '$currency ${_formatNum(minSalary)} - ${_formatNum(maxSalary)}/$salaryPeriod';
      } else if (minSalary != null) {
        salary = '$currency ${_formatNum(minSalary)}/$salaryPeriod';
      } else {
        salary = '$currency ${_formatNum(maxSalary)}/$salaryPeriod';
      }
    }
    // Also check description for pay keywords
    if (!isPaid) {
      final descL = description.toLowerCase();
      isPaid = descL.contains('paid') ||
          descL.contains('salary') ||
          descL.contains('stipend') ||
          descL.contains('compensation') ||
          descL.contains('\$') ||
          descL.contains('per hour') ||
          descL.contains('per month');
    }

    // Parse posted date
    DateTime postedDate;
    final datePosted = json['job_posted_at_datetime_utc'] as String?;
    if (datePosted != null) {
      postedDate = DateTime.tryParse(datePosted) ?? DateTime.now();
    } else {
      postedDate = DateTime.now();
    }

    // Get deadline
    final offerExpiration = json['job_offer_expiration_datetime_utc'] as String?;

    // Get apply link
    final applyLink = json['job_apply_link'] as String? ??
        json['job_google_link'] as String? ??
        '';

    // Extract skills
    final skills = extractSkillsFromDescription(combinedText);

    // Employment type
    final empType = json['job_employment_type'] as String? ?? 'INTERN';

    // Get company logo - use API response or generate from company domain
    String? logo = json['employer_logo'] as String?;
    final employerWebsite = json['employer_website'] as String?;
    if ((logo == null || logo.isEmpty) && employerWebsite != null && employerWebsite.isNotEmpty) {
      // Use Google Favicon API as fallback
      try {
        final domain = Uri.parse(employerWebsite).host;
        logo = 'https://logo.clearbit.com/$domain';
      } catch (_) {}
    }
    // If still no logo, try to construct from employer name
    if (logo == null || logo.isEmpty) {
      final companyName = (json['employer_name'] as String? ?? '').toLowerCase().replaceAll(' ', '');
      if (companyName.isNotEmpty) {
        logo = 'https://logo.clearbit.com/$companyName.com';
      }
    }

    return InternshipModel(
      jobId: json['job_id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      jobTitle: title,
      companyName: json['employer_name'] as String? ?? 'Unknown Company',
      companyLogo: logo,
      location: location,
      isRemote: isRemote,
      isPaid: isPaid,
      salary: salary,
      jobDescription: description,
      requiredSkills: skills,
      applyLink: applyLink,
      postedDate: postedDate,
      deadline: offerExpiration,
      employmentType: empType,
      source: source,
    );
  }

  /// Parse from Remotive API response JSON
  factory InternshipModel.fromRemotiveJson(Map<String, dynamic> json) {
    final rawDescription = json['description'] as String? ?? '';
    final description = _stripHtml(rawDescription);
    final title = json['title'] as String? ?? 'Untitled Position';
    final combinedText = '$title $description';

    // Tags from Remotive (these are actual skill tags)
    final tags = (json['tags'] as List<dynamic>?)
            ?.map((t) => t.toString())
            .toList() ??
        [];

    // Extract skills from description + tags
    final detectedSkills = extractSkillsFromDescription(combinedText);
    final allSkills = <String>{...tags.take(6), ...detectedSkills};

    // Salary
    final salary = json['salary'] as String?;
    final hasSalary = salary != null && salary.isNotEmpty && salary != 'undefined';

    // Location
    final location = json['candidate_required_location'] as String? ?? 'Remote';

    // Job type
    final jobType = json['job_type'] as String? ?? 'full_time';

    // Company logo (Remotive provides real logos!)
    final logo = json['company_logo_url'] as String?;
    final companyName = json['company_name'] as String? ?? 'Unknown';

    // Posted date
    DateTime postedDate;
    final pubDate = json['publication_date'] as String?;
    if (pubDate != null) {
      postedDate = DateTime.tryParse(pubDate) ?? DateTime.now();
    } else {
      postedDate = DateTime.now();
    }

    // Apply URL (real URL from Remotive!)
    final applyUrl = json['url'] as String? ?? '';

    return InternshipModel(
      jobId: 'remotive_${json['id'] ?? DateTime.now().millisecondsSinceEpoch}',
      jobTitle: title,
      companyName: companyName,
      companyLogo: (logo != null && logo.isNotEmpty) ? logo : 'https://logo.clearbit.com/${companyName.toLowerCase().replaceAll(' ', '')}.com',
      location: location,
      isRemote: true,
      isPaid: hasSalary,
      salary: hasSalary ? salary : null,
      jobDescription: description,
      requiredSkills: allSkills.toList(),
      applyLink: applyUrl,
      postedDate: postedDate,
      employmentType: jobType.contains('intern') ? 'INTERN' : jobType,
      source: 'Remotive',
    );
  }

  /// Strip HTML tags from description text
  static String _stripHtml(String html) {
    // Remove HTML tags
    String text = html.replaceAll(RegExp(r'<[^>]*>'), ' ');
    // Decode common HTML entities
    text = text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll('\\n', '\n');
    // Collapse whitespace
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    // Limit length
    if (text.length > 2000) {
      text = '${text.substring(0, 2000)}...';
    }
    return text;
  }

  static String _formatNum(dynamic num) {
    if (num == null) return '0';
    final n = double.tryParse(num.toString()) ?? 0;
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
    return n.toStringAsFixed(0);
  }

  /// Calculate skill match percentage with user skills
  double getMatchPercentage(List<String> userSkills) {
    if (requiredSkills.isEmpty) return 0;
    final userLower = userSkills.map((s) => s.toLowerCase()).toSet();
    final matched = requiredSkills
        .where((s) => userLower.contains(s.toLowerCase()))
        .length;
    return (matched / requiredSkills.length) * 100;
  }

  /// Get time ago string
  String getTimeAgo() {
    final now = DateTime.now();
    final diff = now.difference(postedDate);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }

  /// Serialize to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'jobId': jobId,
      'jobTitle': jobTitle,
      'companyName': companyName,
      'companyLogo': companyLogo,
      'location': location,
      'isRemote': isRemote,
      'isPaid': isPaid,
      'salary': salary,
      'jobDescription': jobDescription,
      'requiredSkills': requiredSkills,
      'applyLink': applyLink,
      'postedDate': postedDate.toIso8601String(),
      'deadline': deadline,
      'employmentType': employmentType,
      'source': source,
    };
  }

  /// Deserialize from cached JSON
  factory InternshipModel.fromJson(Map<String, dynamic> json) {
    return InternshipModel(
      jobId: json['jobId'] ?? '',
      jobTitle: json['jobTitle'] ?? '',
      companyName: json['companyName'] ?? '',
      companyLogo: json['companyLogo'],
      location: json['location'] ?? '',
      isRemote: json['isRemote'] ?? false,
      isPaid: json['isPaid'] ?? true,
      salary: json['salary'],
      jobDescription: json['jobDescription'] ?? '',
      requiredSkills: List<String>.from(json['requiredSkills'] ?? []),
      applyLink: json['applyLink'] ?? '',
      postedDate: DateTime.tryParse(json['postedDate'] ?? '') ?? DateTime.now(),
      deadline: json['deadline'],
      employmentType: json['employmentType'] ?? 'INTERN',
      source: json['source'] ?? 'JSearch',
    );
  }

  /// Serialize list to JSON string for caching
  static String encodeList(List<InternshipModel> internships) {
    return jsonEncode(internships.map((i) => i.toJson()).toList());
  }

  /// Deserialize list from JSON string (cache)
  static List<InternshipModel> decodeList(String jsonString) {
    final List<dynamic> list = jsonDecode(jsonString);
    return list.map((item) => InternshipModel.fromJson(item)).toList();
  }

  /// Get a usable logo URL (with fallback)
  String? getLogoUrl() {
    if (companyLogo != null && companyLogo!.isNotEmpty) {
      return companyLogo;
    }
    // Generate from company name
    final domain = companyName.toLowerCase().replaceAll(' ', '').replaceAll('.', '');
    return 'https://logo.clearbit.com/$domain.com';
  }

  /// Fallback mock data when API is unavailable
  static List<InternshipModel> getMockInternships() {
    return [
      InternshipModel(
        jobId: 'mock_1',
        jobTitle: 'Software Engineer Intern',
        companyName: 'Virtusa',
        companyLogo: 'https://logo.clearbit.com/virtusa.com',
        location: 'Colombo, Sri Lanka',
        isRemote: false,
        isPaid: true,
        salary: 'LKR 50,000/month',
        jobDescription: 'Join our engineering team to work on enterprise Java applications. '
            'You\'ll work with Spring Boot, React, and PostgreSQL to build scalable solutions. '
            'Experience with Git and Agile methodologies preferred.',
        requiredSkills: ['Java', 'Spring Boot', 'React', 'PostgreSQL', 'Git', 'Agile'],
        applyLink: 'https://www.virtusa.com/careers',
        postedDate: DateTime.now().subtract(const Duration(days: 2)),
        employmentType: 'INTERN',
        source: 'LinkedIn',
      ),
      InternshipModel(
        jobId: 'mock_2',
        jobTitle: 'Data Science Intern',
        companyName: 'WSO2',
        companyLogo: 'https://logo.clearbit.com/wso2.com',
        location: 'Colombo, Sri Lanka',
        isRemote: true,
        isPaid: true,
        salary: 'LKR 45,000/month',
        jobDescription: 'Work with our analytics team on machine learning models. '
            'Requirements: Python, TensorFlow, Data Analysis, SQL. '
            'Knowledge of Pandas and NumPy is a plus.',
        requiredSkills: ['Python', 'Machine Learning', 'TensorFlow', 'SQL', 'Data Analysis', 'Pandas'],
        applyLink: 'https://wso2.com/careers',
        postedDate: DateTime.now().subtract(const Duration(days: 3)),
        employmentType: 'INTERN',
        source: 'Indeed',
      ),
      InternshipModel(
        jobId: 'mock_3',
        jobTitle: 'Mobile App Developer Intern',
        companyName: 'IFS',
        companyLogo: 'https://logo.clearbit.com/ifs.com',
        location: 'Colombo, Sri Lanka',
        isRemote: false,
        isPaid: true,
        jobDescription: 'Build cross-platform mobile apps using Flutter and Dart. '
            'Work with Firebase for backend services. '
            'Knowledge of REST APIs and Git required.',
        requiredSkills: ['Flutter', 'Firebase', 'REST API', 'Git'],
        applyLink: 'https://www.ifs.com/careers',
        postedDate: DateTime.now().subtract(const Duration(days: 5)),
        employmentType: 'INTERN',
        source: 'Glassdoor',
      ),
      InternshipModel(
        jobId: 'mock_4',
        jobTitle: 'Cloud Engineering Intern',
        companyName: 'Sysco LABS',
        companyLogo: 'https://logo.clearbit.com/syscolabs.com',
        location: 'Colombo, Sri Lanka',
        isRemote: true,
        isPaid: true,
        salary: 'LKR 55,000/month',
        jobDescription: 'Assist in building cloud infrastructure on AWS. '
            'Work with Docker containers and Kubernetes orchestration. '
            'DevOps experience with CI/CD pipelines is a plus. Linux required.',
        requiredSkills: ['AWS', 'Docker', 'Kubernetes', 'DevOps', 'Linux', 'CI/CD'],
        applyLink: 'https://syscolabs.lk/careers',
        postedDate: DateTime.now().subtract(const Duration(days: 1)),
        employmentType: 'INTERN',
        source: 'LinkedIn',
      ),
      InternshipModel(
        jobId: 'mock_5',
        jobTitle: 'Frontend Developer Intern',
        companyName: '99x',
        companyLogo: 'https://logo.clearbit.com/99x.io',
        location: 'Colombo, Sri Lanka',
        isRemote: true,
        isPaid: true,
        jobDescription: 'Build modern UIs using React and TypeScript. '
            'Work with the design team using Figma. '
            'Experience with HTML, CSS, and JavaScript required. Angular knowledge is a plus.',
        requiredSkills: ['React', 'TypeScript', 'JavaScript', 'HTML', 'CSS', 'Figma'],
        applyLink: 'https://99x.io/careers',
        postedDate: DateTime.now().subtract(const Duration(days: 4)),
        employmentType: 'INTERN',
        source: 'Indeed',
      ),
      InternshipModel(
        jobId: 'mock_6',
        jobTitle: 'Backend Developer Intern',
        companyName: 'Google',
        companyLogo: 'https://logo.clearbit.com/google.com',
        location: 'Mountain View, CA, US',
        isRemote: true,
        isPaid: true,
        salary: 'USD 8K/month',
        jobDescription: 'Work on Google\'s core infrastructure using Python and Go. '
            'Experience with Kubernetes, Docker, and cloud services. '
            'Strong CS fundamentals required.',
        requiredSkills: ['Python', 'Kubernetes', 'Docker', 'SQL', 'Git', 'Linux'],
        applyLink: 'https://careers.google.com',
        postedDate: DateTime.now().subtract(const Duration(days: 1)),
        employmentType: 'INTERN',
        source: 'LinkedIn',
      ),
      InternshipModel(
        jobId: 'mock_7',
        jobTitle: 'Full Stack Developer Intern',
        companyName: 'Microsoft',
        companyLogo: 'https://logo.clearbit.com/microsoft.com',
        location: 'Redmond, WA, US',
        isRemote: true,
        isPaid: true,
        salary: 'USD 7.5K/month',
        jobDescription: 'Build web applications with React, TypeScript, and Azure. '
            'Experience with .NET, C#, and SQL Server preferred. '
            'Agile development environment.',
        requiredSkills: ['React', 'TypeScript', 'Azure', 'C#', '.NET', 'SQL', 'Agile'],
        applyLink: 'https://careers.microsoft.com',
        postedDate: DateTime.now().subtract(const Duration(days: 3)),
        employmentType: 'INTERN',
        source: 'LinkedIn',
      ),
      InternshipModel(
        jobId: 'mock_8',
        jobTitle: 'DevOps Engineer Intern',
        companyName: 'Amazon',
        companyLogo: 'https://logo.clearbit.com/amazon.com',
        location: 'Seattle, WA, US',
        isRemote: false,
        isPaid: true,
        salary: 'USD 8.5K/month',
        jobDescription: 'Help automate CI/CD pipelines and manage AWS infrastructure. '
            'Work with Docker, Jenkins, and Terraform. '
            'Python scripting and Linux administration skills needed.',
        requiredSkills: ['AWS', 'Docker', 'Jenkins', 'CI/CD', 'Python', 'Linux', 'DevOps'],
        applyLink: 'https://www.amazon.jobs',
        postedDate: DateTime.now().subtract(const Duration(days: 2)),
        employmentType: 'INTERN',
        source: 'Indeed',
      ),
    ];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InternshipModel && jobId == other.jobId;

  @override
  int get hashCode => jobId.hashCode;
}
