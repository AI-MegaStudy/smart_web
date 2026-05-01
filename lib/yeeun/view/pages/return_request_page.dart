import 'package:flutter/material.dart';
import 'package:smart_web/yeeun/vm/product_view_model.dart';

import '../../core/app_colors.dart';
import '../../core/responsive.dart';
import '../widgets/app_header.dart';

class ReturnRequestPage extends StatelessWidget {
  const ReturnRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final product = ProductViewModel().products.first;
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(
            title: '반품 신청',
            icon: Icons.assignment_return_outlined,
            actionText: '배송 완료 주문',
            actionRoute: '/orders',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(42, 34, 42, 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: Responsive.maxWidth(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '반품 사유와 증빙 등록',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '배송 완료 사과 주문 반품 요청',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      isMobile
                          ? Column(
                              children: [
                                _ReturnForm(product: product),
                                const SizedBox(height: 18),
                                const _ReturnSummary(),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 3, child: _ReturnForm(product: product)),
                                const SizedBox(width: 18),
                                const SizedBox(width: 330, child: _ReturnSummary()),
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

class _ReturnForm extends StatelessWidget {
  final dynamic product;

  const _ReturnForm({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('반품 대상 선택', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('배송 완료된 주문 라인만 선택 가능합니다.', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(product.imageUrl, width: 74, height: 64, fit: BoxFit.cover),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('후지 사과 5kg', style: TextStyle(fontWeight: FontWeight.w900)),
                      SizedBox(height: 8),
                      Text('주문번호 ORD-20261012-008  후지 사과 2박스'),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xffBFEAF5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('선택됨', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text('반품 사유 선택', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ReasonChip(title: '배송 중 파손', detail: '박스 또는 상품이 파손됨', selected: true),
              _ReasonChip(title: '상품 변질', detail: '수령 시 신선도 이상'),
              _ReasonChip(title: '오배송', detail: '다른 상품이 도착함'),
              _ReasonChip(title: '구성 누락', detail: '일부 상품이 빠짐'),
              _ReasonChip(title: '기타', detail: '기타 검토'),
            ],
          ),
          const SizedBox(height: 16),
          const Text('상세 사유', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const TextField(
            minLines: 4,
            maxLines: 4,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: '박스 외부 파손과 일부 사과 멍이 확인되었습니다.',
            ),
          ),
          const SizedBox(height: 16),
          const Text('증빙 이미지 선택', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Container(
            height: 110,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.text, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('파손 사진 2장이 첨부되었습니다'),
          ),
          const Divider(height: 28),
          const Text('요청 금액 선택', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          const Row(
            children: [
              _RefundOption(text: '전액 78,000원', selected: true),
              _RefundOption(text: '부분 39,000원'),
              _RefundOption(text: '검수 후 산정'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReasonChip extends StatelessWidget {
  final String title;
  final String detail;
  final bool selected;

  const _ReasonChip({
    required this.title,
    required this.detail,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 62,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: selected ? const Color(0xffB3EFCB) : Colors.white,
        border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
          const SizedBox(height: 5),
          Text(detail, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}

class _RefundOption extends StatelessWidget {
  final String text;
  final bool selected;

  const _RefundOption({required this.text, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? const Color(0xffCFEFDB) : Colors.white,
        border: Border.all(color: AppColors.text),
        borderRadius: BorderRadius.horizontal(
          left: selected ? const Radius.circular(18) : Radius.zero,
          right: text == '검수 후 산정' ? const Radius.circular(18) : Radius.zero,
        ),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
    );
  }
}

class _ReturnSummary extends StatelessWidget {
  const _ReturnSummary();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('반품 요청 요약', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          const _SummaryLine(label: '주문 상태', value: '배송 완료'),
          const _SummaryLine(label: '반품 사유', value: '배송 중 파손'),
          const _SummaryLine(label: '요청 금액', value: '78,000원'),
          const _SummaryLine(label: '증빙 이미지', value: '2장'),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xffEEF0EB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '접수 내용\n박스 외부 파손과 일부 사과 멍이 확인되었습니다.\n농가 확인 후 환불 가능 금액을 안내합니다.',
              style: TextStyle(height: 1.55),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xffFFD6D1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('등록 후 반품 접수 상태로 변경됩니다.'),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/orders'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffC82020),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                ),
                child: const Text('반품 요청'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
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
