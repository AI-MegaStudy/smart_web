enum SmartPage {
  home('상세'),
  products('상품'),
  farms('농장소개'),
  guide('예약안내'),
  order('주문상세');

  const SmartPage(this.label);
  final String label;
}
