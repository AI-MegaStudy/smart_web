import 'package:flutter/material.dart';
import 'package:smart_web/yeeun/model/product_model.dart';
import 'package:smart_web/yeeun/vm/product_view_model.dart';

import '../../core/app_colors.dart';
import '../../core/responsive.dart';
import '../widgets/app_header.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)?.settings.arguments as String?;
    final product = ProductViewModel().findById(productId);
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(
            title: '상품 상세',
            icon: Icons.apple,
            showBack: true,
            actionText: '담기',
            actionRoute: '/cart',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 36),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Responsive.maxWidth(context),
                  ),
                  child: isMobile
                      ? Column(
                          children: [
                            _ProductPhoto(product: product),
                            const SizedBox(height: 18),
                            _ReservationPanel(product: product),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 11, child: _ProductPhoto(product: product)),
                            const SizedBox(width: 18),
                            Expanded(flex: 10, child: _ReservationPanel(product: product)),
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

class _ProductPhoto extends StatelessWidget {
  final ProductModel product;

  const _ProductPhoto({required this.product});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.asset(
        product.imageUrl,
        height: 705,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _ReservationPanel extends StatefulWidget {
  final ProductModel product;

  const _ReservationPanel({required this.product});

  @override
  State<_ReservationPanel> createState() => _ReservationPanelState();
}

class _ReservationPanelState extends State<_ReservationPanel> {
  final List<_PackageOptionData> _packages = const [
    _PackageOptionData(weightKg: 1, label: '1kg', subLabel: '소포장', price: 9000),
    _PackageOptionData(weightKg: 3, label: '3kg', subLabel: '가정용', price: 32000),
    _PackageOptionData(weightKg: 5, label: '5kg', subLabel: '인기', price: 39000),
    _PackageOptionData(weightKg: 7.5, label: '7.5kg', subLabel: '넉넉한 양', price: 54000),
    _PackageOptionData(weightKg: 10, label: '10kg', subLabel: '대용량', price: 78000),
  ];

  late _PackageOptionData _selectedPackage = _packages[2];
  int _selectedSlotIndex = 0;
  int _quantity = 2;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final slots = [
      _SlotData(
        title: '${product.harvestDate} 수확 예정',
        detail: '확정 300kg · 예약 70kg · 판매 45kg',
        remainKg: product.stockKg,
        progress: 0.38,
      ),
      const _SlotData(
        title: '10.19~10.25 수확 예정',
        detail: '확정 180kg · 예약 12kg',
        remainKg: 158,
        progress: 0.16,
      ),
    ];
    final selectedSlot = slots[_selectedSlotIndex];
    final totalKg = _selectedPackage.weightKg * _quantity;
    final totalPrice = _selectedPackage.price * _quantity;

    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '수확 슬롯 예약',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${product.name.split(' ').first} 사과 예약',
            style: const TextStyle(fontSize: 31, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Text(product.description),
          const SizedBox(height: 14),
          const Text('패키지 단위 선택', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _packages.map((option) {
              return _PackageOption(
                option: option,
                selected: option == _selectedPackage,
                onTap: () => setState(() => _selectedPackage = option),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          Text(
            '${_formatPrice(_selectedPackage.price)}원 / ${_selectedPackage.label} 박스',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 24),
          const Text('수확 슬롯 선택', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          ...List.generate(slots.length, (index) {
            final slot = slots[index];
            return Padding(
              padding: EdgeInsets.only(bottom: index == slots.length - 1 ? 0 : 10),
              child: _HarvestSlot(
                data: slot,
                selected: index == _selectedSlotIndex,
                onTap: () => setState(() => _selectedSlotIndex = index),
              ),
            );
          }),
          const SizedBox(height: 22),
          const Text('박스 수량 선택', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          _QuantitySelector(
            selected: _quantity,
            onChanged: (value) => setState(() => _quantity = value),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xffEEF0EB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '선택한 예약\n${_selectedPackage.label} 박스 $_quantity개, 총 ${_formatKg(totalKg)}kg\n${selectedSlot.title.replaceAll(' 수확 예정', '')} 수확분으로 담깁니다.\n예상 금액 ${_formatPrice(totalPrice)}원',
              style: const TextStyle(height: 1.7, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xffBFEAF5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '농가가 확정한 수확 예정 범위입니다. 기상과 생육 상황에 따라 일정이 조정될 수 있습니다.',
              style: TextStyle(height: 1.5),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('예약함에 담았습니다.')),
                    );
                    Navigator.pushNamed(context, '/cart');
                  },
                  child: const Text('예약함 담기'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/order-form'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('바로 주문'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }

  String _formatKg(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }
}

class _PackageOptionData {
  final double weightKg;
  final String label;
  final String subLabel;
  final int price;

  const _PackageOptionData({
    required this.weightKg,
    required this.label,
    required this.subLabel,
    required this.price,
  });
}

class _SlotData {
  final String title;
  final String detail;
  final int remainKg;
  final double progress;

  const _SlotData({
    required this.title,
    required this.detail,
    required this.remainKg,
    required this.progress,
  });
}

class _PackageOption extends StatelessWidget {
  final _PackageOptionData option;
  final bool selected;
  final VoidCallback onTap;

  const _PackageOption({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: selected ? const Color(0xffB3EFCB) : Colors.white,
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(option.label, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(option.subLabel, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _HarvestSlot extends StatelessWidget {
  final _SlotData data;
  final bool selected;
  final VoidCallback onTap;

  const _HarvestSlot({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xffDCF7E7) : Colors.white,
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data.title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                Text(data.detail, style: const TextStyle(fontSize: 11)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xffAEE9F8) : const Color(0xffFFE48A),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '잔여 ${data.remainKg}kg',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: data.progress,
                minHeight: 7,
                color: AppColors.primary,
                backgroundColor: AppColors.border,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _QuantitySelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        final value = index + 1;
        final isSelected = value == selected;
        return InkWell(
          onTap: () => onChanged(value),
          child: Container(
            width: 36,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xffCFEFDB) : Colors.white,
              border: Border.all(color: AppColors.text),
              borderRadius: BorderRadius.horizontal(
                left: index == 0 ? const Radius.circular(16) : Radius.zero,
                right: index == 4 ? const Radius.circular(16) : Radius.zero,
              ),
            ),
            child: Text(
              '$value',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        );
      }),
    );
  }
}
