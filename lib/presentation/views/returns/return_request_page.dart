import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/local_basket_item_model.dart';
import '../../view_models/return_request_view_model.dart';
import '../../widgets/brand_app_bar_title.dart';

class ReturnRequestPage extends StatefulWidget {
  const ReturnRequestPage({super.key, required this.orderId});

  final int orderId;

  @override
  State<ReturnRequestPage> createState() => _ReturnRequestPageState();
}

class _ReturnRequestPageState extends State<ReturnRequestPage> {
  late final ReturnRequestViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ReturnRequestViewModel(orderId: widget.orderId)..load();
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
            final order = _viewModel.order;
            if (_viewModel.isLoading || order == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _ConstrainedContent(
                    child: _PageIntro(orderNumber: order.orderNumber),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _ConstrainedContent(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 44),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 980;
                          final form = _ReturnForm(viewModel: _viewModel);
                          final summary = _ReturnSummary(viewModel: _viewModel);

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
  const _PageIntro({required this.orderNumber});

  final String orderNumber;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '반품 사유와 증빙 등록',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '배송 완료된 주문의 반품을 신청합니다',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF163B2B),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$orderNumber 주문에서 문제가 있었던 상품과 사유를 남겨주세요. 사진을 함께 등록하면 확인이 더 빠릅니다.',
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

class _ReturnForm extends StatelessWidget {
  const _ReturnForm({required this.viewModel});

  final ReturnRequestViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final order = viewModel.order;
    final item = order?.items.isNotEmpty == true ? order!.items.first : null;

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '반품할 상품 선택',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF17241C),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '배송 완료된 주문 안에서 반품할 상품을 선택할 수 있습니다.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF667267),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          if (item != null)
            _ReturnOrderItem(orderNumber: order!.orderNumber, item: item),
          const SizedBox(height: 24),
          Text(
            '반품 사유 선택',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF17241C),
            ),
          ),
          const SizedBox(height: 12),
          _ReasonChoiceGrid(viewModel: viewModel),
          const SizedBox(height: 22),
          TextFormField(
            initialValue: viewModel.reasonDetail,
            maxLines: 4,
            onChanged: viewModel.updateReasonDetail,
            decoration: InputDecoration(
              labelText: '상세 사유',
              hintText: '상품 상태와 문제가 있었던 부분을 구체적으로 적어주세요.',
              alignLabelWithHint: true,
              filled: true,
              fillColor: const Color(0xFFF9FAF6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const _UploadBox(),
          const SizedBox(height: 22),
          const Divider(height: 1),
          const SizedBox(height: 18),
          Text(
            '요청 금액 선택',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF17241C),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _AmountOption(
                label: '전체 ${formatPrice(order?.totalAmount ?? 0)}',
                selected: true,
              ),
              _AmountOption(
                label: '부분 ${formatPrice(viewModel.requestAmount)}',
              ),
              const _AmountOption(label: '확인 후 결정'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE3DD)),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F102016),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(22), child: child),
    );
  }
}

class _ReturnOrderItem extends StatelessWidget {
  const _ReturnOrderItem({required this.orderNumber, required this.item});

  final String orderNumber;
  final LocalBasketItemModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBF7),
        border: Border.all(color: const Color(0xFFE2E7DE)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              'https://images.unsplash.com/photo-1570913149827-d2ac84ab3f9a?auto=format&fit=crop&w=300&q=80',
              width: 88,
              height: 72,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _MetaChip(label: orderNumber),
                    _MetaChip(label: item.farmName),
                    _MetaChip(label: '${item.packageCount}박스'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const _SelectedChip(),
        ],
      ),
    );
  }
}

class _ReasonChoiceGrid extends StatelessWidget {
  const _ReasonChoiceGrid({required this.viewModel});

  final ReturnRequestViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    const descriptions = {
      '상품 파손': '박스나 상품이 손상됨',
      '상품 변질': '신선도나 상태 이상',
      '오배송': '다른 상품이 도착함',
      '기타': '직접 사유를 입력',
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 620;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isNarrow ? 1 : 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: isNarrow ? 4.8 : 3.2,
          children: [
            for (final label in viewModel.reasonLabels)
              _ReasonChoiceCard(
                title: label,
                description: descriptions[label] ?? '',
                selected: viewModel.selectedReasonLabel == label,
                onTap: () => viewModel.selectReason(label),
              ),
          ],
        );
      },
    );
  }
}

class _ReasonChoiceCard extends StatelessWidget {
  const _ReasonChoiceCard({
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE7F2E8) : const Color(0xFFF9FAF6),
          border: Border.all(
            color: selected ? const Color(0xFF22764D) : const Color(0xFFE2E7DE),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: selected
                  ? const Color(0xFF22764D)
                  : const Color(0xFFADB8AC),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF647065),
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

class _UploadBox extends StatelessWidget {
  const _UploadBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFC9D5C8), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFE2EFE4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_photo_alternate_outlined,
              color: Color(0xFF0F6A3E),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '증빙 이미지 선택',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '상품 상태를 확인할 수 있는 사진을 첨부해주세요.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF657166),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.upload_file),
            label: const Text('사진 첨부'),
          ),
        ],
      ),
    );
  }
}

class _AmountOption extends StatelessWidget {
  const _AmountOption({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF22764D) : Colors.white,
        border: Border.all(
          color: selected ? const Color(0xFF22764D) : const Color(0xFFD4DCD2),
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: selected ? Colors.white : const Color(0xFF29362D),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _ReturnSummary extends StatelessWidget {
  const _ReturnSummary({required this.viewModel});

  final ReturnRequestViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final order = viewModel.order;
    if (order == null) {
      return const SizedBox.shrink();
    }

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '반품 요청 요약',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 18),
          _SummaryRow(label: '주문 상태', value: '배송 완료'),
          const SizedBox(height: 12),
          _SummaryRow(label: '반품 사유', value: viewModel.selectedReasonLabel),
          const SizedBox(height: 12),
          _SummaryRow(
            label: '요청 금액',
            value: formatPrice(viewModel.requestAmount),
          ),
          const SizedBox(height: 12),
          const _SummaryRow(label: '증빙 이미지', value: '선택 전'),
          const SizedBox(height: 18),
          _SummaryCard(detail: viewModel.reasonDetail),
          const SizedBox(height: 16),
          const _ReturnNotice(),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.maybePop(context),
                  child: const Text('취소'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.returnComplete,
                    (route) => route.settings.name == AppRoutes.home,
                    arguments: order.orderId,
                  ),
                  icon: const Icon(Icons.assignment_return_outlined),
                  label: const Text('반품 요청'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.detail});

  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E7DE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '접수 내용',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            detail.isEmpty ? '상세 사유를 입력하면 이곳에 표시됩니다.' : detail,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF4D5A50),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '농가 확인 후 환불 가능 금액을 안내해드립니다.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF4D5A50),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReturnNotice extends StatelessWidget {
  const _ReturnNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0EA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFD3C2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFB84626), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '등록 후 반품 접수 상태로 변경됩니다. 상품 상태 확인이 끝나면 환불 가능 금액을 안내합니다.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF7B2F18),
                height: 1.45,
              ),
            ),
          ),
        ],
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

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFEFF5EE),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: const Color(0xFF31513C),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _SelectedChip extends StatelessWidget {
  const _SelectedChip();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFE2EFE4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          '선택됨',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: const Color(0xFF0F6A3E),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
