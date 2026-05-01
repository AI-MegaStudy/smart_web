import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool showHome;
  final bool showBack;
  final String? actionText;
  final String? actionRoute;

  const AppHeader({
    super.key,
    this.title = 'Harvest Slot',
    this.icon = Icons.eco,
    this.showHome = false,
    this.showBack = false,
    this.actionText,
    this.actionRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const Spacer(),
          if (showHome)
            IconButton(
              tooltip: '홈',
              onPressed: () => Navigator.pushNamed(context, '/'),
              icon: const Icon(Icons.home_outlined, size: 20),
            ),
          if (showBack)
            IconButton(
              tooltip: '뒤로',
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back, size: 20),
            ),
          if (actionText != null && actionRoute != null)
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, actionRoute!),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(actionText!),
            ),
        ],
      ),
    );
  }
}
