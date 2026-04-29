class HarvestSlotViewData {
  const HarvestSlotViewData({
    required this.label,
    required this.window,
    required this.remainingKg,
    required this.price,
    required this.unitKg,
    required this.status,
    required this.disabled,
  });

  final String label;
  final String window;
  final int remainingKg;
  final int price;
  final int unitKg;
  final String status;
  final bool disabled;
}
