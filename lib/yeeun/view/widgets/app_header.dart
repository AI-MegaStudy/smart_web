import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pushNamed(context, '/'),
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.eco, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Harvest Slot',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const Spacer(),
          _navButton(context, '상품', '/products', filled: false),
          const SizedBox(width: 8),
          _navButton(context, '예약현황', '/reservation-status', filled: false),
          const SizedBox(width: 8),
          _navButton(context, '로그인', '/login', filled: false),
          const SizedBox(width: 8),
          _navButton(context, '예약함', '/cart', filled: true),
        ],
      ),
    );
  }

  Widget _navButton(
    BuildContext context,
    String text,
    String route, {
    required bool filled,
  }) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.primary),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: filled ? Colors.white : AppColors.text,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
