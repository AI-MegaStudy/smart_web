/*import 'package:flutter/material.dart';

import 'utils/app_colors.dart';
import 'view_models/order_detail/order_detail_view_model.dart';
import 'view_models/product_detail/product_detail_view_model.dart';
import 'view_models/product_list/product_list_view_model.dart';
import 'views/pages/order_detail/order_detail_page.dart';
import 'views/pages/product_detail/product_detail_page.dart';
import 'views/pages/product_list/product_list_page.dart';
import 'views/widgets/app_shell/info_placeholder_page.dart';
import 'views/widgets/app_shell/smart_header.dart';
import 'views/widgets/app_shell/smart_page.dart';

void main() {
  runApp(const HarvestSlotApp());
}

class HarvestSlotApp extends StatelessWidget {
  const HarvestSlotApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      surface: Colors.white,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Harvest Slot',
      theme: ThemeData(
        colorScheme: scheme,
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 44,
            height: 1.1,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          headlineLarge: TextStyle(
            fontSize: 30,
            height: 1.2,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          headlineMedium: TextStyle(
            fontSize: 22,
            height: 1.25,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            height: 1.55,
            color: AppColors.textSecondary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: AppColors.textHint,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: const BorderSide(color: AppColors.line),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
      home: const SmartWebDesignShell(),
    );
  }
}

class SmartWebDesignShell extends StatefulWidget {
  const SmartWebDesignShell({super.key});

  @override
  State<SmartWebDesignShell> createState() => _SmartWebDesignShellState();
}

class _SmartWebDesignShellState extends State<SmartWebDesignShell> {
  SmartPage _currentPage = SmartPage.products;

  final ProductListViewModel _productListViewModel = ProductListViewModel.sample();
  ProductDetailViewModel _productDetailViewModel = ProductDetailViewModel.sample();
  final OrderDetailViewModel _orderDetailViewModel = OrderDetailViewModel.sample();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SmartHeader(
            currentPage: _currentPage,
            onSelectPage: (page) {
              setState(() {
                _currentPage = page;
              });
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 28, 32, 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1320),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: switch (_currentPage) {
                      SmartPage.products => ProductListPage(
                          key: const ValueKey('products'),
                          products: _productListViewModel.products,
                          onOpenDetail: () {
                            setState(() {
                              _currentPage = SmartPage.home;
                            });
                          },
                        ),
                      SmartPage.home => ProductDetailPage(
                          key: const ValueKey('detail'),
                          slots: _productDetailViewModel.slots,
                          selectedSlot: _productDetailViewModel.selectedSlotIndex,
                          packageCount: _productDetailViewModel.packageCount,
                          onSelectSlot: (index) {
                            setState(() {
                              _productDetailViewModel = _productDetailViewModel.selectSlot(index);
                            });
                          },
                          onChangePackageCount: (count) {
                            setState(() {
                              _productDetailViewModel = _productDetailViewModel.changePackageCount(count);
                            });
                          },
                        ),
                      SmartPage.order => OrderDetailPage(
                          key: const ValueKey('order'),
                          timelineSteps: _orderDetailViewModel.timelineSteps,
                        ),
                      SmartPage.farms => const InfoPlaceholderPage(
                          key: ValueKey('farms'),
                          title: '농장 소개',
                          message: '직거래 농장 이야기와 재배 철학 영역은 다음 단계에서 연결합니다.',
                          icon: Icons.park_outlined,
                        ),
                      SmartPage.guide => const InfoPlaceholderPage(
                          key: ValueKey('guide'),
                          title: '예약 안내',
                          message: '예약 방법, 배송 흐름, 반품 정책 안내 영역은 다음 단계에서 연결합니다.',
                          icon: Icons.menu_book_outlined,
                        ),
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _currentPage == SmartPage.home
          ? FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  _currentPage = SmartPage.order;
                });
              },
              backgroundColor: AppColors.textPrimary,
              foregroundColor: Colors.white,
              label: const Text('주문상세 보기'),
              icon: const Icon(Icons.local_shipping_outlined),
            )
          : null,
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:smart_web/yeeun/core/app_routes.dart';

void main() {
  runApp(const HarvestSlotApp());
}

class HarvestSlotApp extends StatelessWidget {
  const HarvestSlotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Harvest Slot',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: AppRoutes.routes,
      theme: ThemeData(
        fontFamily: 'Pretendard',
        scaffoldBackgroundColor: const Color(0xffF8FAF3),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff1F6B4A)),
        useMaterial3: true,
      ),
    );
  }
}
