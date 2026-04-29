import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';
import '../common/app_brand_mark.dart';
import '../common/app_nav_pill.dart';
import 'smart_page.dart';

class SmartHeader extends StatelessWidget {
  const SmartHeader({
    super.key,
    required this.currentPage,
    required this.onSelectPage,
  });

  final SmartPage currentPage;
  final ValueChanged<SmartPage> onSelectPage;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1320),
              child: Row(
                children: [
                  const AppBrandMark(),
                  const SizedBox(width: 56),
                  Expanded(
                    child: Wrap(
                      spacing: 12,
                      children: [
                        for (final page in SmartPage.values)
                          AppNavPill(
                            label: page.label,
                            selected: currentPage == page,
                            onTap: () => onSelectPage(page),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 240,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '과수 상품 검색',
                        prefixIcon: const Icon(Icons.search_rounded),
                        isDense: true,
                        filled: true,
                        fillColor: const Color(0xFFF6F3EA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  OutlinedButton(onPressed: () {}, child: const Text('로그인')),
                  const SizedBox(width: 10),
                  FilledButton(onPressed: () {}, child: const Text('가입')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
