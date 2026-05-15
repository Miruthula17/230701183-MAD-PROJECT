import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/job.dart';
import '../services/gemini_service.dart';

class FollowUpScreen extends StatefulWidget {
  final Job job;
  const FollowUpScreen({super.key, required this.job});

  @override
  State<FollowUpScreen> createState() => _FollowUpScreenState();
}

class _FollowUpScreenState extends State<FollowUpScreen>
    with SingleTickerProviderStateMixin {
  String _email = '';
  bool _loading = true;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _generate();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    try {
      final text = await GeminiService().generateFollowUp(
        company: widget.job.company,
        role: widget.job.role,
        notes: widget.job.notes,
      );
      if (!mounted) return;
      setState(() {
        _email = text;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _email = 'Failed to generate email. Please check your API key and try again.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Follow-up Email', style: TextStyle(fontSize: 18)),
            Text(
              '${widget.job.company} — ${widget.job.role}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_loading)
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF057642).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.copy_rounded, color: Color(0xFF057642)),
                tooltip: 'Copy to clipboard',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _email));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Color(0xFF057642)),
                          SizedBox(width: 8),
                          Text('Copied to clipboard!'),
                        ],
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
          if (!_loading)
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0A66C2).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Color(0xFF70B5F9)),
                tooltip: 'Regenerate',
                onPressed: () {
                  setState(() => _loading = true);
                  _generate();
                },
              ),
            ),
        ],
      ),
      body: _loading ? _buildLoadingState() : _buildEmailContent(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: const [
                      Color(0xFF0A66C2),
                      Color(0xFF70B5F9),
                      Color(0xFFE84393),
                      Color(0xFF0A66C2),
                    ],
                    transform: GradientRotation(
                      _shimmerController.value * 6.28,
                    ),
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: const Color(0xFF191919),
                  size: 32,
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Generating your email...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF191919),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI is crafting a professional follow-up',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // AI badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0A66C2).withValues(alpha: 0.2),
                  const Color(0xFFE84393).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF0A66C2).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, size: 16, color: Color(0xFF70B5F9)),
                const SizedBox(width: 8),
                Text(
                  'Generated by Gemini AI',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Email content
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEBEBEB)),
            ),
            child: TextField(
              controller: TextEditingController(text: _email),
              maxLines: null,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: const Color(0xFF191919),
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                fillColor: Colors.transparent,
                filled: true,
              ),
              onChanged: (v) => _email = v,
            ),
          ),
          const SizedBox(height: 20),
          // Copy button
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [Color(0xFF057642), Color(0xFF057642)],
              ),
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _email));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Color(0xFF057642)),
                        SizedBox(width: 8),
                        Text('Email copied to clipboard!'),
                      ],
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.copy_rounded),
              label: const Text('Copy Email',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
