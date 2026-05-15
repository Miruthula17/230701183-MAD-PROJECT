import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/job.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;
  final VoidCallback onFollowUp;
  final VoidCallback onDelete;

  const JobCard({
    super.key,
    required this.job,
    required this.onTap,
    required this.onFollowUp,
    required this.onDelete,
  });

  Color get _statusAccent {
    switch (job.status) {
      case 'wishlist':
        return const Color(0xFFFDCB6E);
      case 'applied':
        return const Color(0xFF74B9FF);
      case 'interview':
        return const Color(0xFFA29BFE);
      case 'offer':
        return const Color(0xFF00B894);
      case 'rejected':
        return const Color(0xFFE17055);
      default:
        return const Color(0xFF636E72);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(job.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onDelete();
        return false; // Let the dialog handle deletion
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFE17055).withValues(alpha: 0.0),
              const Color(0xFFE17055).withValues(alpha: 0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_rounded, color: Color(0xFFE17055), size: 28),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF2A2A4A),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Company initial avatar
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _statusAccent,
                              _statusAccent.withValues(alpha: 0.6),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            job.company.isNotEmpty
                                ? job.company[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              job.role,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // URL quick link
                      if (job.url.isNotEmpty)
                        Container(
                          width: 30,
                          height: 30,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF74B9FF).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.open_in_new_rounded, size: 14, color: Color(0xFF74B9FF)),
                            padding: EdgeInsets.zero,
                            tooltip: 'Open job posting',
                            onPressed: () async {
                              final url = Uri.tryParse(job.url);
                              if (url != null) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              }
                            },
                          ),
                        ),
                      _buildMenuButton(context),
                    ],
                  ),
                  if (job.location.isNotEmpty || job.salary.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (job.location.isNotEmpty) ...[
                          Icon(Icons.location_on_outlined,
                              size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              job.location,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        if (job.location.isNotEmpty && job.salary.isNotEmpty)
                          const SizedBox(width: 12),
                        if (job.salary.isNotEmpty) ...[
                          Icon(Icons.attach_money_rounded,
                              size: 14, color: Colors.grey[500]),
                          Flexible(
                            child: Text(
                              job.salary,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                  // Interview countdown & deadline badges
                  if (job.daysUntilInterview != null || job.daysUntilDeadline != null) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (job.daysUntilInterview != null)
                          _buildCountdownBadge(
                            days: job.daysUntilInterview!,
                            label: 'Interview',
                            icon: Icons.event_rounded,
                            date: job.interviewDate,
                          ),
                        if (job.daysUntilDeadline != null)
                          _buildCountdownBadge(
                            days: job.daysUntilDeadline!,
                            label: 'Deadline',
                            icon: Icons.timer_rounded,
                            date: job.deadline,
                          ),
                      ],
                    ),
                  ],
                  if (job.tags.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: job.tags.map((t) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _statusAccent.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            t,
                            style: TextStyle(
                              fontSize: 11,
                              color: _statusAccent,
                              fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildCountdownBadge({
    required int days,
    required String label,
    required IconData icon,
    required String date,
  }) {
    Color badgeColor;
    String text;

    if (days < 0) {
      badgeColor = Colors.grey;
      text = 'Passed';
    } else if (days == 0) {
      badgeColor = const Color(0xFFE17055);
      text = 'Today!';
    } else if (days == 1) {
      badgeColor = const Color(0xFFE17055);
      text = 'Tomorrow';
    } else if (days <= 3) {
      badgeColor = const Color(0xFFFDCB6E);
      text = '${days}d left';
    } else {
      badgeColor = const Color(0xFF00B894);
      text = '${days}d left';
    }

    String formattedDate = '';
    try {
      formattedDate = DateFormat('MMM dd').format(DateTime.parse(date));
    } catch (_) {}

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            '$label: $text',
            style: TextStyle(
              fontSize: 11,
              color: badgeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (formattedDate.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              '($formattedDate)',
              style: TextStyle(
                fontSize: 10,
                color: badgeColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.more_horiz_rounded, size: 16, color: Colors.grey),
        padding: EdgeInsets.zero,
        color: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: (value) {
          switch (value) {
            case 'edit':
              onTap();
              break;
            case 'followup':
              onFollowUp();
              break;
            case 'delete':
              onDelete();
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                const Icon(Icons.edit_rounded, size: 18, color: Color(0xFFA29BFE)),
                const SizedBox(width: 10),
                const Text('Edit'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'followup',
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, size: 18, color: Color(0xFFFDCB6E)),
                const SizedBox(width: 10),
                const Text('Generate follow-up'),
              ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                const Icon(Icons.delete_rounded, size: 18, color: Color(0xFFE17055)),
                const SizedBox(width: 10),
                const Text('Delete', style: TextStyle(color: Color(0xFFE17055))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
