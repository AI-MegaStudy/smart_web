import '../data/repositories/return_repository.dart';

class CustomerDemoReturnData {
  static List<ReturnHistoryItem> items() {
    return [
      ReturnHistoryItem(
        returnRequestId: 901,
        orderId: 34,
        orderNumber: 'ORD-202605334',
        returnNumber: 'RET-2026051201',
        returnStatusLabel: '반품 요청 접수',
        reasonLabel: '상품 파손',
        reasonDetail: '박스 모서리가 찌그러져 있었고 사과 표면에 눌림 흔적이 있어 반품을 요청했습니다.',
        requestedAmount: 32000,
        approvedAmount: 0,
        decisionReason: '',
        requestedAt: DateTime(2026, 5, 12, 15, 10),
      ),
      ReturnHistoryItem(
        returnRequestId: 902,
        orderId: 26,
        orderNumber: 'ORD-202605326',
        returnNumber: 'RET-2026051107',
        returnStatusLabel: '반품 승인',
        reasonLabel: '상품 변질',
        reasonDetail: '수령 직후 확인했을 때 일부 사과가 물러 있고 신선도가 기대보다 낮았습니다.',
        requestedAmount: 32000,
        approvedAmount: 32000,
        decisionReason: '증빙 사진과 배송 상태를 확인한 뒤 전액 환불로 승인되었습니다.',
        requestedAt: DateTime(2026, 5, 11, 10, 25),
        decidedAt: DateTime(2026, 5, 11, 17, 40),
      ),
      ReturnHistoryItem(
        returnRequestId: 903,
        orderId: 35,
        orderNumber: 'ORD-202605335',
        returnNumber: 'RET-2026050903',
        returnStatusLabel: '환불 완료',
        reasonLabel: '오배송',
        reasonDetail: '주문한 상품과 다른 포장 상태로 도착해 확인 후 반품을 진행했습니다.',
        requestedAmount: 32000,
        approvedAmount: 32000,
        decisionReason: '오배송이 확인되어 카드 결제가 전액 환불 처리되었습니다.',
        requestedAt: DateTime(2026, 5, 9, 14, 5),
        decidedAt: DateTime(2026, 5, 10, 9, 20),
      ),
    ];
  }

  static ReturnRequestResult submittedResult({
    required int orderId,
    required int requestedAmount,
  }) {
    return ReturnRequestResult(
      returnRequestId: 904,
      returnNumber: 'RET-2026051215',
      returnStatusLabel: '반품 요청 접수',
      orderId: orderId,
      requestedAmount: requestedAmount,
    );
  }

  const CustomerDemoReturnData._();
}
