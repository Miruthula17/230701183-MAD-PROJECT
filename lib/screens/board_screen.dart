import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/jobs_provider.dart';
import '../widgets/column_list.dart';
import '../widgets/ai_fill_sheet.dart';
import 'add_job_screen.dart';

const kColumns = [
  {'id': 'wishlist', 'label': 'Wishlist', 'icon': Icons.favorite_border_rounded},
  {'id': 'applied', 'label': 'Applied', 'icon': Icons.description_rounded},
  {'id': 'interview', 'label': 'Interview', 'icon': Icons.forum_rounded},
  {'id': 'offer', 'label': 'Offer', 'icon': Icons.emoji_events_rounded},
  {'id': 'rejected', 'label': 'Rejected', 'icon': Icons.cancel_rounded},
];

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  bool _showSearch = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JobsProvider>();
    final totalJobs = provider.jobs.length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.work_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Job Tracker'),
                Text(
                  '$totalJobs application${totalJobs == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Search toggle
          Container(
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: _showSearch ? const Color(0xFF6C5CE7).withValues(alpha: 0.2) : const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A2A4A)),
            ),
            child: IconButton(
              icon: Icon(
                _showSearch ? Icons.search_off_rounded : Icons.search_rounded,
                size: 22,
                color: _showSearch ? const Color(0xFFA29BFE) : Colors.grey,
              ),
              tooltip: 'Search',
              onPressed: () {
                setState(() {
                  _showSearch = !_showSearch;
                  if (!_showSearch) {
                    _searchController.clear();
                    provider.setSearch('');
                  }
                });
              },
            ),
          ),
          // Sort button
          Container(
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A2A4A)),
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.sort_rounded, size: 22, color: Colors.grey),
              color: const Color(0xFF1A1A2E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tooltip: 'Sort',
              onSelected: (v) => provider.setSortBy(v),
              itemBuilder: (_) => [
                _buildSortItem('newest', 'Newest First', Icons.access_time_rounded, provider.sortBy),
                _buildSortItem('company', 'Company A-Z', Icons.sort_by_alpha_rounded, provider.sortBy),
                _buildSortItem('salary', 'Salary', Icons.attach_money_rounded, provider.sortBy),
              ],
            ),
          ),
          // Export CSV
          Container(
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A2A4A)),
            ),
            child: IconButton(
              icon: const Icon(Icons.file_download_outlined, size: 22, color: Colors.grey),
              tooltip: 'Export CSV',
              onPressed: () => _exportCsv(context, provider),
            ),
          ),
          // AI Fill
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A2A4A)),
            ),
            child: IconButton(
              icon: const ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: _aiGradientShader,
                child: Icon(Icons.auto_awesome, size: 22),
              ),
              tooltip: 'AI Fill from JD',
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const AIFillSheet(),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _showSearch
                ? Container(
                    margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search by company, role, location, tags...',
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFA29BFE)),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  provider.setSearch('');
                                },
                              )
                            : null,
                      ),
                      onChanged: (v) => provider.setSearch(v),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          // Stats bar
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6C5CE7).withValues(alpha: 0.15),
                  const Color(0xFFA29BFE).withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF6C5CE7).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: kColumns.map((col) {
                final count = provider.byStatus(col['id'] as String).length;
                return _StatChip(
                  label: col['label'] as String,
                  count: count,
                  icon: col['icon'] as IconData,
                );
              }).toList(),
            ),
          ),
          // Kanban board
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(12),
              physics: const BouncingScrollPhysics(),
              children: kColumns.map((col) {
                return ColumnList(
                  columnId: col['id'] as String,
                  label: col['label'] as String,
                  icon: col['icon'] as IconData,
                  jobs: provider.byStatus(col['id'] as String),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C5CE7).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddJobScreen()),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Job'),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildSortItem(String value, String label, IconData icon, String current) {
    final isSelected = current == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: isSelected ? const Color(0xFFA29BFE) : Colors.grey),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: isSelected ? const Color(0xFFA29BFE) : Colors.white)),
          if (isSelected) ...[
            const Spacer(),
            const Icon(Icons.check_rounded, size: 18, color: Color(0xFFA29BFE)),
          ],
        ],
      ),
    );
  }

  void _exportCsv(BuildContext context, JobsProvider provider) {
    if (provider.jobs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFFDCB6E)),
              SizedBox(width: 8),
              Text('No jobs to export'),
            ],
          ),
        ),
      );
      return;
    }

    final csv = provider.exportToCsv();
    Clipboard.setData(ClipboardData(text: csv));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF00B894)),
            SizedBox(width: 8),
            Expanded(child: Text('CSV data copied to clipboard! Paste it in a spreadsheet.')),
          ],
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }
}

Shader _aiGradientShader(Rect bounds) {
  return const LinearGradient(
    colors: [Color(0xFF6C5CE7), Color(0xFFE84393)],
  ).createShader(bounds);
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;

  const _StatChip({
    required this.label,
    required this.count,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.grey[400]),
        const SizedBox(height: 2),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }
}
