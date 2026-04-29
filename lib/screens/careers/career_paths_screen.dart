import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../models/career_path_model.dart';
import '../../services/ai_service.dart';

class CareerPathsScreen extends StatefulWidget {
  const CareerPathsScreen({super.key});

  @override
  State<CareerPathsScreen> createState() => _CareerPathsScreenState();
}

class _CareerPathsScreenState extends State<CareerPathsScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndFetchAIInsights();
    });
  }

  Future<void> _checkAndFetchAIInsights() async {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    
    if (user != null && user.cvText != null && user.cvText!.isNotEmpty) {
      if (user.aiCareerPaths == null) {
        setState(() => _isLoading = true);
        final insights = await AIService.generateCareerInsights(user.cvText!);
        
        if (insights != null && mounted) {
          await auth.updateUser(user.copyWith(
            aiEvaluationScore: insights['evaluationScore']?.toDouble(),
            aiEvaluationSummary: insights['evaluationSummary'],
            aiSuggestions: insights['suggestions'],
            aiCareerPaths: insights['careerPaths'],
            technicalSkills: insights['extractedSkills'] != null 
                ? List<String>.from(insights['extractedSkills']) 
                : user.technicalSkills,
            aiRecommendedInternships: insights['recommendedInternships'],
          ));
        }
        
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.user;
        final userSkills = user?.technicalSkills ?? [];

        List<CareerPath> sortedPaths;
        if (user?.aiCareerPaths != null && user!.aiCareerPaths!.isNotEmpty) {
          int i = 0;
          final List<Color> pathColors = [
            const Color(0xFF6366F1), // Indigo
            const Color(0xFF10B981), // Emerald
            const Color(0xFFF59E0B), // Amber
            const Color(0xFFEC4899), // Pink
            const Color(0xFF8B5CF6), // Violet
          ];
          
          sortedPaths = user.aiCareerPaths!.map((path) {
            final color = pathColors[i % pathColors.length];
            i++;
            return CareerPath(
              id: 'ai_path_$i',
              title: path['title'] ?? 'Career Path',
              tagline: path['tagline'] ?? '',
              details: path['details'] ?? '',
              skills: List<String>.from(path['skills'] ?? []),
              icon: Icons.auto_awesome, // Default icon
              color: color,
            );
          }).toList();
        } else {
          final careerPaths = CareerPath.getSamplePaths();
          sortedPaths = List<CareerPath>.from(careerPaths)
            ..sort((a, b) => b
                .calculateMatchPercentage(userSkills)
                .compareTo(a.calculateMatchPercentage(userSkills)));
        }

        return Scaffold(
          backgroundColor: AppTheme.bgLight,
          body: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Career Paths',
                            style: GoogleFonts.inter(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Based on your skills, here are some potential career paths:',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                              height: 1.4,
                            ),
                          ),
                          if (userSkills.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: userSkills.take(5).map((skill) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    skill,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              if (_isLoading)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: AppTheme.primaryBlue),
                        const SizedBox(height: 16),
                        Text(
                          'AI is planning your career...',
                          style: GoogleFonts.inter(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
              // Career cards
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final career = sortedPaths[index];
                      final matchPct =
                          career.calculateMatchPercentage(userSkills);
                      final matchLabel = career.getMatchLabel(userSkills);
                      final matchColor = career.getMatchColor(userSkills);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Column(
                          children: [
                            // Header with gradient
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    career.color,
                                    career.color.withValues(alpha: 0.7),
                                  ],
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Colors.white
                                          .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      career.icon,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          career.title,
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          career.tagline,
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            color: Colors.white
                                                .withValues(alpha: 0.85),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Content
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Match indicator
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: matchColor
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              matchPct >= 50
                                                  ? Icons
                                                      .trending_up_rounded
                                                  : Icons
                                                      .trending_down_rounded,
                                              size: 14,
                                              color: matchColor,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '$matchLabel (${matchPct.round()}%)',
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: matchColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),

                                  // Skills
                                  Text(
                                    'Required Skills',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: career.skills.map((skill) {
                                      final hasSkill = userSkills
                                          .map((s) => s.toLowerCase())
                                          .contains(skill.toLowerCase());
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: hasSkill
                                              ? AppTheme.success
                                                  .withValues(alpha: 0.1)
                                              : const Color(0xFFF3F4F6),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: hasSkill
                                                ? AppTheme.success
                                                    .withValues(alpha: 0.3)
                                                : const Color(0xFFE5E7EB),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (hasSkill)
                                              const Padding(
                                                padding:
                                                    EdgeInsets.only(right: 4),
                                                child: Icon(
                                                    Icons.check_circle,
                                                    size: 12,
                                                    color: AppTheme.success),
                                              ),
                                            Text(
                                              skill,
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: hasSkill
                                                    ? AppTheme.success
                                                    : AppTheme.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 16),

                                  // More Details button
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        _showCareerDetails(
                                            context, career, matchPct);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: career.color,
                                        side: BorderSide(color: career.color),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                      ),
                                      child: Text(
                                        'More Details',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: sortedPaths.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        );
      },
    );
  }

  void _showCareerDetails(
      BuildContext context, CareerPath career, double matchPct) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [career.color, career.color.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(career.icon, color: Colors.white, size: 40),
                    const SizedBox(height: 12),
                    Text(
                      career.title,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      career.tagline,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Match: ${matchPct.round()}%',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Details
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About This Career',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        career.details,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Required Skills',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: career.skills.map((skill) {
                          return Chip(
                            label: Text(skill,
                                style: GoogleFonts.inter(fontSize: 13)),
                            backgroundColor:
                                career.color.withValues(alpha: 0.1),
                            side: BorderSide(
                                color: career.color.withValues(alpha: 0.3)),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );   
      },
    );
  }
}