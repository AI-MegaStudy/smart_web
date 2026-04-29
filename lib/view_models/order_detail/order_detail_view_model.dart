class OrderDetailViewModel {
  const OrderDetailViewModel({
    required this.timelineSteps,
  });

  final List<String> timelineSteps;

  factory OrderDetailViewModel.sample() {
    return const OrderDetailViewModel(
      timelineSteps: [
        '예약완료',
        '수확준비',
        '선별완료',
        '포장중',
        '배송중',
        '배송완료',
      ],
    );
  }
}
