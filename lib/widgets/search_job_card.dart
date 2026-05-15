import 'package:flutter/material.dart';
import '../models/job.dart';

class SearchJobCard extends StatelessWidget {
  final Job job;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onSave;
  final VoidCallback onApply;

  const SearchJobCard({
    super.key,
    required this.job,
    required this.isSaved,
    required this.onTap,
    required this.onSave,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEBEBEB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company logo/initial
                    _buildCompanyAvatar(),
                    const SizedBox(width: 12),
                    // Job info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.role,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: const Color(0xFF191919),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            job.company,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF70B5F9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Save button
                    _buildSaveButton(),
                  ],
                ),
                const SizedBox(height: 12),
                // Location & salary row
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    if (job.location.isNotEmpty)
                      _buildInfoChip(
                        Icons.location_on_outlined,
                        job.location.length > 30
                            ? '${job.location.substring(0, 30)}...'
                            : job.location,
                      ),
                    if (job.salary.isNotEmpty)
                      _buildInfoChip(
                        Icons.attach_money_rounded,
                        job.salary,
                      ),
                    if (job.timeAgo.isNotEmpty)
                      _buildInfoChip(
                        Icons.access_time_rounded,
                        job.timeAgo,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Tags
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (job.jobType.isNotEmpty)
                      _buildTag(
                        job.formattedJobType,
                        const Color(0xFF057642),
                      ),
                    if (job.category.isNotEmpty)
                      _buildTag(
                        job.category,
                        const Color(0xFF70B5F9),
                      ),
                    if (job.matchScore > 0)
                      _buildMatchBadge(),
                  ],
                ),
                const SizedBox(height: 14),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0A66C2), Color(0xFF70B5F9)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: onApply,
                          icon: const Icon(Icons.send_rounded, size: 18),
                          label: const Text(
                            'Track Application',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyAvatar() {
    final hasLogo = job.companyLogoUrl.isNotEmpty;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: hasLogo
            ? null
            : const LinearGradient(
                colors: [Color(0xFF0A66C2), Color(0xFF70B5F9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: hasLogo ? const Color(0xFFFFFFFF) : null,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFEBEBEB),
        ),
      ),
      child: hasLogo
          ? ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Image.network(
                job.companyLogoUrl,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => _buildInitial(),
              ),
            )
          : _buildInitial(),
    );
  }

  Widget _buildInitial() {
    return Center(
      child: Text(
        job.company.isNotEmpty ? job.company[0].toUpperCase() : '?',
        style: const TextStyle(
          color: const Color(0xFF191919),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: onSave,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isSaved
              ? const Color(0xFFE8A723).withValues(alpha: 0.2)
              : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSaved
                ? const Color(0xFFE8A723).withValues(alpha: 0.5)
                : const Color(0xFFEBEBEB),
          ),
        ),
        child: Icon(
          isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          color: isSaved ? const Color(0xFFE8A723) : Colors.grey,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMatchBadge() {
    final color = job.matchScore >= 80
        ? const Color(0xFF057642)
        : job.matchScore >= 50
            ? const Color(0xFFE8A723)
            : const Color(0xFFCC1016);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '${job.matchScore}% Match',
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
