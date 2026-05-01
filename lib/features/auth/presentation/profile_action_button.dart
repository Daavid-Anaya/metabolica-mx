import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/app_colors.dart';

class ProfileActionButton extends StatelessWidget {
  const ProfileActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => context.push('/profile'),
      icon: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
        ),
        child: const Icon(Icons.account_circle_outlined, color: AppColors.accent),
      ),
    );
  }
}
