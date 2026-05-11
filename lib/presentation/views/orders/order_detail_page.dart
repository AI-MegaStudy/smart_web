import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/order_status_mapper.dart';
import '../../../data/models/local_basket_item_model.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/payment_repository.dart';
import '../../../data/repositories/shipment_repository.dart';
import '../../view_models/order_detail_view_model.dart';
import '../../widgets/brand_app_bar_title.dart';
import '../../widgets/flow_status_badge.dart';
import '../../widgets/notice_box.dart';
import '../../widgets/status_badge.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key, required this.orderId});

  final int orderId;

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late final OrderDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = OrderDetailViewModel(orderId: widget.orderId)..load();
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
        actions: [
          AnimatedBuilder(
            animation: _viewModel,
            builder: (context, _) {
              return FlowStatusBadge(
                stepLabel: '배송 흐름',
                statusLabel: _viewModel.order?.orderStatusLabel ?? '상태 확인',
                icon: Icons.local_shipping_outlined,
              );
            },
          ),
        ],
      ),
      body: _ScreenBackground(
        child: AnimatedBuilder(
          animation: _viewModel,
          builder: (context, _) {
            final order = _viewModel.order;
            if (_viewModel.isLoading || order == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _ConstrainedContent(child: _PageIntro(order: order)),
                ),
                SliverToBoxAdapter(
                  child: _ConstrainedContent(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 980;
                          final progress = Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _ProgressPanel(
                                order: order,
                                shipment: _viewModel.shipment,
                              ),
                              const SizedBox(height: 18),
                              _PaymentInfoPanel(
                                payments: _viewModel.payments,
                                errorMessage: _viewModel.paymentErrorMessage,
                              ),
                            ],
                          );
                          final summary = _OrderSummary(
                            order: order,
                            shipment: _viewModel.shipment,
                          );

                          if (!isWide) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                progress,
                                const SizedBox(height: 18),
                                summary,
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 6, child: progress),
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
  const _PageIntro({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '주문 진행 상태',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            order.orderNumber,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF163B2B),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusBadge(label: order.orderStatusLabel),
              const StatusBadge(label: '수확 직배송'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressPanel extends StatelessWidget {
  const _ProgressPanel({required this.order, required this.shipment});

  final OrderModel order;
  final ShipmentInfo? shipment;

  @override
  Widget build(BuildContext context) {
    final statusCode = order.orderStatusCode;
    final returnStatusCode = order.returnStatusCode;
    final paidTimeLabel = _dateTimeLabel(order.paidAt ?? order.orderedAt);
    final isPaymentPending = statusCode == OrderStatusMapper.paymentPending;
    final isProcurementRequested =
        statusCode == OrderStatusMapper.procurementRequested;
    final isProcurementApproved =
        statusCode == OrderStatusMapper.procurementApproved;
    final isProcurementPartialApproved =
        statusCode == OrderStatusMapper.procurementPartialApproved;
    final isProcurementRejected =
        statusCode == OrderStatusMapper.procurementRejected;
    final isQualityChecking = statusCode == OrderStatusMapper.qualityChecking;
    final isReadyToShip = statusCode == OrderStatusMapper.readyToShip;
    final isShipmentDelivered = shipment?.shipmentStatusLabel == '배송 완료';
    final isShipmentShipped = shipment?.shipmentStatusLabel == '배송 중';
    final isReturnRejected =
        returnStatusCode == OrderStatusMapper.returnRequestRejected;
    final isReturnApproved =
        returnStatusCode == OrderStatusMapper.returnRequestApproved;
    final isReturnRequested =
        statusCode == OrderStatusMapper.returnRequested &&
        !isReturnRejected &&
        !isReturnApproved;
    final isRefunded =
        statusCode == OrderStatusMapper.refunded ||
        returnStatusCode == OrderStatusMapper.refunded;
    final isReturnFlow =
        isReturnRequested || isReturnApproved || isReturnRejected || isRefunded;
    final isDelivered =
        statusCode == OrderStatusMapper.delivered ||
        isShipmentDelivered ||
        isReturnFlow;
    final isShipped =
        statusCode == OrderStatusMapper.shipped ||
        isDelivered ||
        isShipmentShipped;
    final isPaid = !isPaymentPending;
    final farmStep = _farmStep(
      isProcurementRequested: isProcurementRequested,
      isProcurementApproved: isProcurementApproved,
      isProcurementPartialApproved: isProcurementPartialApproved,
      isProcurementRejected: isProcurementRejected,
      isQualityChecking: isQualityChecking,
      isReadyToShip: isReadyToShip,
      isShipped: isShipped,
    );
    final trackingDescription = shipment?.hasTrackingInfo == true
        ? '${shipment!.carrierName} ${shipment!.trackingNumber}로 배송 중입니다.'
        : '배송이 시작되면 운송장 정보가 표시됩니다.';

    final steps = [
      _ProgressStepData(
        label: isPaymentPending ? '결제 대기' : '결제 완료',
        description: isPaymentPending
            ? '결제 완료 후 농가 확인이 시작됩니다.'
            : '결제가 완료되었습니다.',
        time: isPaymentPending ? '현재' : paidTimeLabel,
        completed: isPaid,
        current: isPaymentPending || statusCode == OrderStatusMapper.paid,
        icon: isPaymentPending ? Icons.credit_card_outlined : Icons.check,
      ),
      _ProgressStepData(
        label: farmStep.label,
        description: farmStep.description,
        time: farmStep.current ? '현재' : (farmStep.completed ? '완료' : '예정'),
        completed: farmStep.completed,
        current: farmStep.current,
        icon: farmStep.icon,
      ),
      if (!isProcurementRejected) ...[
        _ProgressStepData(
          label: isReadyToShip ? '발송 준비' : '배송 중',
          description: isReadyToShip
              ? '농가가 발송 준비를 진행하고 있습니다.'
              : trackingDescription,
          time: isShipped ? _dateTimeLabel(shipment?.shippedAt) : '예정',
          completed: isShipped || isReadyToShip,
          current:
              isReadyToShip ||
              statusCode == OrderStatusMapper.shipped ||
              isShipmentShipped,
          icon: isReadyToShip
              ? Icons.inventory_2_outlined
              : Icons.local_shipping_outlined,
        ),
        _ProgressStepData(
          label: '배송 완료',
          description: '배송 완료 후 조건에 따라 반품 신청이 가능합니다.',
          time: isDelivered || isShipmentDelivered
              ? _dateTimeLabel(shipment?.deliveredAt)
              : '예정',
          completed: isDelivered || isShipmentDelivered,
          current:
              (statusCode == OrderStatusMapper.delivered ||
                  isShipmentDelivered) &&
              !isReturnFlow,
          icon: Icons.check,
        ),
      ],
      if (isReturnFlow)
        _ProgressStepData(
          label: isRefunded
              ? '환불 완료'
              : isReturnRejected
              ? '반품 반려'
              : isReturnApproved
              ? '반품 승인'
              : '반품 요청 접수',
          description: isRefunded
              ? '반품 확인 후 환불이 완료되었습니다.'
              : isReturnRejected
              ? '반품 요청이 반려되었습니다. 자세한 사유는 반품 내역에서 확인할 수 있습니다.'
              : isReturnApproved
              ? '반품 요청이 승인되어 환불 처리를 준비하고 있습니다.'
              : '반품 요청이 접수되어 농가 확인을 기다리고 있습니다.',
          time: isRefunded || isReturnApproved || isReturnRejected
              ? '완료'
              : '현재',
          completed: true,
          current: isReturnRequested || isReturnApproved,
          icon: isReturnRejected
              ? Icons.block_outlined
              : Icons.assignment_return_outlined,
        ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE3DD)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '진행 현황',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            for (var index = 0; index < steps.length; index += 1) ...[
              _ProgressStep(step: steps[index]),
              if (index != steps.length - 1)
                const Divider(height: 28, color: Color(0xFFDCE3DD)),
            ],
          ],
        ),
      ),
    );
  }

  String _dateTimeLabel(DateTime? value) {
    if (value == null) {
      return '확인 중';
    }
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$month.$day $hour:$minute';
  }

  _ProgressStepData _farmStep({
    required bool isProcurementRequested,
    required bool isProcurementApproved,
    required bool isProcurementPartialApproved,
    required bool isProcurementRejected,
    required bool isQualityChecking,
    required bool isReadyToShip,
    required bool isShipped,
  }) {
    if (isProcurementRejected) {
      return const _ProgressStepData(
        label: '농가 승인 불가',
        description: '농가가 수확 가능 수량을 확보하지 못했습니다. 취소 또는 재주문 안내가 필요할 수 있습니다.',
        time: '현재',
        completed: true,
        current: true,
        icon: Icons.block_outlined,
      );
    }
    if (isProcurementPartialApproved) {
      return const _ProgressStepData(
        label: '일부 수량 확인 필요',
        description: '농가가 일부 수량만 가능하다고 확인했습니다. 주문 조정 안내가 필요할 수 있습니다.',
        time: '현재',
        completed: true,
        current: true,
        icon: Icons.info_outline,
      );
    }
    if (isQualityChecking) {
      return const _ProgressStepData(
        label: '선별 중',
        description: '수확한 상품을 선별하고 있습니다.',
        time: '현재',
        completed: true,
        current: true,
        icon: Icons.fact_check_outlined,
      );
    }
    if (isReadyToShip || isShipped) {
      return const _ProgressStepData(
        label: '농가 승인 완료',
        description: '농가가 주문 수량을 확인하고 발송 준비 단계로 넘겼습니다.',
        time: '완료',
        completed: true,
        current: false,
        icon: Icons.check,
      );
    }
    if (isProcurementApproved) {
      return const _ProgressStepData(
        label: '농가 승인 완료',
        description: '농가가 주문 수량을 확인했습니다.',
        time: '현재',
        completed: true,
        current: true,
        icon: Icons.check,
      );
    }
    return _ProgressStepData(
      label: '농가 확인 중',
      description: '농가가 수확 가능 수량을 확인하고 있습니다.',
      time: isProcurementRequested ? '현재' : '예정',
      completed: isProcurementRequested,
      current: isProcurementRequested,
      icon: isProcurementRequested ? Icons.hourglass_top : Icons.check,
    );
  }
}

class _ProgressStepData {
  const _ProgressStepData({
    required this.label,
    required this.description,
    required this.time,
    required this.completed,
    required this.current,
    required this.icon,
  });

  final String label;
  final String description;
  final String time;
  final bool completed;
  final bool current;
  final IconData icon;
}

class _ProgressStep extends StatelessWidget {
  const _ProgressStep({required this.step});

  final _ProgressStepData step;

  @override
  Widget build(BuildContext context) {
    final color = step.completed
        ? Theme.of(context).colorScheme.primary
        : const Color(0xFFB8C2B8);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: step.completed
              ? Icon(step.icon, color: Colors.white, size: 17)
              : null,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF101813),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                step.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF4B584D),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          step.current ? '현재' : step.time,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF101813),
          ),
        ),
      ],
    );
  }
}

class _PaymentInfoPanel extends StatelessWidget {
  const _PaymentInfoPanel({required this.payments, required this.errorMessage});

  final List<PaymentHistoryItem> payments;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE3DD)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '결제 정보',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            if (errorMessage != null)
              NoticeBox(icon: Icons.info_outline, message: errorMessage!)
            else if (payments.isEmpty)
              const NoticeBox(
                icon: Icons.info_outline,
                message: '결제 대기 상태입니다. 결제가 완료되면 결제 정보가 표시됩니다.',
              )
            else
              for (final payment in payments) ...[
                _PaymentInfoRow(payment: payment),
                if (payment != payments.last)
                  const Divider(height: 26, color: Color(0xFFDCE3DD)),
              ],
          ],
        ),
      ),
    );
  }
}

class _PaymentInfoRow extends StatelessWidget {
  const _PaymentInfoRow({required this.payment});

  final PaymentHistoryItem payment;

  @override
  Widget build(BuildContext context) {
    final isPaymentPending = payment.paymentStatusLabel == '결제 대기';
    final displayAmount = isPaymentPending
        ? payment.requestedAmount
        : payment.approvedAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFE5F2E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.credit_card_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 19,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payment.paymentMethodLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF101813),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    payment.paymentStatusLabel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF657166),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              formatPrice(displayAmount),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        if (isPaymentPending) ...[
          const SizedBox(height: 14),
          _SummaryRow(
            label: '결제 예정 금액',
            value: formatPrice(payment.requestedAmount),
          ),
        ] else if (payment.requestedAmount != payment.approvedAmount) ...[
          const SizedBox(height: 14),
          _SummaryRow(
            label: '요청 금액',
            value: formatPrice(payment.requestedAmount),
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: '결제 금액',
            value: formatPrice(payment.approvedAmount),
          ),
        ],
        if (payment.approvedAt != null) ...[
          const SizedBox(height: 8),
          _SummaryRow(
            label: '결제 일시',
            value: _dateTimeLabel(payment.approvedAt),
          ),
        ],
      ],
    );
  }

  String _dateTimeLabel(DateTime? value) {
    if (value == null) {
      return '확인 중';
    }
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$month.$day $hour:$minute';
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.order, required this.shipment});

  final OrderModel order;
  final ShipmentInfo? shipment;

  @override
  Widget build(BuildContext context) {
    final canReturn = order.orderStatusLabel == '배송 완료';
    final hasShipmentInfo = shipment?.hasTrackingInfo == true;
    final carrierDisplay = hasShipmentInfo ? shipment!.carrierName : '배송 준비 중';
    final trackingDisplay = hasShipmentInfo
        ? shipment!.trackingNumber
        : '운송장번호 준비 중';
    final shipmentStatusDisplay = shipment?.shipmentStatusLabel ?? '배송 준비 중';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE3DD)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '주문 요약',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            for (final item in order.items) ...[
              _OrderItem(item: item),
              const SizedBox(height: 12),
            ],
            const Divider(height: 28),
            _SummaryRow(label: '받는 분', value: order.receiverName),
            if (order.receiverPhone.isNotEmpty) ...[
              const SizedBox(height: 10),
              _SummaryRow(label: '연락처', value: order.receiverPhone),
            ],
            const SizedBox(height: 10),
            _SummaryRow(label: '배송지', value: order.shippingAddress),
            if (order.deliveryMemo.isNotEmpty) ...[
              const SizedBox(height: 10),
              _SummaryRow(label: '배송 요청사항', value: order.deliveryMemo),
            ],
            const SizedBox(height: 10),
            _SummaryRow(label: '결제 금액', value: formatPrice(order.totalAmount)),
            const SizedBox(height: 10),
            _SummaryRow(
              label: '총 중량',
              value: '${formatKg(order.totalReservedKg)}kg',
            ),
            const SizedBox(height: 10),
            _SummaryRow(label: '배송 상태', value: shipmentStatusDisplay),
            const SizedBox(height: 10),
            _SummaryRow(label: '택배사', value: carrierDisplay),
            const SizedBox(height: 10),
            _SummaryRow(label: '운송장번호', value: trackingDisplay),
            const SizedBox(height: 18),
            const NoticeBox(message: '수확 일정은 기상과 생육 상황에 따라 조정될 수 있습니다.'),
            const SizedBox(height: 18),
            if (canReturn)
              OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.returnRequest,
                  arguments: order.orderId,
                ),
                icon: const Icon(Icons.assignment_return_outlined),
                label: const Text('반품 신청'),
              )
            else
              const NoticeBox(
                icon: Icons.info_outline,
                message: '반품 신청은 배송 완료 후 조건에 따라 가능합니다.',
              ),
          ],
        ),
      ),
    );
  }
}

class _OrderItem extends StatelessWidget {
  const _OrderItem({required this.item});

  final LocalBasketItemModel item;

  @override
  Widget build(BuildContext context) {
    final chips = [
      if (item.harvestStartLabel.isNotEmpty || item.harvestEndLabel.isNotEmpty)
        '${item.harvestStartLabel}-${item.harvestEndLabel}',
      '${item.packageCount}박스',
      '${formatKg(item.reservedKg)}kg',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.productName,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [for (final chip in chips) _OrderItemChip(label: chip)],
        ),
      ],
    );
  }
}

class _OrderItemChip extends StatelessWidget {
  const _OrderItemChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFEFF5F0),
        border: Border.all(color: const Color(0xFFD4E1D8)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: const Color(0xFF24533C),
            fontWeight: FontWeight.w900,
          ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 82,
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF657166)),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}
