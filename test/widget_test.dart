import 'package:flutter_test/flutter_test.dart';
import 'package:smart_web/main.dart';

void main() {
  testWidgets('loads the Harvest Slot home page', (tester) async {
    await tester.pumpWidget(const HarvestSlotApp());

    expect(find.text('예약 가능한 상품'), findsOneWidget);
    expect(find.text('후지 사과 5kg'), findsOneWidget);
  });
}
