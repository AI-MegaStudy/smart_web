class HarvestSlotModel {
  const HarvestSlotModel({
    required this.slotId,
    required this.productId,
    required this.harvestStartLabel,
    required this.harvestEndLabel,
    required this.confirmedPrice,
    required this.confirmedReservableKg,
    required this.availableKg,
    required this.customerNotice,
    required this.slotStatus,
  });

  final int slotId;
  final int productId;
  final String harvestStartLabel;
  final String harvestEndLabel;
  final int confirmedPrice;
  final double confirmedReservableKg;
  final double availableKg;
  final String customerNotice;
  final String slotStatus;
}
