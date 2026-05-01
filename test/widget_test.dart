import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_web/app/app.dart';

void main() {
  testWidgets('홈 화면이 표시된다', (WidgetTester tester) async {
    await tester.pumpWidget(const HarvestSlotApp());
    await tester.pump();

    expect(find.text('Harvest Slot'), findsOneWidget);
    expect(find.text('수확일이 확정된 사과만 예약하세요'), findsOneWidget);
    expect(find.text('예약 상품 보기'), findsOneWidget);
  });

  testWidgets('예약함 버튼을 누르면 준비 중 화면으로 이동한다', (WidgetTester tester) async {
    await tester.pumpWidget(const HarvestSlotApp());
    await tester.pump();

    await tester.tap(find.byTooltip('예약함'));
    await tester.pumpAndSettle();

    expect(find.text('예약함'), findsOneWidget);
    expect(find.text('선택한 수확 슬롯과 박스 수량을 확인하세요'), findsOneWidget);
    expect(find.text('예약 확인'), findsOneWidget);
  });

  testWidgets('상품 목록 화면으로 이동한다', (WidgetTester tester) async {
    await tester.pumpWidget(const HarvestSlotApp());
    await tester.pump();

    await tester.tap(find.text('예약 상품 보기'));
    await tester.pumpAndSettle();

    expect(find.text('상품 목록'), findsOneWidget);
    expect(find.text('농가가 오픈한 사과 수확 슬롯'), findsOneWidget);
    expect(find.text('후지 사과 5kg'), findsOneWidget);
    expect(find.text('전체'), findsOneWidget);
  });

  testWidgets('홈에서 내 주문 목록으로 이동한다', (WidgetTester tester) async {
    await tester.pumpWidget(const HarvestSlotApp());
    await tester.pump();

    await tester.tap(find.text('내 주문'));
    await tester.pumpAndSettle();

    expect(find.text('최근 예약 주문'), findsOneWidget);
    expect(find.text('ORD-20261012-008'), findsOneWidget);
  });

  testWidgets('홈에서 회원가입 화면으로 이동한다', (WidgetTester tester) async {
    await tester.pumpWidget(const HarvestSlotApp());
    await tester.pump();

    await tester.tap(find.text('회원가입'));
    await tester.pumpAndSettle();

    expect(find.text('예약과 배송 안내를 받을 계정을 만듭니다'), findsOneWidget);
    expect(find.text('가입하고 인증'), findsOneWidget);
  });

  testWidgets('회원가입 후 이메일 인증 화면으로 이동한다', (WidgetTester tester) async {
    await tester.pumpWidget(const HarvestSlotApp());
    await tester.pump();

    await tester.tap(find.text('회원가입'));
    await tester.pumpAndSettle();

    final verifyButton = find.text('가입하고 인증');
    await tester.ensureVisible(verifyButton);
    await tester.pumpAndSettle();
    await tester.tap(verifyButton);
    await tester.pumpAndSettle();

    expect(find.text('메일로 받은 인증 코드를 입력하세요'), findsOneWidget);
    expect(find.text('인증 완료'), findsOneWidget);
  });

  testWidgets('이메일 인증에서 로그인 화면으로 이동한다', (WidgetTester tester) async {
    await tester.pumpWidget(const HarvestSlotApp());
    await tester.pump();

    await tester.tap(find.text('회원가입'));
    await tester.pumpAndSettle();

    final verifyButton = find.text('가입하고 인증');
    await tester.ensureVisible(verifyButton);
    await tester.pumpAndSettle();
    await tester.tap(verifyButton);
    await tester.pumpAndSettle();

    await tester.tap(find.text('재발송'));
    await tester.pump();
    expect(find.text('인증 코드 재발송 완료'), findsOneWidget);

    final completeButton = find.text('인증 완료');
    await tester.ensureVisible(completeButton);
    await tester.pumpAndSettle();
    await tester.tap(completeButton);
    await tester.pumpAndSettle();

    expect(find.text('예약 내역을 이어서 확인하세요'), findsOneWidget);
    expect(find.text('고객 로그인'), findsOneWidget);
  });

  testWidgets('홈에서 로그인 화면으로 이동한다', (WidgetTester tester) async {
    await tester.pumpWidget(const HarvestSlotApp());
    await tester.pump();

    await tester.tap(find.text('로그인'));
    await tester.pumpAndSettle();

    expect(find.text('예약 내역을 이어서 확인하세요'), findsOneWidget);
    expect(find.text('고객 로그인'), findsOneWidget);
  });

  testWidgets('로그인 후 홈으로 이동한다', (WidgetTester tester) async {
    await tester.pumpWidget(const HarvestSlotApp());
    await tester.pump();

    await tester.tap(find.text('로그인'));
    await tester.pumpAndSettle();

    final loginButtons = find.text('로그인하기');
    await tester.ensureVisible(loginButtons);
    await tester.pumpAndSettle();
    await tester.tap(loginButtons);
    await tester.pumpAndSettle();

    expect(find.text('수확일이 확정된 사과만 예약하세요'), findsOneWidget);
  });

  testWidgets('내 주문 목록에서 주문 상세로 이동한다', (WidgetTester tester) async {
    await tester.pumpWidget(const HarvestSlotApp());
    await tester.pump();

    await tester.tap(find.text('내 주문'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('ORD-20261012-008'));
    await tester.pumpAndSettle();

    expect(find.text('주문 진행 상태'), findsOneWidget);
    expect(find.text('진행 현황'), findsOneWidget);
  });

  testWidgets('상품 상세에서 수확 슬롯과 수량을 확인한다', (WidgetTester tester) async {
    await tester.pumpWidget(const HarvestSlotApp());
    await tester.pump();

    await tester.tap(find.text('예약 상품 보기'));
    await tester.pumpAndSettle();

    final productTitle = find.text('후지 사과 5kg').first;
    await tester.ensureVisible(productTitle);
    await tester.pumpAndSettle();
    await tester.tap(productTitle);
    await tester.pumpAndSettle();

    expect(find.text('상품 상세'), findsOneWidget);
    expect(find.text('후지 사과 5kg'), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('수확 슬롯 선택'), findsOneWidget);
    expect(find.text('예약함에 담기'), findsOneWidget);
    expect(find.text('1박스'), findsOneWidget);

    final increaseButton = find.byTooltip('수량 늘리기');
    await tester.ensureVisible(increaseButton);
    await tester.pumpAndSettle();
    await tester.tap(increaseButton);
    await tester.pump();

    expect(find.text('2박스'), findsOneWidget);
    expect(find.text('예약 중량'), findsOneWidget);
  });

  testWidgets('예약함에서 예약 확인으로 이동한다', (WidgetTester tester) async {
    await tester.pumpWidget(const HarvestSlotApp());
    await tester.pump();

    await tester.tap(find.byTooltip('예약함'));
    await tester.pumpAndSettle();

    expect(find.text('후지 사과 5kg'), findsOneWidget);
    expect(find.text('총 예약 중량'), findsOneWidget);

    final confirmButton = find.text('예약 확인');
    await tester.ensureVisible(confirmButton);
    await tester.pumpAndSettle();
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();

    expect(find.text('예약할 수확 슬롯과 수량을 확인하세요'), findsOneWidget);
    expect(find.text('예약 확정하기'), findsOneWidget);
  });

  testWidgets('예약 확인에서 주문서 작성으로 이동한다', (WidgetTester tester) async {
    await tester.pumpWidget(const HarvestSlotApp());
    await tester.pump();

    await tester.tap(find.byTooltip('예약함'));
    await tester.pumpAndSettle();

    final confirmButton = find.text('예약 확인');
    await tester.ensureVisible(confirmButton);
    await tester.pumpAndSettle();
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();

    final reserveButton = find.text('예약 확정하기');
    await tester.ensureVisible(reserveButton);
    await tester.pumpAndSettle();
    await tester.tap(reserveButton);
    await tester.pumpAndSettle();

    expect(find.text('예약 상품을 받을 정보를 입력하세요'), findsOneWidget);
    expect(find.text('주문 생성'), findsOneWidget);
  });

  testWidgets('주문서 작성에서 결제 화면으로 이동한다', (WidgetTester tester) async {
    await tester.pumpWidget(const HarvestSlotApp());
    await tester.pump();

    await tester.tap(find.byTooltip('예약함'));
    await tester.pumpAndSettle();

    final confirmButton = find.text('예약 확인');
    await tester.ensureVisible(confirmButton);
    await tester.pumpAndSettle();
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();

    final reserveButton = find.text('예약 확정하기');
    await tester.ensureVisible(reserveButton);
    await tester.pumpAndSettle();
    await tester.tap(reserveButton);
    await tester.pumpAndSettle();

    final orderButton = find.text('주문 생성');
    await tester.ensureVisible(orderButton);
    await tester.pumpAndSettle();
    await tester.tap(orderButton);
    await tester.pumpAndSettle();

    expect(find.text('주문 금액을 확인하고 결제를 승인하세요'), findsOneWidget);
    expect(find.text('결제 승인'), findsOneWidget);
  });

  testWidgets('결제 승인 후 주문 완료 화면으로 이동한다', (WidgetTester tester) async {
    await tester.pumpWidget(const HarvestSlotApp());
    await tester.pump();

    await tester.tap(find.byTooltip('예약함'));
    await tester.pumpAndSettle();

    final confirmButton = find.text('예약 확인');
    await tester.ensureVisible(confirmButton);
    await tester.pumpAndSettle();
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();

    final reserveButton = find.text('예약 확정하기');
    await tester.ensureVisible(reserveButton);
    await tester.pumpAndSettle();
    await tester.tap(reserveButton);
    await tester.pumpAndSettle();

    final orderButton = find.text('주문 생성');
    await tester.ensureVisible(orderButton);
    await tester.pumpAndSettle();
    await tester.tap(orderButton);
    await tester.pumpAndSettle();

    final paymentButton = find.text('결제 승인');
    await tester.ensureVisible(paymentButton);
    await tester.pumpAndSettle();
    await tester.tap(paymentButton);
    await tester.pumpAndSettle();

    expect(find.text('예약 주문이 완료되었습니다'), findsOneWidget);
    expect(find.text('주문 상세'), findsOneWidget);
  });

  testWidgets('주문 완료에서 주문 상세로 이동한다', (WidgetTester tester) async {
    await tester.pumpWidget(const HarvestSlotApp());
    await tester.pump();

    await tester.tap(find.byTooltip('예약함'));
    await tester.pumpAndSettle();

    final confirmButton = find.text('예약 확인');
    await tester.ensureVisible(confirmButton);
    await tester.pumpAndSettle();
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();

    final reserveButton = find.text('예약 확정하기');
    await tester.ensureVisible(reserveButton);
    await tester.pumpAndSettle();
    await tester.tap(reserveButton);
    await tester.pumpAndSettle();

    final orderButton = find.text('주문 생성');
    await tester.ensureVisible(orderButton);
    await tester.pumpAndSettle();
    await tester.tap(orderButton);
    await tester.pumpAndSettle();

    final paymentButton = find.text('결제 승인');
    await tester.ensureVisible(paymentButton);
    await tester.pumpAndSettle();
    await tester.tap(paymentButton);
    await tester.pumpAndSettle();

    final detailButton = find.text('주문 상세');
    await tester.ensureVisible(detailButton);
    await tester.pumpAndSettle();
    await tester.tap(detailButton);
    await tester.pumpAndSettle();

    expect(find.text('주문 진행 상태'), findsOneWidget);
    expect(find.text('진행 현황'), findsOneWidget);
    expect(find.text('반품 신청'), findsOneWidget);
  });

  testWidgets('주문 상세에서 반품 신청으로 이동한다', (WidgetTester tester) async {
    await tester.pumpWidget(const HarvestSlotApp());
    await tester.pump();

    await tester.tap(find.byTooltip('예약함'));
    await tester.pumpAndSettle();

    final confirmButton = find.text('예약 확인');
    await tester.ensureVisible(confirmButton);
    await tester.pumpAndSettle();
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();

    final reserveButton = find.text('예약 확정하기');
    await tester.ensureVisible(reserveButton);
    await tester.pumpAndSettle();
    await tester.tap(reserveButton);
    await tester.pumpAndSettle();

    final orderButton = find.text('주문 생성');
    await tester.ensureVisible(orderButton);
    await tester.pumpAndSettle();
    await tester.tap(orderButton);
    await tester.pumpAndSettle();

    final paymentButton = find.text('결제 승인');
    await tester.ensureVisible(paymentButton);
    await tester.pumpAndSettle();
    await tester.tap(paymentButton);
    await tester.pumpAndSettle();

    final detailButton = find.text('주문 상세');
    await tester.ensureVisible(detailButton);
    await tester.pumpAndSettle();
    await tester.tap(detailButton);
    await tester.pumpAndSettle();

    final returnButton = find.text('반품 신청');
    await tester.ensureVisible(returnButton);
    await tester.pumpAndSettle();
    await tester.tap(returnButton);
    await tester.pumpAndSettle();

    expect(find.text('반품 사유와 증빙을 입력하세요'), findsOneWidget);
    expect(find.text('반품 요청 접수'), findsOneWidget);
  });

  testWidgets('반품 요청 접수 후 홈으로 이동한다', (WidgetTester tester) async {
    await tester.pumpWidget(const HarvestSlotApp());
    await tester.pump();

    await tester.tap(find.byTooltip('예약함'));
    await tester.pumpAndSettle();

    final confirmButton = find.text('예약 확인');
    await tester.ensureVisible(confirmButton);
    await tester.pumpAndSettle();
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();

    final reserveButton = find.text('예약 확정하기');
    await tester.ensureVisible(reserveButton);
    await tester.pumpAndSettle();
    await tester.tap(reserveButton);
    await tester.pumpAndSettle();

    final orderButton = find.text('주문 생성');
    await tester.ensureVisible(orderButton);
    await tester.pumpAndSettle();
    await tester.tap(orderButton);
    await tester.pumpAndSettle();

    final paymentButton = find.text('결제 승인');
    await tester.ensureVisible(paymentButton);
    await tester.pumpAndSettle();
    await tester.tap(paymentButton);
    await tester.pumpAndSettle();

    final detailButton = find.text('주문 상세');
    await tester.ensureVisible(detailButton);
    await tester.pumpAndSettle();
    await tester.tap(detailButton);
    await tester.pumpAndSettle();

    final returnButton = find.text('반품 신청');
    await tester.ensureVisible(returnButton);
    await tester.pumpAndSettle();
    await tester.tap(returnButton);
    await tester.pumpAndSettle();

    final submitButton = find.text('반품 요청 접수');
    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.text('수확일이 확정된 사과만 예약하세요'), findsOneWidget);
  });
}
