import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../core/utils/formatters.dart';
import '../../view_models/checkout_view_model.dart';
import '../../widgets/brand_app_bar_title.dart';
import '../../widgets/notice_box.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key, required this.reservationId});

  final int reservationId;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late final CheckoutViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CheckoutViewModel(reservationId: widget.reservationId)..load();
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
                          final form = _ShippingForm(viewModel: _viewModel);
                          final summary = _CheckoutSummary(
                            viewModel: _viewModel,
                          );

                          if (!isWide) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                form,
                                const SizedBox(height: 18),
                                summary,
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 6, child: form),
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

  final CheckoutViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '배송지와 결제 전 확인',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '기본 배송지로 예약을 주문 전환',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF163B2B),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '저장된 배송지를 선택하고 필요한 부분만 수정한 뒤 결제 단계로 이동하세요.',
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

class _ShippingForm extends StatelessWidget {
  const _ShippingForm({required this.viewModel});

  final CheckoutViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '배송 프로필 선택',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              '저장된 기본 배송지를 우선 사용합니다.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF5F6C62)),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 620;
                final children = [
                  _AddressChoiceCard(
                    title: '기본 배송지',
                    name: viewModel.receiverName,
                    phone: viewModel.receiverPhone,
                    address: viewModel.shippingAddress,
                    selected: true,
                  ),
                  const _AddressChoiceCard(
                    title: '회사 배송지',
                    name: '홍길동',
                    phone: '010-1111-2222',
                    address: '서울시 서초구 반포대로 45',
                    selected: false,
                  ),
                ];

                if (!isWide) {
                  return Column(
                    children: [
                      for (final child in children) ...[
                        child,
                        const SizedBox(height: 10),
                      ],
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: children[0]),
                    const SizedBox(width: 12),
                    Expanded(child: children[1]),
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            Text(
              '배송 메모 선택',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: viewModel.deliveryMemo,
              items: const [
                DropdownMenuItem(
                  value: '문 앞에 놓아주세요',
                  child: Text('문 앞에 놓아주세요'),
                ),
                DropdownMenuItem(
                  value: '경비실에 맡겨주세요',
                  child: Text('경비실에 맡겨주세요'),
                ),
                DropdownMenuItem(
                  value: '배송 전 연락주세요',
                  child: Text('배송 전 연락주세요'),
                ),
                DropdownMenuItem(value: '직접 입력', child: Text('직접 입력')),
              ],
              onChanged: (value) {
                if (value != null) {
                  viewModel.updateDeliveryMemo(value);
                }
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 18),
            Text(
              '필요 시 수정',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            _TextInput(
              label: '수령인 변경',
              initialValue: '',
              hintText: viewModel.receiverName,
              onChanged: viewModel.updateReceiverName,
            ),
            const SizedBox(height: 14),
            _TextInput(
              label: '전화번호 변경',
              initialValue: '',
              hintText: viewModel.receiverPhone,
              onChanged: viewModel.updateReceiverPhone,
            ),
            const SizedBox(height: 14),
            _TextInput(
              label: '상세 주소 변경',
              initialValue: '',
              hintText: viewModel.shippingAddress,
              onChanged: viewModel.updateShippingAddress,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            const NoticeBox(message: '예약한 수확 상품은 결제 전까지만 주문서에서 수정할 수 있습니다.'),
          ],
        ),
      ),
    );
  }
}

class _AddressChoiceCard extends StatelessWidget {
  const _AddressChoiceCard({
    required this.title,
    required this.name,
    required this.phone,
    required this.address,
    required this.selected,
  });

  final String title;
  final String name;
  final String phone;
  final String address;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFE7F3EB) : Colors.white,
        border: Border.all(
          color: selected ? const Color(0xFF2F6B4E) : const Color(0xFFDCE3DD),
          width: selected ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF163B2B),
                    ),
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text('$name · $phone'),
            const SizedBox(height: 6),
            Text(
              address,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF5F6C62)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutSummary extends StatelessWidget {
  const _CheckoutSummary({required this.viewModel});

  final CheckoutViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '예약 RES-20261012-${viewModel.reservationId.toString().padLeft(3, '0')}',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            _SummaryRow(label: '상품', value: '사과 ${viewModel.items.length}종'),
            const SizedBox(height: 10),
            const _SummaryRow(label: '배송비', value: '무료'),
            const SizedBox(height: 10),
            _SummaryRow(
              label: '총 수량',
              value: '${formatKg(viewModel.totalReservedKg)}kg',
            ),
            const Divider(height: 28),
            _TotalRow(
              label: '주문 금액',
              value: formatPrice(viewModel.totalAmount),
            ),
            const SizedBox(height: 18),
            _DeliverySummary(viewModel: viewModel),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: viewModel.canSubmit
                  ? () => Navigator.pushNamed(
                      context,
                      AppRoutes.payment,
                      arguments: 8,
                    )
                  : null,
              icon: const Icon(Icons.receipt_long_outlined),
              label: const Text('결제 화면으로 이동'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliverySummary extends StatelessWidget {
  const _DeliverySummary({required this.viewModel});

  final CheckoutViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F3),
        border: Border.all(color: const Color(0xFFDCE3DD)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '배송 정보',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text('${viewModel.receiverName} · ${viewModel.receiverPhone}'),
            const SizedBox(height: 4),
            Text(viewModel.shippingAddress),
            const SizedBox(height: 4),
            Text(viewModel.deliveryMemo),
          ],
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFF163B2B),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF163B2B),
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
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

class _TextInput extends StatelessWidget {
  const _TextInput({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.hintText,
    this.maxLines = 1,
  });

  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
