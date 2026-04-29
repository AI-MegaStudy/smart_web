import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';

class AppCountButton extends StatelessWidget {
  const AppCountButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF6F3EA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line),
        ),
        child: Icon(icon, color: AppColors.textPrimary),
      ),
    );
  }
}
