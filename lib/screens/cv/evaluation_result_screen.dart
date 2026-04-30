import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../models/career_path_model.dart';
import 'cv_upload_screen.dart';
class EvaluationResultScreen extends StatefulWidget {
  const EvaluationResultScreen({super.key});

  @override
  State<EvaluationResultScreen> createState() => _EvaluationResultScreenState();
}

class _EvaluationResultScreenState extends State<EvaluationResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.user;
        
        // Use AI score if available, otherwise fallback to local calculation
        final score = user?.aiEvaluationScore ?? user?.calculateEvaluationScore() ?? 0.0;
        final scoreLabel = user?.getScoreLabel() ?? 'N/A'; // We can still use the same label logic
        final scoreColor = user?.getScoreColor() ?? AppTheme.textLight; // And color logic
        final percentRank = (score * 10).round().clamp(0, 100);
        final userSkills = user?.technicalSkills ?? [];

        // Determine which career paths to show (AI or local fallback)
        CareerPath? bestMatch;
        double matchPct = 0;
        
        if (user?.aiCareerPaths != null && user!.aiCareerPaths!.isNotEmpty) {
          final firstAiPath = user.aiCareerPaths!.first;
          bestMatch = CareerPath(
            id: 'ai_1',
            title: firstAiPath['title'] ?? '',
            tagline: firstAiPath['tagline'] ?? '',
            details: firstAiPath['details'] ?? '',
            skills: List<String>.from(firstAiPath['skills'] ?? []),
            icon: Icons.auto_awesome,
            color: const Color(0xFF6366F1),
          );
          matchPct = bestMatch.calculateMatchPercentage(userSkills);
        } else {
          // Get career paths and find best match
          final careerPaths = CareerPath.getSamplePaths();
          careerPaths.sort((a, b) => b
              .calculateMatchPercentage(userSkills)
              .compareTo(a.calculateMatchPercentage(userSkills)));
  
          bestMatch = careerPaths.isNotEmpty ? careerPaths.first : null;
          matchPct = bestMatch?.calculateMatchPercentage(userSkills) ?? 0;
        }

        return Scaffold(
          backgroundColor: AppTheme.bgLight,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 20, color: AppTheme.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'ATS Evaluation Result',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            centerTitle: true,
          ),
          body: (user?.cvText == null || user!.cvText!.isEmpty)
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload_file_rounded, size: 80, color: AppTheme.primaryBlue.withValues(alpha: 0.5)),
                        const SizedBox(height: 24),
                        Text(
                          'No CV Uploaded',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Please upload your CV to receive an ATS-friendly evaluation score and AI-powered career suggestions.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // Go back
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const CvUploadScreen()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            'Upload CV Now',
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
             padding: const EdgeInsets.all(20),
             child: Column(
               children: [
                 // Score display card
                 Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [scoreColor, scoreColor.withValues(alpha: 0.8)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: scoreColor.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.2),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 4,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              score.toStringAsFixed(1),
                              style: GoogleFonts.inter(
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          scoreLabel,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your profile is in the top $percentRank% of applicants',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Skill Match section
                if (bestMatch != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Skill Match',
                              style: GoogleFonts.inter(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: bestMatch
                                    .getMatchColor(userSkills)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Match ${matchPct.round()}%',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: bestMatch.getMatchColor(userSkills),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Text(
                          'Best match: ${bestMatch.title}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Skills progress bars
                        ...bestMatch.skills
                            .take(6)
                            .map((skill) => _buildSkillBar(skill, userSkills)),
                      ],
                    ),
                  ),
                ],

                // test commit changegit 

                const SizedBox(height: 20),

                // Suggestions
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ATS Suggestions',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'AI-generated insights to improve your score',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Show AI Summary if available
                      if (user.aiEvaluationSummary != null) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.auto_awesome, color: AppTheme.primaryBlue, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  user.aiEvaluationSummary!,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppTheme.textPrimary,
                                    height: 1.4,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Handles CV file selection, PDF text extraction, and AI analysis

                      if (user.aiSuggestions != null)
                        ...user.aiSuggestions!.map((sugg) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildSuggestion(
                            icon: sugg['isPositive'] == true ? Icons.check_circle_rounded : Icons.lightbulb_outline,
                            color: sugg['isPositive'] == true ? AppTheme.success : AppTheme.primaryBlue,
                            title: sugg['title'] ?? 'Suggestion',
                            description: sugg['description'] ?? '',
                            isPositive: sugg['isPositive'] == true,
                          ),
                        ))
                      else ...[
                        _buildSuggestion(
                          icon: Icons.warning_amber_rounded,
                          color: AppTheme.warning,
                          title: 'Add More Metrics',
                          description:
                              'Include quantifiable achievements in your CV to stand out',
                          isPositive: false,
                        ),
                        const SizedBox(height: 12),
                        _buildSuggestion(
                          icon: Icons.check_circle_rounded,
                          color: AppTheme.success,
                          title: 'Great Formatting',
                          description:
                              'Your profile structure follows best practices',
                          isPositive: true,
                        ),
                        const SizedBox(height: 12),
                        _buildSuggestion(
                          icon: userSkills.length >= 5
                              ? Icons.check_circle_rounded
                              : Icons.warning_amber_rounded,
                          color: userSkills.length >= 5
                              ? AppTheme.success
                              : AppTheme.warning,
                          title: userSkills.length >= 5
                              ? 'Good Skill Coverage'
                              : 'Add More Skills',
                          description: userSkills.length >= 5
                              ? 'You have a solid range of technical skills'
                              : 'Add more technical skills to improve your match score',
                          isPositive: userSkills.length >= 5,
                        ),
                        const SizedBox(height: 12),
                        _buildSuggestion(
                          icon: user.cvUrl != null
                              ? Icons.check_circle_rounded
                              : Icons.warning_amber_rounded,
                          color: user.cvUrl != null
                              ? AppTheme.success
                              : AppTheme.error,
                          title: user.cvUrl != null
                              ? 'CV Uploaded'
                              : 'Upload Your CV',
                          description: user.cvUrl != null
                              ? 'Your resume is on file and contributing to your score'
                              : 'Upload your CV to boost your evaluation score by 25%',
                          isPositive: user.cvUrl != null,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkillBar(String skill, List<String> userSkills) {
    final hasSkill = userSkills
        .map((s) => s.toLowerCase())
        .contains(skill.toLowerCase());
    final percentage = hasSkill ? 1.0 : 0.0;
    final matchLabel = hasSkill ? 'High Match' : 'Low Match';
    final matchColor = hasSkill ? AppTheme.success : AppTheme.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                skill,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                matchLabel,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: matchColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearPercentIndicator(
            lineHeight: 8,
            percent: percentage,
            backgroundColor: matchColor.withValues(alpha: 0.12),
            progressColor: matchColor,
            barRadius: const Radius.circular(4),
            padding: EdgeInsets.zero,
            animation: true,
            animationDuration: 1000,
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestion({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
