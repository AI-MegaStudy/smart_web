import 'package:flutter/material.dart';

class NoticeBox extends StatelessWidget {
  const NoticeBox({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x142F6F4E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x2E2F6F4E)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.45,
                color: const Color(0xFF304236),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
