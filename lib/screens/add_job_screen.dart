import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/job.dart';
import '../providers/jobs_provider.dart';

class AddJobScreen extends StatefulWidget {
  final Job? prefilled;
  const AddJobScreen({super.key, this.prefilled});

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _companyCtrl;
  late TextEditingController _roleCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _salaryCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _tagsCtrl;
  late TextEditingController _urlCtrl;
  late String _status;
  bool _isEditing = false;
  DateTime? _interviewDate;
  DateTime? _deadline;

  static const _statuses = [
    {'id': 'wishlist', 'label': 'Wishlist', 'icon': Icons.favorite_border_rounded},
    {'id': 'applied', 'label': 'Applied', 'icon': Icons.description_rounded},
    {'id': 'interview', 'label': 'Interview', 'icon': Icons.forum_rounded},
    {'id': 'offer', 'label': 'Offer', 'icon': Icons.emoji_events_rounded},
    {'id': 'rejected', 'label': 'Rejected', 'icon': Icons.cancel_rounded},
  ];

  @override
  void initState() {
    super.initState();
    final job = widget.prefilled;
    _isEditing = job != null && job.company.isNotEmpty;
    _companyCtrl = TextEditingController(text: job?.company ?? '');
    _roleCtrl = TextEditingController(text: job?.role ?? '');
    _locationCtrl = TextEditingController(text: job?.location ?? '');
    _salaryCtrl = TextEditingController(text: job?.salary ?? '');
    _notesCtrl = TextEditingController(text: job?.notes ?? '');
    _tagsCtrl = TextEditingController(text: job?.tags.join(', ') ?? '');
    _urlCtrl = TextEditingController(text: job?.url ?? '');
    _status = job?.status ?? 'wishlist';

    if (job?.interviewDate.isNotEmpty == true) {
      try {
        _interviewDate = DateTime.parse(job!.interviewDate);
      } catch (_) {}
    }
    if (job?.deadline.isNotEmpty == true) {
      try {
        _deadline = DateTime.parse(job!.deadline);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _companyCtrl.dispose();
    _roleCtrl.dispose();
    _locationCtrl.dispose();
    _salaryCtrl.dispose();
    _notesCtrl.dispose();
    _tagsCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<JobsProvider>();
    final tags = _tagsCtrl.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (widget.prefilled != null) {
      final job = widget.prefilled!
        ..company = _companyCtrl.text
        ..role = _roleCtrl.text
        ..location = _locationCtrl.text
        ..salary = _salaryCtrl.text
        ..notes = _notesCtrl.text
        ..tags = tags
        ..status = _status
        ..url = _urlCtrl.text
        ..interviewDate = _interviewDate?.toIso8601String() ?? ''
        ..deadline = _deadline?.toIso8601String() ?? '';

      if (_isEditing) {
        provider.updateJob(job.id, job);
      } else {
        provider.addJob(job);
      }
    } else {
      final job = provider.newJob()
        ..company = _companyCtrl.text
        ..role = _roleCtrl.text
        ..location = _locationCtrl.text
        ..salary = _salaryCtrl.text
        ..notes = _notesCtrl.text
        ..tags = tags
        ..status = _status
        ..url = _urlCtrl.text
        ..interviewDate = _interviewDate?.toIso8601String() ?? ''
        ..deadline = _deadline?.toIso8601String() ?? '';
      provider.addJob(job);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF00B894)),
            const SizedBox(width: 8),
            Text(_isEditing ? 'Job updated!' : 'Job added!'),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isInterview}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (isInterview ? _interviewDate : _deadline) ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6C5CE7),
              surface: Color(0xFF1A1A2E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isInterview) {
          _interviewDate = picked;
        } else {
          _deadline = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Job' : 'Add New Job'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header illustration
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6C5CE7).withValues(alpha: 0.2),
                      const Color(0xFFA29BFE).withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF6C5CE7).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C5CE7).withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _isEditing ? Icons.edit_note_rounded : Icons.post_add_rounded,
                        color: const Color(0xFFA29BFE),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEditing ? 'Update Details' : 'Track a New Opportunity',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isEditing
                                ? 'Modify the job information below'
                                : 'Fill in the details or use AI auto-fill',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              _buildSectionLabel('Company *', Icons.business_rounded),
              const SizedBox(height: 8),
              TextFormField(
                controller: _companyCtrl,
                decoration: const InputDecoration(hintText: 'e.g. Google'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 20),
              _buildSectionLabel('Role *', Icons.badge_rounded),
              const SizedBox(height: 8),
              TextFormField(
                controller: _roleCtrl,
                decoration: const InputDecoration(hintText: 'e.g. Software Engineer'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 20),
              _buildSectionLabel('Location', Icons.location_on_rounded),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationCtrl,
                decoration: const InputDecoration(hintText: 'e.g. Remote / San Francisco'),
              ),

              const SizedBox(height: 20),
              _buildSectionLabel('Salary', Icons.attach_money_rounded),
              const SizedBox(height: 8),
              TextFormField(
                controller: _salaryCtrl,
                decoration: const InputDecoration(hintText: 'e.g. \$120k - \$150k'),
              ),

              // Job URL
              const SizedBox(height: 20),
              _buildSectionLabel('Job URL', Icons.link_rounded),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _urlCtrl,
                      decoration: const InputDecoration(
                        hintText: 'https://...',
                      ),
                      keyboardType: TextInputType.url,
                    ),
                  ),
                  if (_urlCtrl.text.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C5CE7).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.open_in_new_rounded, color: Color(0xFFA29BFE)),
                        onPressed: () async {
                          final url = Uri.tryParse(_urlCtrl.text);
                          if (url != null) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        },
                      ),
                    ),
                  ],
                ],
              ),

              // Interview Date
              const SizedBox(height: 20),
              _buildSectionLabel('Interview Date', Icons.event_rounded),
              const SizedBox(height: 8),
              _buildDatePicker(
                date: _interviewDate,
                hint: 'Select interview date',
                onTap: () => _pickDate(isInterview: true),
                onClear: () => setState(() => _interviewDate = null),
              ),

              // Deadline
              const SizedBox(height: 20),
              _buildSectionLabel('Application Deadline', Icons.timer_rounded),
              const SizedBox(height: 8),
              _buildDatePicker(
                date: _deadline,
                hint: 'Select deadline',
                onTap: () => _pickDate(isInterview: false),
                onClear: () => setState(() => _deadline = null),
              ),

              const SizedBox(height: 20),
              _buildSectionLabel('Status', Icons.view_kanban_rounded),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF16213E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2A2A4A)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _status,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF16213E),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    items: _statuses
                            .map((s) => DropdownMenuItem<String>(
                                  value: s['id'] as String,
                                  child: Row(
                                    children: [
                                      Icon(s['icon'] as IconData,
                                          size: 18, color: const Color(0xFFA29BFE)),
                                      const SizedBox(width: 12),
                                      Text(
                                        s['label'] as String,
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                    onChanged: (v) => setState(() => _status = v ?? 'wishlist'),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              _buildSectionLabel('Tags', Icons.label_rounded),
              const SizedBox(height: 8),
              TextFormField(
                controller: _tagsCtrl,
                decoration: const InputDecoration(
                  hintText: 'flutter, remote, startup (comma-separated)',
                ),
              ),

              const SizedBox(height: 20),
              _buildSectionLabel('Notes', Icons.notes_rounded),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Any extra notes...',
                ),
              ),

              // Activity Timeline
              if (_isEditing && widget.prefilled != null && widget.prefilled!.activityLog.isNotEmpty) ...[
                const SizedBox(height: 28),
                _buildSectionLabel('Activity Timeline', Icons.timeline_rounded),
                const SizedBox(height: 12),
                _buildActivityTimeline(),
              ],

              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C5CE7).withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: Icon(_isEditing ? Icons.save_rounded : Icons.add_rounded),
                  label: Text(
                    _isEditing ? 'Update Job' : 'Add Job',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required DateTime? date,
    required String hint,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2A4A)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: date != null ? const Color(0xFFA29BFE) : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                date != null
                    ? DateFormat('EEEE, MMM dd, yyyy').format(date)
                    : hint,
                style: TextStyle(
                  color: date != null ? Colors.white : Colors.grey[600],
                  fontSize: 15,
                ),
              ),
            ),
            if (date != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.clear_rounded, size: 20, color: Colors.grey[500]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTimeline() {
    final logs = widget.prefilled!.activityLog;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A4A)),
      ),
      child: Column(
        children: logs.asMap().entries.map((entry) {
          final idx = entry.key;
          final log = entry.value;
          final isLast = idx == logs.length - 1;
          final dateStr = log['date'] ?? '';
          String formattedDate = '';
          try {
            final dt = DateTime.parse(dateStr);
            formattedDate = DateFormat('MMM dd, hh:mm a').format(dt);
          } catch (_) {
            formattedDate = dateStr;
          }

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline line & dot
                SizedBox(
                  width: 24,
                  child: Column(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isLast
                              ? const Color(0xFF6C5CE7)
                              : Colors.grey[600],
                          border: isLast
                              ? Border.all(
                                  color: const Color(0xFFA29BFE),
                                  width: 2,
                                )
                              : null,
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: Colors.grey[700],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log['action'] ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: isLast ? Colors.white : Colors.grey[400],
                            fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFA29BFE)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
