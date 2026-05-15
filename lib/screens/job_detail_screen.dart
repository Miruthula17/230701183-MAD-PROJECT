import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job.dart';
import '../providers/jobs_provider.dart';
import 'interview_prep_screen.dart';

class JobDetailScreen extends StatelessWidget {
  final Job job;
  const JobDetailScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final jobsProvider = context.watch<JobsProvider>();
    final isSaved = jobsProvider.isJobSaved(job.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, isSaved, jobsProvider),
          SliverToBoxAdapter(child: _buildBody(context, jobsProvider)),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext ctx, bool isSaved, JobsProvider jp) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: const Color(0xFFF3F2EF),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: const Color(0xFF191919), size: 20),
          onPressed: () => Navigator.pop(ctx),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: isSaved ? const Color(0xFFE8A723) : const Color(0xFF191919),
            ),
            onPressed: () => jp.toggleSaveJob(job),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0A66C2), Color(0xFFF3F2EF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                _buildLogo(),
                const SizedBox(height: 12),
                Text(job.company, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF191919))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 64, height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF70B5F9).withValues(alpha: 0.5), width: 2),
      ),
      child: job.companyLogoUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(job.companyLogoUrl, fit: BoxFit.cover,
                errorBuilder: (c, e, s) => _initial()),
            )
          : _initial(),
    );
  }

  Widget _initial() => Center(
    child: Text(
      job.company.isNotEmpty ? job.company[0].toUpperCase() : '?',
      style: const TextStyle(color: const Color(0xFF191919), fontWeight: FontWeight.bold, fontSize: 28),
    ),
  );

  Widget _buildBody(BuildContext context, JobsProvider jp) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(job.role, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF191919), letterSpacing: -0.5)),
          const SizedBox(height: 16),
          _buildInfoChips(),
          const SizedBox(height: 24),
          _buildActions(context, jp),
          const SizedBox(height: 24),
          const Text('About this role', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF191919))),
          const SizedBox(height: 12),
          _buildDescriptionBox(),
          const SizedBox(height: 24),
          if (job.tags.isNotEmpty) ...[
            const Text('Tags', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF191919))),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: job.tags.map((t) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF70B5F9).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF70B5F9).withValues(alpha: 0.3)),
                ),
                child: Text(t, style: const TextStyle(fontSize: 13, color: Color(0xFF70B5F9), fontWeight: FontWeight.w500)),
              )).toList(),
            ),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildInfoChips() {
    return Wrap(
      spacing: 10, runSpacing: 8,
      children: [
        if (job.location.isNotEmpty) _chip(Icons.location_on_outlined, job.location),
        if (job.salary.isNotEmpty) _chip(Icons.attach_money_rounded, job.salary),
        if (job.jobType.isNotEmpty) _chip(Icons.work_outline_rounded, job.formattedJobType),
        if (job.timeAgo.isNotEmpty) _chip(Icons.access_time_rounded, job.timeAgo),
        if (job.category.isNotEmpty) _chip(Icons.category_rounded, job.category),
      ],
    );
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEBEBEB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Flexible(child: Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[700]), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, JobsProvider jp) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0A66C2), Color(0xFF70B5F9)]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: const Color(0xFF0A66C2).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                jp.addFromSearch(job);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Row(children: [Icon(Icons.check_circle, color: Color(0xFF057642)), SizedBox(width: 8), Text('Added to applications!')])),
                );
              },
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('Track Application', style: TextStyle(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFEBEBEB))),
          child: IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InterviewPrepScreen(job: job))),
            icon: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (b) => const LinearGradient(colors: [Color(0xFF0A66C2), Color(0xFFE84393)]).createShader(b),
              child: const Icon(Icons.auto_awesome, size: 22),
            ),
            tooltip: 'AI Interview Prep',
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionBox() {
    final cleanText = job.description
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'<li>'), '• ')
        .replaceAll(RegExp(r'</li>'), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'&nbsp;'), ' ')
        .replaceAll(RegExp(r'&amp;'), '&')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
    final display = cleanText.length > 2000 ? '${cleanText.substring(0, 2000)}...' : cleanText;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBEBEB)),
      ),
      child: Text(
        display.isEmpty ? 'No description available.' : display,
        style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.6),
      ),
    );
  }
}
