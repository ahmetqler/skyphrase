import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LessonTopBar extends StatelessWidget {
  final double progress;
  final VoidCallback onClose;

  const LessonTopBar({
    super.key,
    required this.progress,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.close, color: AppColors.textSecondary),
          onPressed: onClose,
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}
