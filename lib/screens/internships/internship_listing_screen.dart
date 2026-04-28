import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_theme.dart';
import '../../models/internship_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/internship_provider.dart';
import '../../services/job_service.dart';
import 'internship_detail_screen.dart';

class InternshipListingScreen extends StatefulWidget {
  const InternshipListingScreen({super.key});

  @override
  State<InternshipListingScreen> createState() =>
      _InternshipListingScreenState();
}

class _InternshipListingScreenState extends State<InternshipListingScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userSkills =
        context.watch<AuthProvider>().user?.technicalSkills ?? [];

    return Consumer<InternshipProvider>(
      builder: (context, provider, _) {
        final internships = provider.selectedFilters.sort == 'Best Match'
            ? provider.getSortedByMatch(userSkills)
            : provider.internships;
        final recommended = provider.getRecommended(userSkills);

        return Scaffold(
          backgroundColor: AppTheme.bgLight,
          body: RefreshIndicator(
            color: AppTheme.primaryBlue,
            onRefresh: () async {
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
              await provider.fetchInternships(forceRefresh: true, aiMockInternships: aiInternships);
            },
            child: CustomScrollView(
              slivers: [
                // ─── Header ───
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
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Internships',
                              style: GoogleFonts.inter(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Find your perfect internship opportunity',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Search bar
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: provider.searchInternships,
                                decoration: InputDecoration(
                                  hintText: 'Search jobs, skills, companies...',
                                  hintStyle: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: AppTheme.textLight,
                                  ),
                                  prefixIcon: const Icon(Icons.search,
                                      color: AppTheme.textLight),
                                  suffixIcon: provider.searchQuery.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear,
                                              color: AppTheme.textLight,
                                              size: 20),
                                          onPressed: () {
                                            _searchController.clear();
                                            provider.searchInternships('');
                                          },
                                        )
                                      : null,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ─── Info banner (cache/mock indicator) ───
                if (provider.infoMessage != null &&
                    provider.dataSource != DataSource.api)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: provider.dataSource == DataSource.mock
                            ? AppTheme.warning.withValues(alpha: 0.1)
                            : AppTheme.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: provider.dataSource == DataSource.mock
                              ? AppTheme.warning.withValues(alpha: 0.3)
                              : AppTheme.info.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            provider.dataSource == DataSource.mock
                                ? Icons.info_outline
                                : Icons.cached_rounded,
                            size: 18,
                            color: provider.dataSource == DataSource.mock
                                ? AppTheme.warning
                                : AppTheme.info,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              provider.infoMessage!,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: provider.dataSource == DataSource.mock
                                    ? AppTheme.warning
                                    : AppTheme.info,
                              ),
                            ),
                          ),
                          if (provider.dataSource != DataSource.api)
                            GestureDetector(
                              onTap: () {
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
                                provider.fetchInternships(forceRefresh: true, aiMockInternships: aiInternships);
                              },
                              child: Text(
                                'Refresh',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                // ─── Filters ───
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                    child: _FilterBar(
                      filters: provider.selectedFilters,
                      onChanged: provider.updateFilters,
                    ),
                  ),
                ),

                // ─── Loading state ───
                if (provider.isLoading)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: List.generate(
                            3, (_) => const _ShimmerCard()),
                      ),
                    ),
                  ),

                // ─── Content ───
                if (!provider.isLoading) ...[
                  // Recommended section
                  if (recommended.isNotEmpty &&
                      provider.searchQuery.isEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.auto_awesome,
                                  size: 16, color: AppTheme.primaryBlue),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Recommended For You',
                              style: GoogleFonts.inter(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 210,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: recommended.length,
                          itemBuilder: (ctx, i) => Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: _RecommendedCard(
                              internship: recommended[i],
                              userSkills: userSkills,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],

                  // All Internships header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            provider.searchQuery.isNotEmpty
                                ? 'Search Results'
                                : 'All Internships',
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            '${internships.length} found',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Internship list
                  if (internships.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => InternshipCard(
                            internship: internships[index],
                            userSkills: userSkills,
                          ),
                          childCount: internships.length,
                        ),
                      ),
                    ),

                  // Empty state
                  if (internships.isEmpty && !provider.isLoading)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppTheme.textLight
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(Icons.search_off_rounded,
                                  size: 40,
                                  color: AppTheme.textLight
                                      .withValues(alpha: 0.5)),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No internships found',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Try adjusting your search or filters',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppTheme.textLight,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton.icon(
                              onPressed: () {
                                provider.clearFilters();
                                _searchController.clear();
                              },
                              icon: const Icon(Icons.refresh, size: 18),
                              label: Text('Clear Filters',
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],

                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Filter Bar Widget ───
class _FilterBar extends StatelessWidget {
  final FilterModel filters;
  final ValueChanged<FilterModel> onChanged;

  const _FilterBar({required this.filters, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChipWidget(
                  label: 'Remote',
                  isActive: filters.location == 'Remote',
                  onTap: () => onChanged(filters.copyWith(
                    location:
                        filters.location == 'Remote' ? 'Both' : 'Remote',
                  )),
                ),
                const SizedBox(width: 8),
                _FilterChipWidget(
                  label: 'Sri Lanka',
                  isActive: filters.location == 'Sri Lanka',
                  onTap: () => onChanged(filters.copyWith(
                    location: filters.location == 'Sri Lanka'
                        ? 'Both'
                        : 'Sri Lanka',
                  )),
                ),
                const SizedBox(width: 8),
                _FilterChipWidget(
                  label: 'Paid',
                  isActive: filters.type == 'Paid',
                  onTap: () => onChanged(filters.copyWith(
                    type: filters.type == 'Paid' ? 'Any' : 'Paid',
                  )),
                ),
                const SizedBox(width: 8),
                _FilterChipWidget(
                  label: 'Entry-Level',
                  isActive: filters.level == 'Entry-Level',
                  onTap: () => onChanged(filters.copyWith(
                    level:
                        filters.level == 'Entry-Level' ? 'Any' : 'Entry-Level',
                  )),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        _SortDropdown(
          value: filters.sort,
          onChanged: (v) => onChanged(filters.copyWith(sort: v)),
        ),
      ],
    );
  }
}

class _FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChipWidget({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? AppTheme.primaryBlue : const Color(0xFFE5E7EB),
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _SortDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _SortDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down,
              size: 18, color: AppTheme.textSecondary),
          isDense: true,
          items: ['Most Recent', 'Top Rated', 'Best Match']
              .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s,
                        style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w500)),
                  ))
              .toList(),
          onChanged: (v) => onChanged(v!),
        ),
      ),
    );
  }
}

// ─── Shimmer Loading Card ───
class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFE5E7EB),
        highlightColor: const Color(0xFFF3F4F6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    )),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: 120, height: 14,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          )),
                      const SizedBox(height: 8),
                      Container(
                          width: 80, height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          )),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
                width: double.infinity, height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                )),
            const SizedBox(height: 12),
            Row(
              children: List.generate(
                  3,
                  (_) => Container(
                      width: 60,
                      height: 24,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ))),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Recommended Card (horizontal scroll) ───
class _RecommendedCard extends StatelessWidget {
  final InternshipModel internship;
  final List<String> userSkills;

  const _RecommendedCard({
    required this.internship,
    required this.userSkills,
  });

  @override
  Widget build(BuildContext context) {
    final matchPct = internship.getMatchPercentage(userSkills).round();
    final color = _getCardColor();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InternshipDetailScreen(internship: internship),
        ),
      ),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withValues(alpha: 0.75)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Company logo
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: internship.getLogoUrl() != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: internship.getLogoUrl()!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                            errorWidget: (c, u, e) => Center(
                              child: Text(
                                internship.companyName[0],
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            internship.companyName[0],
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
                if (matchPct > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$matchPct% Match',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  internship.jobTitle,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  internship.companyName,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 12,
                        color: Colors.white.withValues(alpha: 0.7)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        internship.isRemote
                            ? 'Remote'
                            : internship.location,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCardColor() {
    final hash = internship.companyName.hashCode;
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF8B5CF6),
      const Color(0xFF0EA5E9),
      const Color(0xFF14B8A6),
      const Color(0xFFEC4899),
      const Color(0xFFF59E0B),
    ];
    return colors[hash.abs() % colors.length];
  }
}

// ─── Internship Card Widget ───
class InternshipCard extends StatelessWidget {
  final InternshipModel internship;
  final List<String> userSkills;

  const InternshipCard({
    super.key,
    required this.internship,
    required this.userSkills,
  });

  Color _getCompanyColor() {
    final hash = internship.companyName.hashCode;
    final colors = [
      const Color(0xFF4285F4),
      const Color(0xFF00A4EF),
      const Color(0xFF1877F2),
      const Color(0xFFFF9900),
      const Color(0xFF6772E5),
      const Color(0xFF1DB954),
      const Color(0xFFE50914),
      const Color(0xFF14B8A6),
    ];
    return colors[hash.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final matchPct = internship.getMatchPercentage(userSkills).round();
    final companyColor = _getCompanyColor();
    final userSkillsLower = userSkills.map((s) => s.toLowerCase()).toSet();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InternshipDetailScreen(internship: internship),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company header
                  Row(
                    children: [
                      // Company logo
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: companyColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: internship.getLogoUrl() != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: CachedNetworkImage(
                                  imageUrl: internship.getLogoUrl()!,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.contain,
                                  placeholder: (c, u) => Center(
                                    child: Text(
                                      internship.companyName[0],
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: companyColor,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (c, u, e) => Center(
                                    child: Text(
                                      internship.companyName[0],
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: companyColor,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  internship.companyName[0],
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: companyColor,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              internship.companyName,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.access_time_rounded,
                                    size: 12, color: AppTheme.textLight),
                                const SizedBox(width: 4),
                                Text(
                                  internship.getTimeAgo(),
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    internship.source,
                                    style: GoogleFonts.inter(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Match badge
                      if (matchPct > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: matchPct >= 80
                                ? AppTheme.success.withValues(alpha: 0.1)
                                : matchPct >= 50
                                    ? AppTheme.warning.withValues(alpha: 0.1)
                                    : AppTheme.primaryBlue
                                        .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$matchPct%',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: matchPct >= 80
                                  ? AppTheme.success
                                  : matchPct >= 50
                                      ? AppTheme.warning
                                      : AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Job title
                  Text(
                    internship.jobTitle,
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),

                  // Tags row
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (internship.isRemote)
                        _buildTag('Remote', const Color(0xFF8B5CF6)),
                      if (internship.isPaid)
                        _buildTag('Paid', AppTheme.success),
                      _buildTag(internship.location.split(',').first,
                          AppTheme.primaryBlue),
                      if (internship.salary != null)
                        _buildTag(internship.salary!, AppTheme.warning),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Skills (max 3 + overflow)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ...internship.requiredSkills.take(3).map((skill) {
                        final isMatch = userSkillsLower
                            .contains(skill.toLowerCase());
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isMatch
                                ? AppTheme.success.withValues(alpha: 0.1)
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(6),
                            border: isMatch
                                ? Border.all(
                                    color: AppTheme.success
                                        .withValues(alpha: 0.3))
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isMatch)
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: Icon(Icons.check_circle,
                                      size: 12, color: AppTheme.success),
                                ),
                              Text(
                                skill,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isMatch
                                      ? AppTheme.success
                                      : AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      if (internship.requiredSkills.length > 3)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '+${internship.requiredSkills.length - 3} more',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Bottom action bar
            Container(
              decoration: const BoxDecoration(
                border:
                    Border(top: BorderSide(color: Color(0xFFF3F4F6))),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 14, color: AppTheme.textLight),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      internship.location,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InternshipDetailScreen(
                              internship: internship),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Apply Now',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
