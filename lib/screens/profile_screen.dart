import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../providers/jobs_provider.dart';
import '../widgets/profile_strength_widget.dart';
import '../widgets/ai_insight_card.dart';
import '../services/gemini_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _generatingResume = false;

  @override
  Widget build(BuildContext context) {
    final pp = context.watch<ProfileProvider>();
    final profile = pp.profile;
    final jobs = context.watch<JobsProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(profile.name, profile.headline),
              const SizedBox(height: 20),
              ProfileStrengthWidget(
                percentage: profile.completeness,
                label: profile.strengthLabel,
                tip: profile.nextTip,
              ),
              const SizedBox(height: 24),
              _buildEditableField('Name', profile.name, Icons.person_rounded, (v) => pp.updateName(v)),
              _buildEditableField('Headline', profile.headline, Icons.badge_rounded, (v) => pp.updateHeadline(v)),
              _buildEditableField('Email', profile.email, Icons.email_rounded, (v) => pp.updateEmail(v)),
              _buildEditableField('Experience (years)', profile.experience, Icons.work_history_rounded, (v) => pp.updateExperience(v)),
              _buildEditableField('Education', profile.education, Icons.school_rounded, (v) => pp.updateEducation(v)),
              _buildEditableField('Preferred Role', profile.preferredRole, Icons.search_rounded, (v) => pp.updatePreferredRole(v)),
              _buildEditableField('Preferred Location', profile.preferredLocation, Icons.location_on_rounded, (v) => pp.updatePreferredLocation(v)),
              const SizedBox(height: 20),
              _buildSkillsSection(pp, profile.skills),
              const SizedBox(height: 24),
              _buildResumeSection(pp, profile.resumeSummary),
              const SizedBox(height: 24),
              // Stats
              _buildStatsRow(jobs),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name, String headline) {
    return Row(
      children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF0A66C2), Color(0xFF70B5F9)]),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(color: const Color(0xFF191919), fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.isNotEmpty ? name : 'Set up your profile',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF191919)),
              ),
              if (headline.isNotEmpty)
                Text(headline, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField(String label, String value, IconData icon, Function(String) onSave) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showEditDialog(label, value, onSave),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEBEBEB)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF70B5F9)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(
                        value.isNotEmpty ? value : 'Tap to add',
                        style: TextStyle(fontSize: 15, color: value.isNotEmpty ? Colors.white : Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.edit_rounded, size: 18, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkillsSection(ProfileProvider pp, List<String> skills) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBEBEB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 20, color: Color(0xFFE8A723)),
              const SizedBox(width: 8),
              const Text('Skills', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF191919))),
              const Spacer(),
              GestureDetector(
                onTap: () => _showAddSkillDialog(pp),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A66C2).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add_rounded, size: 18, color: Color(0xFF70B5F9)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (skills.isEmpty)
            Text('Add your skills to get better job matches', style: TextStyle(fontSize: 13, color: Colors.grey[600]))
          else
            Wrap(
              spacing: 8, runSpacing: 8,
              children: skills.map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF70B5F9).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF70B5F9).withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(s, style: const TextStyle(fontSize: 13, color: Color(0xFF70B5F9), fontWeight: FontWeight.w500)),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => pp.removeSkill(s),
                      child: const Icon(Icons.close_rounded, size: 14, color: Color(0xFF70B5F9)),
                    ),
                  ],
                ),
              )).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildResumeSection(ProfileProvider pp, String resume) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.description_rounded, size: 20, color: Color(0xFF057642)),
            const SizedBox(width: 8),
            const Text('AI Resume Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF191919))),
          ],
        ),
        const SizedBox(height: 12),
        if (resume.isNotEmpty)
          AiInsightCard(
            title: 'Your Resume Summary',
            content: resume,
            icon: Icons.description_rounded,
            gradientColors: const [Color(0xFF057642), Color(0xFF057642)],
          ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF0A66C2).withValues(alpha: resume.isEmpty ? 1 : 0.3),
                const Color(0xFFE84393).withValues(alpha: resume.isEmpty ? 1 : 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: ElevatedButton.icon(
            onPressed: _generatingResume ? null : () => _generateResume(pp),
            icon: _generatingResume
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: const Color(0xFF191919)))
                : const Icon(Icons.auto_awesome),
            label: Text(
              _generatingResume ? 'Generating...' : (resume.isEmpty ? 'Generate AI Resume' : 'Regenerate'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(JobsProvider jobs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBEBEB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your Journey', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF191919))),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _stat('${jobs.totalJobs}', 'Applied', const Color(0xFF70B5F9)),
              _stat('${jobs.countByStatus('interview')}', 'Interviews', const Color(0xFF70B5F9)),
              _stat('${jobs.countByStatus('offer')}', 'Offers', const Color(0xFF057642)),
              _stat('${jobs.responseRate.toStringAsFixed(0)}%', 'Response', const Color(0xFFE8A723)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  Future<void> _showEditDialog(String label, String current, Function(String) onSave) async {
    final controller = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Edit $label'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: 'Enter $label'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: Colors.grey[600]))),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('Save')),
        ],
      ),
    );
    if (result != null) onSave(result);
  }

  Future<void> _showAddSkillDialog(ProfileProvider pp) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add Skill'),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(hintText: 'e.g. Flutter, Python, React')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: Colors.grey[600]))),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('Add')),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      // Support comma-separated skills
      for (final s in result.split(',')) {
        if (s.trim().isNotEmpty) pp.addSkill(s.trim());
      }
    }
  }

  Future<void> _generateResume(ProfileProvider pp) async {
    setState(() => _generatingResume = true);
    try {
      final resume = await GeminiService().generateResume(profile: pp.profile);
      pp.updateResumeSummary(resume);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate resume. Try again.')),
        );
      }
    }
    if (mounted) setState(() => _generatingResume = false);
  }
}
