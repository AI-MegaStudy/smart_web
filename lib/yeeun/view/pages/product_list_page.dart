import 'package:flutter/material.dart';
import 'package:smart_web/yeeun/model/product_model.dart';
import 'package:smart_web/yeeun/vm/product_view_model.dart';

import '../../core/app_colors.dart';
import '../../core/responsive.dart';
import '../widgets/app_header.dart';
import '../widgets/product_card.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  String _selectedKind = '전체';
  String? _selectedPackage;
  bool _sortByStock = false;

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts(ProductViewModel().products);
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(
            title: '상품 목록',
            icon: Icons.inventory_2_outlined,
            showHome: true,
            actionText: '예약함',
            actionRoute: '/cart',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Responsive.maxWidth(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '수확 예정 상품',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '사과 품종과 수확 예정 범위를 함께 확인',
                        style: TextStyle(
                          fontSize: 29,
                          height: 1.15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        '예약 가능한 상품을 우선 표시합니다. 품종과 패키지 단위를 선택하면 목록이 즉시 필터링됩니다.',
                        style: TextStyle(fontSize: 14, height: 1.45),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _FilterChip(
                            label: '전체',
                            selected: _selectedKind == '전체',
                            onTap: () => _setKind('전체'),
                          ),
                          _FilterChip(
                            label: '후지',
                            selected: _selectedKind == '후지',
                            onTap: () => _setKind('후지'),
                          ),
                          _FilterChip(
                            label: '홍로',
                            selected: _selectedKind == '홍로',
                            onTap: () => _setKind('홍로'),
                          ),
                          _FilterChip(
                            label: '시나노골드',
                            selected: _selectedKind == '시나노골드',
                            onTap: () => _setKind('시나노골드'),
                          ),
                          ...['1kg', '3kg', '5kg', '7.5kg', '10kg'].map(
                            (label) => _FilterChip(
                              label: label,
                              selected: _selectedPackage == label,
                              onTap: () => _togglePackage(label),
                            ),
                          ),
                          _FilterChip(
                            label: '잔여 많은 순',
                            selected: _sortByStock,
                            onTap: () => setState(() => _sortByStock = !_sortByStock),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '${products.length}개 상품 표시 중',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 22),
                      if (products.isEmpty)
                        const _EmptyProducts()
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: products.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isMobile ? 1 : 3,
                            crossAxisSpacing: 18,
                            mainAxisSpacing: 18,
                            childAspectRatio: isMobile ? 1.05 : 0.68,
                          ),
                          itemBuilder: (_, index) {
                            return ProductCard(product: products[index]);
                          },
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

  List<ProductModel> _filteredProducts(List<ProductModel> source) {
    var products = source.where((product) {
      final kindMatches =
          _selectedKind == '전체' || product.name.contains(_selectedKind);
      final packageMatches =
          _selectedPackage == null || product.name.contains(_selectedPackage!);
      return kindMatches && packageMatches;
    }).toList();

    if (_sortByStock) {
      products.sort((a, b) => b.stockKg.compareTo(a.stockKg));
    }

    return products;
  }

  void _setKind(String kind) {
    setState(() {
      _selectedKind = kind;
    });
  }

  void _togglePackage(String packageLabel) {
    setState(() {
      _selectedPackage =
          _selectedPackage == packageLabel ? null : packageLabel;
    });
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xffCFEFDB) : Colors.white,
          border: Border.all(
            color: selected ? const Color(0xff9AC9A8) : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        '선택한 조건에 맞는 상품이 없습니다. 필터를 다시 선택해 주세요.',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}
