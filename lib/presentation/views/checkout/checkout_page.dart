import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../core/utils/formatters.dart';
import '../../view_models/checkout_view_model.dart';
import '../../widgets/app_alert_dialog.dart';
import '../../widgets/brand_app_bar_title.dart';
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
              '기본 배송지를 사용할 수 있고, 이번 주문에 필요한 정보는 직접 수정할 수 있습니다.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF5F6C62)),
            ),
            const SizedBox(height: 16),
            _DefaultAddressSwitch(viewModel: viewModel),
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
                    onPressed: () => showAppAlertDialog(
                      context,
                      message: '카카오 주소 API 연동은 추후 배송지 관리 기능과 함께 연결할 예정입니다.',
                    ),
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
}

class _DefaultAddressSwitch extends StatelessWidget {
  const _DefaultAddressSwitch({required this.viewModel});

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
        child: Row(
          children: [
            Checkbox(
              value: viewModel.useDefaultAddress,
              onChanged: (value) {
                viewModel.updateUseDefaultAddress(value ?? false);
              },
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '기본 배송지 사용',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF163B2B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${viewModel.defaultReceiverName} · ${viewModel.defaultReceiverPhone} · ${viewModel.defaultShippingAddress}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5F6C62),
                    ),
                  ),
                ],
              ),
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
              onPressed: () {
                if (!viewModel.canSubmit) {
                  showAppAlertDialog(
                    context,
                    message: '받는 분, 연락처, 배송지를 모두 입력해주세요.',
                  );
                  return;
                }

                Navigator.pushNamed(context, AppRoutes.payment, arguments: 8);
              },
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
    this.maxLines = 1,
  });

  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
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
