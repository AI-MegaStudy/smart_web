import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/responsive.dart';
import '../../vm/product_view_model.dart';
import '../widgets/app_header.dart';
import '../widgets/product_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = ProductViewModel();
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Responsive.maxWidth(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isMobile
                          ? Column(
                              children: [
                                _heroText(context),
                                const SizedBox(height: 20),
                                _heroImage(),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(child: _heroText(context)),
                                const SizedBox(width: 24),
                                Expanded(child: _heroImage()),
                              ],
                            ),
                      const SizedBox(height: 36),
                      const Text(
                        '예약 가능한 상품',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Text(
                        '이번 주 수확 예정 상품',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: vm.products.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isMobile ? 1 : 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: isMobile ? 1.1 : 0.64,
                        ),
                        itemBuilder: (_, index) {
                          return ProductCard(product: vm.products[index]);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroText(BuildContext context) {
    return Container(
      height: 360,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '이번 주 예약 가능',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '수확일이 확정된 사과만 예약하세요',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            '농가가 확정한 수확 예정 범위, 예약 가능 수량, 판매가를 기준으로 주문하고 배송 상태까지 확인합니다.',
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/products'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('예약 상품 보기'),
          ),
        ],
      ),
    );
  }

  Widget _heroImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Image.asset(
        'assets/images/apple1.jpg',
        height: 360,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
