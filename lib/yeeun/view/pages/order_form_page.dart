import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/responsive.dart';
import '../widgets/app_header.dart';

class OrderFormPage extends StatelessWidget {
  const OrderFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(
            title: '주문서 작성',
            icon: Icons.local_shipping_outlined,
            actionText: '예약 보관 중',
            actionRoute: '/cart',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(38, 34, 38, 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Responsive.maxWidth(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '배송지와 결제 전 확인',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '기본 배송지로 예약을 주문 전환',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      isMobile
                          ? Column(
                              children: [
                                _DeliveryForm(),
                                const SizedBox(height: 18),
                                _OrderSummary(),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 3, child: _DeliveryForm()),
                                const SizedBox(width: 18),
                                const SizedBox(width: 310, child: _OrderSummary()),
                              ],
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
}

class _DeliveryForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('배송 프로필 선택', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('저장된 기본 배송지를 우선 사용합니다.', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 22),
          Row(
            children: const [
              Expanded(
                child: _AddressCard(
                  title: '기본 배송지',
                  lines: ['홍길동 · 010-1111-2222', '서울시 강남구 테헤란로 123'],
                  selected: true,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _AddressCard(
                  title: '회사 배송지',
                  lines: ['홍길동', '서울시 서초구 반포대로 45'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('배송 메모 선택', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: '문 앞에 놓아주세요',
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: '문 앞에 놓아주세요', child: Text('문 앞에 놓아주세요')),
              DropdownMenuItem(value: '배송 전 연락 주세요', child: Text('배송 전 연락 주세요')),
              DropdownMenuItem(value: '경비실에 맡겨주세요', child: Text('경비실에 맡겨주세요')),
            ],
            onChanged: (_) {},
          ),
          const Divider(height: 28),
          const Text('필요 시 수정', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          _input('수령인 변경', '기본값 사용'),
          _input('전화번호 변경', '기본값 사용'),
          _input('상세 주소 변경', '기본 주소 사용'),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xffBFEAF5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('예약 보관 시간이 만료되기 전에만 주문을 생성할 수 있습니다.'),
          ),
        ],
      ),
    );
  }

  Widget _input(String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final String title;
  final List<String> lines;
  final bool selected;

  const _AddressCard({
    required this.title,
    required this.lines,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: selected ? const Color(0xffB3EFCB) : Colors.white,
        border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 7),
          ...lines.map((line) => Text(line, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _line('예약 RES-20261012-005', '사과 2종', strong: true),
          const Divider(height: 22),
          _line('예약 만료', '2026-10-12 19:12', strong: true),
          _line('배송비', '무료', strong: true),
          const Divider(height: 22),
          _line('주문 금액', '110,000원', strong: true, large: true),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xffEEF0EB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '배송 정보\n\n홍길동 · 010-1111-2222\n서울시 강남구 테헤란로 123\n\n문 앞에 놓아주세요',
              style: TextStyle(height: 1.55),
            ),
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/payment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text('주문 생성'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(String label, String value, {bool strong = false, bool large = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: large ? 19 : 14,
              fontWeight: strong ? FontWeight.w900 : FontWeight.w500,
              color: large ? AppColors.primary : AppColors.text,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: large ? 19 : 14,
              fontWeight: FontWeight.w900,
              color: large ? AppColors.primary : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    border: Border.all(color: AppColors.border),
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 7,
        offset: const Offset(0, 3),
      ),
    ],
  );
}
