import 'package:flutter/material.dart';
import 'package:smart_web/yeeun/model/product_model.dart';
import 'package:smart_web/yeeun/vm/product_view_model.dart';

import '../../core/app_colors.dart';
import '../../core/responsive.dart';
import '../widgets/app_header.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late List<ProductModel> _items;
  final Map<String, int> _quantities = {'1': 2, '2': 1};
  final Set<String> _selectedIds = {'1', '2'};

  @override
  void initState() {
    super.initState();
    _items = ProductViewModel().products.take(2).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final selectedItems =
        _items.where((product) => _selectedIds.contains(product.id)).toList();
    final total = selectedItems.fold<int>(
      0,
      (sum, product) => sum + product.price * _quantityOf(product.id),
    );
    final totalCount = selectedItems.fold<int>(
      0,
      (sum, product) => sum + _quantityOf(product.id),
    );
    final allSelected = _items.isNotEmpty && _selectedIds.length == _items.length;

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(
            title: '예약함',
            icon: Icons.shopping_cart_outlined,
            showHome: true,
            actionText: '주문서 작성',
            actionRoute: '/order-form',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Responsive.maxWidth(context),
                  ),
                  child: isMobile
                      ? Column(
                          children: [
                            _CartItems(
                              products: _items,
                              quantities: _quantities,
                              selectedIds: _selectedIds,
                              allSelected: allSelected,
                              onChange: _changeQuantity,
                              onToggle: _toggleItem,
                              onToggleAll: _toggleAll,
                              onRemove: _removeItem,
                              onRemoveSelected: _removeSelected,
                            ),
                            const SizedBox(height: 18),
                            _CartSummary(
                              totalCount: totalCount,
                              total: total,
                              selectedCount: selectedItems.length,
                            ),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: _CartItems(
                                products: _items,
                                quantities: _quantities,
                                selectedIds: _selectedIds,
                                allSelected: allSelected,
                                onChange: _changeQuantity,
                                onToggle: _toggleItem,
                                onToggleAll: _toggleAll,
                                onRemove: _removeItem,
                                onRemoveSelected: _removeSelected,
                              ),
                            ),
                            const SizedBox(width: 18),
                            SizedBox(
                              width: 280,
                              child: _CartSummary(
                                totalCount: totalCount,
                                total: total,
                                selectedCount: selectedItems.length,
                              ),
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

  int _quantityOf(String productId) => _quantities[productId] ?? 1;

  void _changeQuantity(String productId, int delta) {
    setState(() {
      final current = _quantityOf(productId);
      _quantities[productId] = (current + delta).clamp(1, 9);
    });
  }

  void _toggleItem(String productId, bool? selected) {
    setState(() {
      if (selected ?? false) {
        _selectedIds.add(productId);
      } else {
        _selectedIds.remove(productId);
      }
    });
  }

  void _toggleAll(bool? selected) {
    setState(() {
      if (selected ?? false) {
        _selectedIds
          ..clear()
          ..addAll(_items.map((product) => product.id));
      } else {
        _selectedIds.clear();
      }
    });
  }

  void _removeItem(String productId) {
    setState(() {
      _items.removeWhere((product) => product.id == productId);
      _selectedIds.remove(productId);
      _quantities.remove(productId);
    });
  }

  void _removeSelected() {
    setState(() {
      _items.removeWhere((product) => _selectedIds.contains(product.id));
      for (final id in _selectedIds) {
        _quantities.remove(id);
      }
      _selectedIds.clear();
    });
  }
}

class _CartItems extends StatelessWidget {
  final List<ProductModel> products;
  final Map<String, int> quantities;
  final Set<String> selectedIds;
  final bool allSelected;
  final void Function(String productId, int delta) onChange;
  final void Function(String productId, bool? selected) onToggle;
  final ValueChanged<bool?> onToggleAll;
  final ValueChanged<String> onRemove;
  final VoidCallback onRemoveSelected;

  const _CartItems({
    required this.products,
    required this.quantities,
    required this.selectedIds,
    required this.allSelected,
    required this.onChange,
    required this.onToggle,
    required this.onToggleAll,
    required this.onRemove,
    required this.onRemoveSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '예약함',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
              ),
              TextButton.icon(
                onPressed: selectedIds.isEmpty ? null : onRemoveSelected,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('선택 삭제'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (products.isNotEmpty)
            Row(
              children: [
                Checkbox(value: allSelected, onChanged: onToggleAll),
                const Text('전체 선택', style: TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
          const SizedBox(height: 8),
          if (products.isEmpty)
            const _EmptyCart()
          else
            ...products.map(
              (product) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: selectedIds.contains(product.id),
                      onChanged: (value) => onToggle(product.id, value),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        product.imageUrl,
                        width: 72,
                        height: 58,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text('${product.harvestDate} 수확 예정'),
                        ],
                      ),
                    ),
                    _StepperBox(
                      value: quantities[product.id] ?? 1,
                      onMinus: () => onChange(product.id, -1),
                      onPlus: () => onChange(product.id, 1),
                    ),
                    IconButton(
                      tooltip: '삭제',
                      onPressed: () => onRemove(product.id),
                      icon: const Icon(Icons.close, size: 18),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final int totalCount;
  final int total;
  final int selectedCount;

  const _CartSummary({
    required this.totalCount,
    required this.total,
    required this.selectedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('예약 정보', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          _PriceLine(label: '선택 상품', value: '$selectedCount종'),
          _PriceLine(label: '상품 수량', value: '$totalCount박스'),
          const _PriceLine(label: '배송 예정', value: '10월 중순'),
          const Divider(height: 28),
          _PriceLine(label: '합계', value: '${_formatPrice(total)}원', strong: true),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  selectedCount == 0 ? null : () => Navigator.pushNamed(context, '/order-form'),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('주문서 작성'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepperBox extends StatelessWidget {
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _StepperBox({
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _smallButton(Icons.remove, onMinus),
        Container(
          width: 36,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(border: Border.all(color: AppColors.border)),
          child: Text('$value', style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
        _smallButton(Icons.add, onPlus),
      ],
    );
  }

  Widget _smallButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 14),
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  final String label;
  final String value;
  final bool strong;

  const _PriceLine({
    required this.label,
    required this.value,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              color: strong ? AppColors.primary : AppColors.text,
              fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        '예약함이 비어 있습니다. 상품 목록에서 예약할 상품을 담아 주세요.',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    border: Border.all(color: AppColors.border),
    borderRadius: BorderRadius.circular(8),
  );
}

String _formatPrice(int price) {
  return price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]},',
      );
}
