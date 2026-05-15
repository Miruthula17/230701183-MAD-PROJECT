import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/jobs_provider.dart';
import 'add_job_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JobsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0A66C2), Color(0xFF70B5F9)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.dashboard_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dashboard'),
                Text(
                  'Your job search at a glance',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatsRow(provider),
            const SizedBox(height: 20),
            _buildStatusChart(provider),
            const SizedBox(height: 20),
            _buildWeeklyActivity(provider),
            const SizedBox(height: 20),
            _buildUpcomingInterviews(provider, context),
            const SizedBox(height: 20),
            _buildRecentActivity(provider, context),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(JobsProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Total',
            value: '${provider.totalJobs}',
            icon: Icons.work_rounded,
            gradient: const [Color(0xFF0A66C2), Color(0xFF70B5F9)],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Interviews',
            value: '${provider.countByStatus('interview')}',
            icon: Icons.forum_rounded,
            gradient: const [Color(0xFF70B5F9), Color(0xFF70B5F9)],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Response',
            value: '${provider.responseRate.toStringAsFixed(0)}%',
            icon: Icons.trending_up_rounded,
            gradient: const [Color(0xFF057642), Color(0xFF057642)],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChart(JobsProvider provider) {
    if (provider.totalJobs == 0) {
      return _buildEmptyCard(
        'No jobs yet',
        'Add your first job to see status breakdown',
        Icons.pie_chart_rounded,
      );
    }

    final statusData = [
      _ChartData('Wishlist', provider.countByStatus('wishlist'), const Color(0xFFE8A723)),
      _ChartData('Applied', provider.countByStatus('applied'), const Color(0xFF70B5F9)),
      _ChartData('Interview', provider.countByStatus('interview'), const Color(0xFF70B5F9)),
      _ChartData('Offer', provider.countByStatus('offer'), const Color(0xFF057642)),
      _ChartData('Rejected', provider.countByStatus('rejected'), const Color(0xFFCC1016)),
    ].where((d) => d.count > 0).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEBEBEB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pie_chart_rounded, size: 20, color: Color(0xFF70B5F9)),
              const SizedBox(width: 8),
              const Text(
                'Status Breakdown',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF191919),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sections: statusData.map((d) {
                        return PieChartSectionData(
                          value: d.count.toDouble(),
                          color: d.color,
                          title: '${d.count}',
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF191919),
                          ),
                          radius: 50,
                          titlePositionPercentageOffset: 0.55,
                        );
                      }).toList(),
                      sectionsSpace: 3,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: statusData.map((d) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: d.color,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                d.label,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            Text(
                              '${d.count}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF191919),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyActivity(JobsProvider provider) {
    final weeklyData = provider.weeklyActivity;
    final maxVal = weeklyData.values.fold<int>(0, (a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEBEBEB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded, size: 20, color: Color(0xFF70B5F9)),
              const SizedBox(width: 8),
              const Text(
                'Weekly Activity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF191919),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (maxVal + 2).toDouble(),
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final keys = weeklyData.keys.toList();
                        if (value.toInt() < keys.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              keys[value.toInt()],
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: weeklyData.entries.toList().asMap().entries.map((entry) {
                  final idx = entry.key;
                  final val = entry.value.value.toDouble();
                  return BarChartGroupData(
                    x: idx,
                    barRods: [
                      BarChartRodData(
                        toY: val,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF0A66C2).withValues(alpha: 0.8),
                            const Color(0xFF70B5F9),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingInterviews(JobsProvider provider, BuildContext context) {
    final upcoming = provider.upcomingInterviews;
    if (upcoming.isEmpty) {
      return _buildEmptyCard(
        'No upcoming interviews',
        'Interview dates will appear here',
        Icons.event_rounded,
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEBEBEB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_rounded, size: 20, color: Color(0xFFE8A723)),
              const SizedBox(width: 8),
              const Text(
                'Upcoming Interviews',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF191919),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...upcoming.map((job) {
            final days = job.daysUntilInterview!;
            final urgencyColor = days <= 1
                ? const Color(0xFFCC1016)
                : days <= 3
                    ? const Color(0xFFE8A723)
                    : const Color(0xFF057642);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: urgencyColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: urgencyColor.withValues(alpha: 0.3)),
              ),
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddJobScreen(prefilled: job),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: urgencyColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        days == 0
                            ? 'TODAY'
                            : days == 1
                                ? '1d'
                                : '${days}d',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: urgencyColor,
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
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF191919),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            job.role,
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      DateFormat('MMM dd').format(DateTime.parse(job.interviewDate)),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(JobsProvider provider, BuildContext context) {
    final recent = provider.recentJobs;
    if (recent.isEmpty) {
      return _buildEmptyCard(
        'No recent activity',
        'Your latest jobs will appear here',
        Icons.history_rounded,
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEBEBEB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_rounded, size: 20, color: Color(0xFF057642)),
              const SizedBox(width: 8),
              const Text(
                'Recent Jobs',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF191919),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recent.map((job) {
            final statusColor = _statusColor(job.status);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddJobScreen(prefilled: job),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            job.company.isNotEmpty ? job.company[0].toUpperCase() : '?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: statusColor,
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
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              job.role,
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEBEBEB)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.grey[700]),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
        ],
      ),
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradient;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradient[0].withValues(alpha: 0.2),
            gradient[1].withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gradient[0].withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: gradient[0]),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF191919),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartData {
  final String label;
  final int count;
  final Color color;
  _ChartData(this.label, this.count, this.color);
}
