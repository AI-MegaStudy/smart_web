import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/local_basket_item_model.dart';
import '../../view_models/payment_view_model.dart';
import '../../widgets/app_alert_dialog.dart';
import '../../widgets/brand_app_bar_title.dart';
import '../../widgets/flow_status_badge.dart';
import '../../widgets/notice_box.dart';

class MockPaymentPage extends StatefulWidget {
  const MockPaymentPage({super.key, required this.orderId});

  final int orderId;

  @override
  State<MockPaymentPage> createState() => _MockPaymentPageState();
}

class _MockPaymentPageState extends State<MockPaymentPage> {
  late final PaymentViewModel _viewModel;
  bool _isConfirmed = false;

  @override
  void initState() {
    super.initState();
    _viewModel = PaymentViewModel(orderId: widget.orderId)..load();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 72,
        titleSpacing: 14,
        title: const BrandAppBarTitle(),
        actions: const [
          FlowStatusBadge(
            stepLabel: '예약 흐름 4/5',
            statusLabel: '결제 대기',
            icon: Icons.credit_card_outlined,
          ),
        ],
      ),
      body: _ScreenBackground(
        child: AnimatedBuilder(
          animation: _viewModel,
          builder: (context, _) {
            if (_viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _ConstrainedContent(
                    child: _PageIntro(viewModel: _viewModel),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _ConstrainedContent(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 980;
                          final details = _PaymentDetails(
                            items: _viewModel.items,
                          );
                          final summary = _PaymentSummary(
                            viewModel: _viewModel,
                            isConfirmed: _isConfirmed,
                            onConfirmedChanged: (value) {
                              setState(() => _isConfirmed = value);
                            },
                            onPay: _pay,
                          );

                          if (!isWide) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                details,
                                const SizedBox(height: 18),
                                summary,
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 6, child: details),
                              const SizedBox(width: 18),
                              Expanded(flex: 4, child: summary),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _pay() async {
    if (!_isConfirmed) {
      await showAppAlertDialog(context, message: '결제 전 확인 내용을 동의해주세요.');
      return;
    }

    if (!mounted) return;
    Navigator.pushNamed(
      context,
      AppRoutes.orderComplete,
      arguments: _viewModel.orderId,
    );
  }
}

class _ScreenBackground extends StatelessWidget {
  const _ScreenBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF5F1E5), Color(0xFFEEF4EE), Color(0xFFF7F7F1)],
          stops: [0, 0.48, 1],
        ),
      ),
      child: child,
    );
  }
}

class _ConstrainedContent extends StatelessWidget {
  const _ConstrainedContent({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: child,
      ),
    );
  }
}

class _PageIntro extends StatelessWidget {
  const _PageIntro({required this.viewModel});

  final PaymentViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '결제 전 확인',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '수확 예약 상품과 배송 정보를 확인하세요',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF163B2B),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '주문번호 ORD-20261012-${viewModel.orderId.toString().padLeft(3, '0')} 결제 전 수확 일정, 배송지, 결제 금액을 다시 확인합니다.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.5,
              color: const Color(0xFF5F6C62),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentDetails extends StatelessWidget {
  const _PaymentDetails({required this.items});

  final List<LocalBasketItemModel> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionCard(
          title: '수확 예약 상품',
          icon: Icons.inventory_2_outlined,
          child: Column(
            children: [
              for (final item in items) ...[
                _ReservationItem(item: item),
                if (item != items.last) const Divider(height: 24),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        const _SectionCard(
          title: '배송 정보',
          icon: Icons.local_shipping_outlined,
          child: Column(
            children: [
              _InfoRow(label: '받는 분', value: '홍길동'),
              _InfoRow(label: '연락처', value: '010-1111-2222'),
              _InfoRow(label: '주소', value: '서울시 강남구 테헤란로 123'),
              _InfoRow(label: '요청사항', value: '문 앞에 놓아주세요'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const NoticeBox(
          message:
              '결제 후 농가가 수확 가능 수량을 최종 확인합니다. 수확 일정은 기상과 생육 상황에 따라 조정될 수 있습니다.',
        ),
      ],
    );
  }
}

class _ReservationItem extends StatelessWidget {
  const _ReservationItem({required this.item});

  final LocalBasketItemModel item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFE7F3EB),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.spa_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                '${item.harvestStartLabel}-${item.harvestEndLabel} 수확 예정',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF5F6C62),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SmallBadge(label: '${formatKg(item.packageUnitKg)}kg'),
                  _SmallBadge(label: '${item.packageCount}박스'),
                  _SmallBadge(label: '${formatKg(item.reservedKg)}kg'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          formatPrice(item.subtotalAmount),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class _PaymentSummary extends StatelessWidget {
  const _PaymentSummary({
    required this.viewModel,
    required this.isConfirmed,
    required this.onConfirmedChanged,
    required this.onPay,
  });

  final PaymentViewModel viewModel;
  final bool isConfirmed;
  final ValueChanged<bool> onConfirmedChanged;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    const shippingFee = 0;
    final total = viewModel.totalAmount + shippingFee;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '결제 수단',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            const _PaymentMethodTile(),
            const SizedBox(height: 22),
            Text(
              '결제 금액',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            _SummaryRow(
              label: '상품 금액',
              value: formatPrice(viewModel.totalAmount),
            ),
            const SizedBox(height: 10),
            _SummaryRow(label: '배송비', value: formatPrice(shippingFee)),
            const Divider(height: 28),
            _SummaryRow(
              label: '최종 결제 금액',
              value: formatPrice(total),
              strong: true,
            ),
            const SizedBox(height: 18),
            CheckboxListTile(
              value: isConfirmed,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('수확 일정과 결제 금액을 확인했습니다.'),
              onChanged: (value) => onConfirmedChanged(value ?? false),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: onPay,
              icon: const Icon(Icons.credit_score_outlined),
              label: const Text('결제하기'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFEFF5F0),
        border: Border.all(color: const Color(0xFFD4E1D8)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              Icons.radio_button_checked,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                '카드 간편결제',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            const _SmallBadge(label: '선택됨'),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 82,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF657166),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final textStyle = strong
        ? Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.primary,
          )
        : Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF657166)),
          ),
        ),
        Text(value, style: textStyle),
      ],
    );
  }
}

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1ED),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: const Color(0xFF4B584D),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
