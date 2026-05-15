import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/jobs_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/search_provider.dart';
import '../models/job.dart';
import '../widgets/ai_insight_card.dart';
import '../services/gemini_service.dart';

import 'add_job_screen.dart';
import 'job_detail_screen.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _careerTip = '';
  bool _loadingTip = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadData();
    });
  }

  Future<void> _loadData() async {
    // Load recommended jobs
    final searchProvider = context.read<SearchProvider>();
    final profileProvider = context.read<ProfileProvider>();
    await searchProvider.loadRecommendedJobs(
      category: profileProvider.profile.preferredCategory,
    );

    // Load career tip
    _loadCareerTip();
  }

  Future<void> _loadCareerTip() async {
    try {
      final profile = context.read<ProfileProvider>().profile;
      final jobs = context.read<JobsProvider>();
      final insights = await GeminiService().getCareerInsights(
        profile: profile,
        totalApplications: jobs.totalJobs,
        interviews: jobs.countByStatus('interview'),
        offers: jobs.countByStatus('offer'),
        rejections: jobs.countByStatus('rejected'),
      );
      if (mounted) {
        setState(() {
          _careerTip = insights['tip_of_the_day'] ?? 'Keep applying consistently!';
          _loadingTip = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _careerTip = 'Stay consistent with your applications and follow up after interviews!';
          _loadingTip = false;
        });
      }
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final jobs = context.watch<JobsProvider>();
    final search = context.watch<SearchProvider>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF0A66C2),
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting header
                _buildGreeting(profile.name),
                const SizedBox(height: 20),

                // Quick stats
                _buildQuickStats(jobs),
                const SizedBox(height: 20),

                // Quick search
                _buildQuickSearch(context),
                const SizedBox(height: 24),

                // Recommended jobs
                _buildSectionTitle('Recommended for You', Icons.recommend_rounded),
                const SizedBox(height: 12),
                _buildRecommendedJobs(search, jobs),
                const SizedBox(height: 24),

                // AI Career Tip
                AiInsightCard(
                  title: 'AI Career Tip',
                  content: _careerTip,
                  isLoading: _loadingTip,
                  icon: Icons.lightbulb_rounded,
                  gradientColors: const [Color(0xFFE8A723), Color(0xFFCC1016)],
                  onRefresh: () {
                    setState(() => _loadingTip = true);
                    _loadCareerTip();
                  },
                ),
                const SizedBox(height: 24),

                // Recent applications
                if (jobs.recentJobs.isNotEmpty) ...[
                  _buildSectionTitle('Recent Applications', Icons.history_rounded),
                  const SizedBox(height: 12),
                  _buildRecentApplications(jobs, context),
                ],
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(String name) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_greeting${name.isNotEmpty ? ', $name' : ''} 👋',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF191919),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Find your dream job with AI',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0A66C2), Color(0xFF70B5F9)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
        ),
      ],
    );
  }

  Widget _buildQuickStats(JobsProvider jobs) {
    return Row(
      children: [
        _buildStatCard(
          '${jobs.totalJobs}',
          'Applied',
          Icons.send_rounded,
          const [Color(0xFF0A66C2), Color(0xFF70B5F9)],
        ),
        const SizedBox(width: 10),
        _buildStatCard(
          '${jobs.countByStatus('interview')}',
          'Interviews',
          Icons.forum_rounded,
          const [Color(0xFF70B5F9), Color(0xFF70B5F9)],
        ),
        const SizedBox(width: 10),
        _buildStatCard(
          '${jobs.countByStatus('offer')}',
          'Offers',
          Icons.emoji_events_rounded,
          const [Color(0xFF057642), Color(0xFF057642)],
        ),
        const SizedBox(width: 10),
        _buildStatCard(
          '${jobs.savedJobs.length}',
          'Saved',
          Icons.bookmark_rounded,
          const [Color(0xFFE8A723), Color(0xFFCC1016)],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String value, String label, IconData icon, List<Color> gradient) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              gradient[0].withValues(alpha: 0.15),
              gradient[1].withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: gradient[0].withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: gradient[0]),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF191919),
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSearch(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to search tab
        final mainState = context.findAncestorStateOfType<MainShellState>();
        if (mainState != null && mainState.mounted) {
          mainState.switchToTab(1);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEBEBEB)),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: Color(0xFF70B5F9)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Search jobs, companies, skills...',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0A66C2), Color(0xFF70B5F9)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'AI',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF191919),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF70B5F9)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF191919),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedJobs(SearchProvider search, JobsProvider jobs) {
    if (search.isLoadingRecommended) {
      return SizedBox(
        height: 180,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          itemBuilder: (_, i) => _buildJobCardSkeleton(),
        ),
      );
    }

    if (search.recommendedJobs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEBEBEB)),
        ),
        child: Column(
          children: [
            Icon(Icons.work_outline_rounded, size: 36, color: Colors.grey[700]),
            const SizedBox(height: 8),
            Text(
              'Loading recommendations...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: search.recommendedJobs.length,
        itemBuilder: (context, index) {
          final job = search.recommendedJobs[index];
          return _buildRecommendedCard(job, jobs, context);
        },
      ),
    );
  }

  Widget _buildRecommendedCard(Job job, JobsProvider jobs, BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
      ),
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEBEBEB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Company avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0A66C2), Color(0xFF70B5F9)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: job.companyLogoUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: Image.network(
                            job.companyLogoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Center(
                              child: Text(
                                job.company.isNotEmpty
                                    ? job.company[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF191919),
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            job.company.isNotEmpty
                                ? job.company[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF191919),
                              fontSize: 18,
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.company,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF70B5F9),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (job.timeAgo.isNotEmpty)
                        Text(
                          job.timeAgo,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => jobs.toggleSaveJob(job),
                  child: Icon(
                    jobs.isJobSaved(job.id)
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    size: 22,
                    color: jobs.isJobSaved(job.id)
                        ? const Color(0xFFE8A723)
                        : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              job.role,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF191919),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    job.location.isNotEmpty ? job.location : 'Remote',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (job.jobType.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF057642).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  job.formattedJobType,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF057642),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCardSkeleton() {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEBEBEB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEBEBEB),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBEBEB),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 60,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBEBEB),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 14,
            decoration: BoxDecoration(
              color: const Color(0xFFEBEBEB),
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 160,
            height: 14,
            decoration: BoxDecoration(
              color: const Color(0xFFEBEBEB),
              borderRadius: BorderRadius.circular(7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentApplications(JobsProvider jobs, BuildContext context) {
    return Column(
      children: jobs.recentJobs.take(3).map((job) {
        final statusColor = _statusColor(job.status);
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddJobScreen(prefilled: job),
                ),
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFEBEBEB)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          job.company.isNotEmpty
                              ? job.company[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.company,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF191919),
                            ),
                          ),
                          Text(
                            job.role,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        job.status,
                        style: TextStyle(
                          fontSize: 11,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'wishlist':
        return const Color(0xFFE8A723);
      case 'applied':
        return const Color(0xFF70B5F9);
      case 'interview':
        return const Color(0xFF70B5F9);
      case 'offer':
        return const Color(0xFF057642);
      case 'rejected':
        return const Color(0xFFCC1016);
      default:
        return const Color(0xFF8C8C8C);
    }
  }
}
