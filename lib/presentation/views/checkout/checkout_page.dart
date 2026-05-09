import 'package:flutter/material.dart';
import 'package:kpostal_plus/kpostal_plus.dart';

import '../../../app/router.dart';
import '../../../core/utils/formatters.dart';
import '../../view_models/checkout_view_model.dart';
import '../../widgets/app_alert_dialog.dart';
import '../../widgets/brand_app_bar_title.dart';
import '../../widgets/empty_state_panel.dart';
import '../../widgets/flow_status_badge.dart';
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
        actions: const [
          FlowStatusBadge(
            stepLabel: '예약 흐름 3/5',
            statusLabel: '주문서 작성',
            icon: Icons.edit_note_outlined,
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

            if (_viewModel.items.isEmpty) {
              return Center(
                child: _ConstrainedContent(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: EmptyStatePanel(
                      icon: Icons.receipt_long_outlined,
                      title: '작성할 주문서가 없습니다',
                      message: '예약 확인을 마친 상품이 있을 때 배송 정보와 결제 전 확인을 진행할 수 있습니다.',
                      actionLabel: '예약함으로 이동',
                      onAction: () =>
                          Navigator.pushNamed(context, AppRoutes.basket),
                    ),
                  ),
                ),
              );
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
            '배송 정보와 결제 전 확인',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '받는 분과 배송지를 입력해주세요',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF163B2B),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '주문에 사용할 수령인, 연락처, 주소를 확인한 뒤 결제 단계로 이동하세요.',
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
              '배송 정보 입력',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              '저장된 배송지를 선택하거나 이번 주문에 필요한 정보만 직접 수정할 수 있습니다.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF5F6C62)),
            ),
            const SizedBox(height: 16),
            _AddressChoiceSection(viewModel: viewModel),
            const SizedBox(height: 18),
            _TextInput(
              label: '받는 분',
              initialValue: viewModel.receiverName,
              onChanged: viewModel.updateReceiverName,
            ),
            const SizedBox(height: 14),
            _TextInput(
              label: '연락처',
              initialValue: viewModel.receiverPhone,
              onChanged: viewModel.updateReceiverPhone,
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _TextInput(
                    label: '주소',
                    initialValue: viewModel.shippingAddress,
                    onChanged: viewModel.updateShippingAddress,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: OutlinedButton.icon(
                    onPressed: () => _searchAddress(context),
                    icon: const Icon(Icons.search),
                    label: const Text('주소 검색'),
                  ),
                ),
              ],
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
            const SizedBox(height: 16),
            const NoticeBox(message: '예약한 수확 상품은 결제 전까지만 주문서에서 수정할 수 있습니다.'),
          ],
        ),
      ),
    );
  }

  Future<void> _searchAddress(BuildContext context) async {
    final result = await Navigator.push<Kpostal>(
      context,
      MaterialPageRoute(
        builder: (_) => KpostalPlusView(
          title: '주소 찾기',
          appBarColor: Theme.of(context).colorScheme.primary,
          titleColor: Colors.white,
          loadingColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );

    if (result == null) {
      return;
    }

    final selectedAddress = result.userSelectedAddress.isNotEmpty
        ? result.userSelectedAddress
        : result.address;
    final formattedAddress = result.postCode.isEmpty
        ? selectedAddress
        : '(${result.postCode}) $selectedAddress';

    viewModel.updateShippingAddress(formattedAddress);
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
              onPressed: viewModel.isSubmitting
                  ? null
                  : () async {
                      if (!viewModel.canSubmit) {
                        await showAppAlertDialog(
                          context,
                          message: '받는 분, 연락처, 배송지를 모두 입력해주세요.',
                        );
                        return;
                      }

                      final orderId = await viewModel.createOrder();
                      if (!context.mounted) return;

                      if (orderId == null) {
                        await showAppAlertDialog(
                          context,
                          message:
                              viewModel.errorMessage ??
                              '주문 생성에 실패했습니다. 예약 상태를 다시 확인해주세요.',
                        );
                        return;
                      }

                      Navigator.pushNamed(
                        context,
                        AppRoutes.payment,
                        arguments: orderId,
                      );
                    },
              icon: Icon(
                viewModel.isSubmitting
                    ? Icons.hourglass_empty
                    : Icons.receipt_long_outlined,
              ),
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
            if (viewModel.selectedAddress.label.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('배송지: ${viewModel.selectedAddress.label}'),
            ],
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
    this.maxLines = 1,
  });

  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey('$label-$initialValue'),
      initialValue: initialValue,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _AddressChoiceSection extends StatelessWidget {
  const _AddressChoiceSection({required this.viewModel});

  final CheckoutViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '배송지 선택',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.addressAdd),
              child: const Text('배송지 추가'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 640;
            final cards = [
              for (final address in viewModel.addressOptions)
                _AddressChoiceCard(
                  address: address,
                  selected: viewModel.selectedAddressId == address.id,
                  onTap: () => viewModel.selectAddress(address.id),
                ),
            ];

            if (!isWide) {
              return Column(
                children: [
                  for (var index = 0; index < cards.length; index += 1) ...[
                    cards[index],
                    if (index != cards.length - 1) const SizedBox(height: 10),
                  ],
                ],
              );
            }

            return Row(
              children: [
                for (var index = 0; index < cards.length; index += 1) ...[
                  Expanded(child: cards[index]),
                  if (index != cards.length - 1) const SizedBox(width: 10),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _AddressChoiceCard extends StatelessWidget {
  const _AddressChoiceCard({
    required this.address,
    required this.selected,
    required this.onTap,
  });

  final CheckoutAddressOption address;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE7F3EB) : const Color(0xFFF7F8F3),
            border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : const Color(0xFFDCE3DD),
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
                    Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        address.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (address.isDefault) const _SmallAddressBadge('기본 배송지'),
                    if (address.isRecent) const _SmallAddressBadge('최근 사용'),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '${address.receiverName} · ${address.receiverPhone}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  address.address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF5F6C62),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SmallAddressBadge extends StatelessWidget {
  const _SmallAddressBadge(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFDCE3DD)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
