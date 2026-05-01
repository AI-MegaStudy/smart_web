import 'package:flutter/material.dart';
import 'package:smart_web/yeeun/model/product_model.dart';
import 'package:smart_web/yeeun/vm/product_view_model.dart';

import '../../core/app_colors.dart';
import '../../core/responsive.dart';
import '../widgets/app_header.dart';

class ReturnRequestPage extends StatefulWidget {
  const ReturnRequestPage({super.key});

  @override
  State<ReturnRequestPage> createState() => _ReturnRequestPageState();
}

class _ReturnRequestPageState extends State<ReturnRequestPage> {
  String _reason = '배송 중 파손';
  String _refund = '전액 78,000원';

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
                                _ReturnForm(
                                  product: product,
                                  reason: _reason,
                                  refund: _refund,
                                  onReasonChanged: _changeReason,
                                  onRefundChanged: _changeRefund,
                                ),
                                const SizedBox(height: 18),
                                _ReturnSummary(reason: _reason, refund: _refund),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: _ReturnForm(
                                    product: product,
                                    reason: _reason,
                                    refund: _refund,
                                    onReasonChanged: _changeReason,
                                    onRefundChanged: _changeRefund,
                                  ),
                                ),
                                const SizedBox(width: 18),
                                SizedBox(
                                  width: 330,
                                  child: _ReturnSummary(
                                    reason: _reason,
                                    refund: _refund,
                                  ),
                                ),
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

  void _changeReason(String reason) {
    setState(() => _reason = reason);
  }

  void _changeRefund(String refund) {
    setState(() => _refund = refund);
  }
}

class _ReturnForm extends StatelessWidget {
  final ProductModel product;
  final String reason;
  final String refund;
  final ValueChanged<String> onReasonChanged;
  final ValueChanged<String> onRefundChanged;

  const _ReturnForm({
    required this.product,
    required this.reason,
    required this.refund,
    required this.onReasonChanged,
    required this.onRefundChanged,
  });

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
                  child: Image.asset(
                    product.imageUrl,
                    width: 74,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ReasonChip(
                title: '배송 중 파손',
                detail: '박스 또는 상품이 파손됨',
                selected: reason == '배송 중 파손',
                onTap: () => onReasonChanged('배송 중 파손'),
              ),
              _ReasonChip(
                title: '상품 변질',
                detail: '수령 시 신선도 이상',
                selected: reason == '상품 변질',
                onTap: () => onReasonChanged('상품 변질'),
              ),
              _ReasonChip(
                title: '오배송',
                detail: '다른 상품이 도착함',
                selected: reason == '오배송',
                onTap: () => onReasonChanged('오배송'),
              ),
              _ReasonChip(
                title: '구성 누락',
                detail: '일부 상품이 빠짐',
                selected: reason == '구성 누락',
                onTap: () => onReasonChanged('구성 누락'),
              ),
              _ReasonChip(
                title: '기타',
                detail: '기타 검토',
                selected: reason == '기타',
                onTap: () => onReasonChanged('기타'),
              ),
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
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('현재는 샘플 화면이라 업로드 UI만 표시합니다.')),
              );
            },
            child: Container(
              height: 110,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.text),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('파손 사진 2장이 첨부되었습니다'),
            ),
          ),
          const Divider(height: 28),
          const Text('요청 금액 선택', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Wrap(
            children: [
              _RefundOption(
                text: '전액 78,000원',
                selected: refund == '전액 78,000원',
                onTap: () => onRefundChanged('전액 78,000원'),
              ),
              _RefundOption(
                text: '부분 39,000원',
                selected: refund == '부분 39,000원',
                onTap: () => onRefundChanged('부분 39,000원'),
              ),
              _RefundOption(
                text: '검수 후 산정',
                selected: refund == '검수 후 산정',
                onTap: () => onRefundChanged('검수 후 산정'),
              ),
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
  final VoidCallback onTap;

  const _ReasonChip({
    required this.title,
    required this.detail,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
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
      ),
    );
  }
}

class _RefundOption extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _RefundOption({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xffCFEFDB) : Colors.white,
          border: Border.all(color: AppColors.text),
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
        ),
      ),
    );
  }
}

class _ReturnSummary extends StatelessWidget {
  final String reason;
  final String refund;

  const _ReturnSummary({
    required this.reason,
    required this.refund,
  });

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
          _SummaryLine(label: '반품 사유', value: reason),
          _SummaryLine(label: '요청 금액', value: refund),
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
                onPressed: () => Navigator.pushNamed(context, '/order-detail'),
                child: const Text('취소'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('반품 요청이 접수되었습니다.')),
                  );
                  Navigator.pushNamed(context, '/orders');
                },
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
