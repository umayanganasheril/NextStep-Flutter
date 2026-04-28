import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/internship_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/internship_provider.dart';
import '../cv/cv_upload_screen.dart';
import '../navigation/main_navigation.dart';
import '../ai_features/mock_interview_screen.dart';
import 'widgets/quick_access_card.dart';
import 'widgets/real_job_card.dart';
import 'widgets/career_tip_card.dart';
import 'widgets/home_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger internship fetch so data is ready when user navigates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<InternshipProvider>();
      final authUser = context.read<AuthProvider>().user;
      
      List<InternshipModel>? aiInternships;
      if (authUser?.aiRecommendedInternships != null) {
        aiInternships = authUser!.aiRecommendedInternships!.map<InternshipModel>((json) => InternshipModel(
          jobId: 'ai_${json.hashCode}',
          jobTitle: json['jobTitle'] ?? 'Internship',
          companyName: json['companyName'] ?? 'AI Selected Company',
          location: json['location'] ?? 'Remote',
          isRemote: (json['location'] ?? '').toLowerCase().contains('remote'),
          jobDescription: json['jobDescription'] ?? '',
          requiredSkills: List<String>.from(json['requiredSkills'] ?? []),
          employmentType: 'INTERN',
          postedDate: DateTime.now(),
          isPaid: true,
          applyLink: '',
        )).toList();
      }

      if (provider.internships.isEmpty && !provider.isLoading) {
        provider.fetchInternships(forceRefresh: true, aiMockInternships: aiInternships);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final internshipProvider = context.watch<InternshipProvider>();
    final user = auth.user;
    final name = user?.name ?? 'Student';
    final firstName = name.split(' ').first;
    final score = user?.calculateEvaluationScore() ?? 0.0;
    final cvPercent = ((score / 10.0) * 100).round();
    final userSkills = user?.technicalSkills ?? [];
    final recommended = internshipProvider.getRecommended(userSkills);

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(
        slivers: [
          // ─── Header with greeting ───
          SliverToBoxAdapter(
            child: HomeHeader(
              user: user,
              firstName: firstName,
              cvPercent: cvPercent,
            ),
          ),

          // ─── Quick access grid ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Text(
                'Quick Access',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.1,
              children: [
                QuickAccessCard(
                  icon: Icons.route_rounded,
                  title: 'Career Path',
                  subtitle: 'Explore paths',
                  color: const Color(0xFF6366F1),
                  onTap: () => MainNavigation.switchTab(context, 1),
                ),
                QuickAccessCard(
                  icon: Icons.business_center_rounded,
                  title: 'Internship\nOpenings',
                  subtitle: 'Find opportunities',
                  color: const Color(0xFF0EA5E9),
                  onTap: () => MainNavigation.switchTab(context, 2),
                ),
                QuickAccessCard(
                  icon: Icons.upload_file_rounded,
                  title: 'CV Upload',
                  subtitle: 'Update resume',
                  color: const Color(0xFF14B8A6),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CvUploadScreen()),
                  ),
                ),
                QuickAccessCard(
                  icon: Icons.record_voice_over_rounded,
                  title: 'Interview\nPrep',
                  subtitle: 'Practice questions',
                  color: const Color(0xFF8B5CF6),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const MockInterviewScreen()),
                  ),
                ),
              ],
            ),
          ),

          // ─── Recommended Jobs section (REAL DATA) ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.auto_awesome,
                            size: 16, color: AppTheme.primaryBlue),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Recommended Jobs',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => MainNavigation.switchTab(context, 2),
                    child: Text(
                      'See All',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Recommended cards (horizontal scroll)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 190,
              child: internshipProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.primaryBlue))
                  : recommended.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              'Complete your profile to get personalized recommendations',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: recommended.length,
                          itemBuilder: (ctx, i) => Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: RealJobCard(
                              internship: recommended[i],
                              userSkills: userSkills,
                            ),
                          ),
                        ),
            ),
          ),

          // ─── Tips section ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
              child: Text(
                'Career Tips',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: CareerTipCard(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}
