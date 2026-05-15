import 'package:flutter/material.dart';

class AiInsightCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final List<Color> gradientColors;
  final bool isLoading;
  final VoidCallback? onRefresh;

  const AiInsightCard({
    super.key,
    required this.title,
    required this.content,
    this.icon = Icons.auto_awesome,
    this.gradientColors = const [Color(0xFF0A66C2), Color(0xFF70B5F9)],
    this.isLoading = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: gradientColors[0].withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with gradient
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0A66C2).withValues(alpha: 0.08),
                  Color(0xFF0A66C2).withValues(alpha: 0.03),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(19),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF0A66C2)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A66C2),
                    ),
                  ),
                ),
                if (onRefresh != null)
                  GestureDetector(
                    onTap: isLoading ? null : onRefresh,
                    child: Icon(
                      Icons.refresh_rounded,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: isLoading
                ? _buildLoadingState()
                : Text(
                    content,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        3,
        (i) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          height: 14,
          width: i == 2 ? 150 : double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFEBEBEB),
            borderRadius: BorderRadius.circular(7),
          ),
        ),
      ),
    );
  }
}
