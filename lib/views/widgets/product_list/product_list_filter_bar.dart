import 'package:flutter/material.dart';

import 'filter_field.dart';

class ProductListFilterBar extends StatelessWidget {
  const ProductListFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Expanded(child: FilterField(label: '과일 종류', value: '사과')),
            const SizedBox(width: 14),
            const Expanded(child: FilterField(label: '수확월', value: '10월')),
            const SizedBox(width: 14),
            const Expanded(child: FilterField(label: '예약 상태', value: '예약 가능')),
            const SizedBox(width: 14),
            const Expanded(child: FilterField(label: '정렬', value: '추천순')),
            const SizedBox(width: 18),
            FilledButton(onPressed: () {}, child: const Text('필터 적용')),
          ],
        ),
      ),
    );
  }
}
