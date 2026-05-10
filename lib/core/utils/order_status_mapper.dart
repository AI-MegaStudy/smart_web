class OrderStatusMapper {
  const OrderStatusMapper._();

  static const paymentPending = 'PAYMENT_PENDING';
  static const paid = 'PAID';
  static const procurementRequested = 'PROCUREMENT_REQUESTED';
  static const procurementApproved = 'PROCUREMENT_APPROVED';
  static const procurementPartialApproved = 'PROCUREMENT_PARTIAL_APPROVED';
  static const procurementRejected = 'PROCUREMENT_REJECTED';
  static const qualityChecking = 'QUALITY_CHECKING';
  static const readyToShip = 'READY_TO_SHIP';
  static const shipped = 'SHIPPED';
  static const delivered = 'DELIVERED';
  static const returnRequested = 'RETURN_REQUESTED';
  static const refunded = 'REFUNDED';
  static const canceled = 'CANCELED';

  static const shipmentReady = 'READY';

  static const returnRequestRequested = 'REQUESTED';
  static const returnRequestApproved = 'APPROVED';
  static const returnRequestRejected = 'REJECTED';

  static const labels = {
    paymentPending: '결제 대기',
    paid: '결제 완료',
    procurementRequested: '농가 확인 중',
    procurementApproved: '농가 승인 완료',
    procurementPartialApproved: '일부 수량 확인 필요',
    procurementRejected: '농가 승인 불가',
    qualityChecking: '선별 중',
    readyToShip: '발송 준비',
    shipped: '배송 중',
    delivered: '배송 완료',
    returnRequested: '반품 요청 접수',
    refunded: '환불 완료',
    canceled: '주문 취소',
  };

  static const shipmentLabels = {
    shipmentReady: '배송 준비',
    shipped: '배송 중',
    delivered: '배송 완료',
  };

  static const returnLabels = {
    returnRequestRequested: '반품 요청 접수',
    returnRequestApproved: '반품 승인',
    returnRequestRejected: '반품 반려',
    refunded: '환불 완료',
  };

  static String labelOf(String statusCode) {
    return labels[statusCode] ?? '상태 확인 중';
  }

  static String shipmentLabelOf(String shipmentStatus) {
    return shipmentLabels[shipmentStatus] ?? '배송 상태 확인 중';
  }

  static String returnLabelOf(String returnStatus) {
    return returnLabels[returnStatus] ?? '반품 상태 확인 중';
  }

  static String demoStatusCodeForOrderId(int orderId) {
    return switch (orderId) {
      8 => procurementRequested,
      14 => shipped,
      2 => delivered,
      _ => shipped,
    };
  }
}
