import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';

class PriceText extends StatelessWidget {
  const PriceText({super.key, required this.price});

  final int price;

  @override
  Widget build(BuildContext context) {
    return Text(
      formatPrice(price),
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
