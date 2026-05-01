import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../core/utils/formatters.dart';
import '../../view_models/payment_view_model.dart';
import '../../widgets/brand_app_bar_title.dart';
import '../../widgets/notice_box.dart';
import '../../widgets/status_badge.dart';

class MockPaymentPage extends StatefulWidget {
  const MockPaymentPage({super.key, required this.orderId});

  final int orderId;

  @override
  State<MockPaymentPage> createState() => _MockPaymentPageState();
}

class _MockPaymentPageState extends State<MockPaymentPage> {
  late final PaymentViewModel _viewModel;

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
                          final card = _PaymentCard(viewModel: _viewModel);
                          final summary = _PaymentSummary(
                            viewModel: _viewModel,
                          );

                          if (!isWide) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                card,
                                const SizedBox(height: 18),
                                summary,
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 6, child: card),
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
            '결제 정보 확인',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '주문 금액을 확인하고 결제를 완료하세요',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF163B2B),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '주문번호 ORD-20261012-${viewModel.orderId.toString().padLeft(3, '0')} 결제를 진행합니다.',
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

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.viewModel});

  final PaymentViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF163B2B), Color(0xFF307051)],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33163B2B),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StatusBadge(label: '결제 대기'),
            const SizedBox(height: 28),
            Text(
              '결제 수단',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white.withAlpha(210),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '카드 간편 결제',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              '결제 금액',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withAlpha(190),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              formatPrice(viewModel.totalAmount),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentSummary extends StatelessWidget {
  const _PaymentSummary({required this.viewModel});

  final PaymentViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '결제 요약',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const StatusBadge(label: '확인 필요'),
              ],
            ),
            const SizedBox(height: 16),
            _SummaryRow(label: '주문번호', value: 'ORD-20261012-008'),
            const SizedBox(height: 10),
            const _SummaryRow(label: '결제 수단', value: '카드'),
            const SizedBox(height: 10),
            _SummaryRow(
              label: '결제 금액',
              value: formatPrice(viewModel.totalAmount),
            ),
            const SizedBox(height: 18),
            const NoticeBox(message: '결제가 완료되면 농가 확인 단계로 넘어갑니다.'),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.orderComplete,
                arguments: viewModel.orderId,
              ),
              icon: const Icon(Icons.credit_score_outlined),
              label: const Text('결제 완료하기'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
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
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}
