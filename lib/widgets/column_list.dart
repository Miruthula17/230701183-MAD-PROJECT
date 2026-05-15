import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job.dart';
import '../providers/jobs_provider.dart';
import '../screens/add_job_screen.dart';
import '../screens/followup_screen.dart';
import 'job_card.dart';

class ColumnList extends StatelessWidget {
  final String columnId;
  final String label;
  final IconData icon;
  final List<Job> jobs;

  const ColumnList({
    super.key,
    required this.columnId,
    required this.label,
    required this.icon,
    required this.jobs,
  });

  Color get _columnAccent {
    switch (columnId) {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Column header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _columnAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _columnAccent.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: _columnAccent),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: _columnAccent,
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: _columnAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${jobs.length}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: _columnAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Job cards with drag target
          Expanded(
            child: DragTarget<Job>(
              onAcceptWithDetails: (details) {
                final provider = context.read<JobsProvider>();
                provider.moveJob(details.data.id, columnId);
              },
              onWillAcceptWithDetails: (details) =>
                  details.data.status != columnId,
              builder: (context, candidateData, rejectedData) {
                final isHovering = candidateData.isNotEmpty;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isHovering
                        ? _columnAccent.withValues(alpha: 0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: isHovering
                        ? Border.all(
                            color: _columnAccent.withValues(alpha: 0.4),
                            width: 2,
                          )
                        : null,
                  ),
                  child: jobs.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 4),
                          itemCount: jobs.length,
                          itemBuilder: (context, index) {
                            final job = jobs[index];
                            return LongPressDraggable<Job>(
                              data: job,
                              feedback: Material(
                                color: Colors.transparent,
                                child: SizedBox(
                                  width: 280,
                                  child: Opacity(
                                    opacity: 0.85,
                                    child: Transform.rotate(
                                      angle: 0.03,
                                      child: JobCard(
                                        job: job,
                                        onTap: () {},
                                        onFollowUp: () {},
                                        onDelete: () {},
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.3,
                                child: JobCard(
                                  job: job,
                                  onTap: () {},
                                  onFollowUp: () {},
                                  onDelete: () {},
                                ),
                              ),
                              child: JobCard(
                                job: job,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AddJobScreen(prefilled: job),
                                  ),
                                ),
                                onFollowUp: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        FollowUpScreen(job: job),
                                  ),
                                ),
                                onDelete: () => _confirmDelete(context, job),
                              ),
                            );
                          },
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 40,
            color: Colors.grey[700],
          ),
          const SizedBox(height: 8),
          Text(
            'No jobs yet',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Drag here or tap +',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Job job) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Job?'),
        content: Text(
          'Remove "${job.company} — ${job.role}" from your tracker?',
          style: TextStyle(color: Colors.grey[600]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<JobsProvider>().deleteJob(job.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.delete_rounded, color: Color(0xFFCC1016)),
                      SizedBox(width: 8),
                      Text('Job removed'),
                    ],
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCC1016),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
