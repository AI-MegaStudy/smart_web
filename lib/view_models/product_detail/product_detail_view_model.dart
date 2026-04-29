import 'harvest_slot_view_data.dart';

class ProductDetailViewModel {
  const ProductDetailViewModel({
    required this.slots,
    this.selectedSlotIndex = 0,
    this.packageCount = 1,
  });

  final List<HarvestSlotViewData> slots;
  final int selectedSlotIndex;
  final int packageCount;

  HarvestSlotViewData get selectedSlot => slots[selectedSlotIndex];

  ProductDetailViewModel copyWith({
    List<HarvestSlotViewData>? slots,
    int? selectedSlotIndex,
    int? packageCount,
  }) {
    return ProductDetailViewModel(
      slots: slots ?? this.slots,
      selectedSlotIndex: selectedSlotIndex ?? this.selectedSlotIndex,
      packageCount: packageCount ?? this.packageCount,
    );
  }

  ProductDetailViewModel selectSlot(int index) {
    return copyWith(selectedSlotIndex: index);
  }

  ProductDetailViewModel changePackageCount(int count) {
    return copyWith(packageCount: count.clamp(1, 9));
  }

  factory ProductDetailViewModel.sample() {
    return const ProductDetailViewModel(
      slots: [
        HarvestSlotViewData(
          label: '1차 수확 슬롯',
          window: '2026.10.12 ~ 10.18',
          remainingKg: 72,
          price: 39000,
          unitKg: 5,
          status: '예약 가능',
          disabled: false,
        ),
        HarvestSlotViewData(
          label: '2차 수확 슬롯',
          window: '2026.10.19 ~ 10.25',
          remainingKg: 120,
          price: 38000,
          unitKg: 5,
          status: '예약 가능',
          disabled: false,
        ),
        HarvestSlotViewData(
          label: '조기 수확 슬롯',
          window: '2026.10.05 ~ 10.10',
          remainingKg: 0,
          price: 41000,
          unitKg: 5,
          status: '품절',
          disabled: true,
        ),
      ],
    );
  }
}
