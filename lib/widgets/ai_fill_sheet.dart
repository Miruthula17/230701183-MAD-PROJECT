import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/gemini_service.dart';
import '../providers/jobs_provider.dart';
import '../screens/add_job_screen.dart';

class AIFillSheet extends StatefulWidget {
  const AIFillSheet({super.key});

  @override
  State<AIFillSheet> createState() => _AIFillSheetState();
}

class _AIFillSheetState extends State<AIFillSheet>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  bool _loading = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _extract() async {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFE8A723)),
              SizedBox(width: 8),
              Text('Please paste a job description first'),
            ],
          ),
        ),
      );
      return;
    }

    setState(() => _loading = true);
    _pulseController.repeat(reverse: true);

    try {
      final details = await GeminiService().extractJobDetails(_controller.text);
      if (!mounted) return;
      final provider = context.read<JobsProvider>();
      final job = provider.newJob()
        ..company = details['company'] ?? ''
        ..role = details['role'] ?? ''
        ..location = details['location'] ?? ''
        ..salary = details['salary'] ?? ''
        ..tags = List<String>.from(details['tags'] ?? []);
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddJobScreen(prefilled: job)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Color(0xFFCC1016)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Could not extract details. Check your API key and try again.',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (mounted) {
      setState(() => _loading = false);
      _pulseController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0A66C2), Color(0xFFE84393)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome,
                      color: const Color(0xFF191919), size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Auto-Fill',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF191919),
                        ),
                      ),
                      Text(
                        'Paste a job description to auto-extract details',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Text field
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEBEBEB)),
              ),
              child: TextField(
                controller: _controller,
                maxLines: 8,
                style: const TextStyle(fontSize: 14, height: 1.5),
                decoration: InputDecoration(
                  hintText:
                      'Paste the full job description here...\n\ne.g. "We are looking for a Senior Flutter Developer at Google..."',
                  hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                  filled: true,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Extract button
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: _loading
                          ? [
                              const Color(0xFF0A66C2),
                              Color.lerp(
                                const Color(0xFF70B5F9),
                                const Color(0xFFE84393),
                                _pulseController.value,
                              )!,
                            ]
                          : [
                              const Color(0xFF0A66C2),
                              const Color(0xFF70B5F9),
                            ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0A66C2).withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _extract,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: const Color(0xFF191919),
                        ),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(
                  _loading ? 'Extracting with Gemini...' : 'Auto-fill with Gemini AI',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  disabledForegroundColor: Colors.white70,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
