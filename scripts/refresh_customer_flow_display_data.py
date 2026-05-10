from __future__ import annotations

from pathlib import Path
import sys


PROJECT_ROOT = Path(__file__).resolve().parents[1]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from backend.app.core.database import SessionLocal
from backend.app.models import (
    Account,
    CustomerProfile,
    Order,
    Payment,
    Procurement,
    ProcurementItem,
    Reservation,
    ReturnRequest,
    Shipment,
)


CUSTOMERS = {
    1: {
        "old_email": "qa.customer1@harvest-slot.test",
        "email": "minji.kim@harvest-slot.test",
        "name": "김민지",
        "phone": "010-2745-1189",
        "address": "서울시 강남구 테헤란로 152 9층",
    },
    2: {
        "old_email": "qa.customer2@harvest-slot.test",
        "email": "seojun.park@harvest-slot.test",
        "name": "박서준",
        "phone": "010-5832-4071",
        "address": "경기도 성남시 분당구 판교역로 235 1203호",
    },
    3: {
        "old_email": "qa.customer3@harvest-slot.test",
        "email": "jieun.lee@harvest-slot.test",
        "name": "이지은",
        "phone": "010-9461-7720",
        "address": "부산시 해운대구 센텀중앙로 48 1805호",
    },
}


def scenario_from_key(value: str, marker: str) -> tuple[int, int] | None:
    if marker not in value:
        return None
    key = value.split(marker, 1)[1]
    parts = key.replace("-", "").replace("_", "")
    if len(parts) < 5 or parts[0] != "C":
        return None
    try:
        return int(parts[1:3]), int(parts[3:5])
    except ValueError:
        return None


def customer_index_from_row(row) -> int | None:
    candidates = [
        getattr(row, "reservation_no", ""),
        getattr(row, "order_no", ""),
        getattr(row, "tracking_no", ""),
        getattr(row, "return_no", ""),
        getattr(row, "idempotency_key", ""),
        getattr(row, "mock_transaction_key", ""),
        getattr(row, "procurement_no", ""),
    ]
    markers = ["QA-RSV-", "QA-ORD-", "QA", "QA-RET-", "qa-payment-", "qa-tx-", "QA-PRC-"]
    for value in candidates:
        if not value:
            continue
        for marker in markers:
            parsed = scenario_from_key(str(value), marker)
            if parsed:
                return parsed[0]
    return None


def update_accounts(session) -> None:
    owner = session.query(Account).filter(Account.email == "qa.owner@harvest-slot.test").one_or_none()
    if owner:
        owner.email = "sunnyfarm.owner@harvest-slot.test"
        if owner.owner_profile:
            owner.owner_profile.owner_name = "정하늘"
            owner.owner_profile.owner_phone = "010-3308-6124"
            owner.owner_profile.business_number = "612-81-45820"

    for index, data in CUSTOMERS.items():
        account = (
            session.query(Account)
            .filter(Account.email.in_([data["old_email"], data["email"]]))
            .one_or_none()
        )
        if not account:
            continue
        account.email = data["email"]
        profile = account.customer_profile
        if not profile:
            continue
        profile.customer_name = data["name"]
        profile.customer_phone = data["phone"]
        profile.default_receiver_name = data["name"]
        profile.default_receiver_phone = data["phone"]
        profile.default_shipping_address = data["address"]

        for reservation in profile.reservations:
            if reservation.reservation_no.startswith("QA-RSV-"):
                _, scenario = scenario_from_key(reservation.reservation_no, "QA-RSV-") or (index, 0)
                reservation.reservation_no = f"RSV-202605{index}{scenario:02d}"
            if reservation.order:
                reservation.order.receiver_name = data["name"]
                reservation.order.receiver_phone = data["phone"]
                reservation.order.shipping_address = data["address"]


def update_flow_numbers(session) -> None:
    for order in session.query(Order).filter(Order.order_no.like("QA-ORD-%")).all():
        parsed = scenario_from_key(order.order_no, "QA-ORD-")
        if not parsed:
            continue
        customer_index, scenario = parsed
        order.order_no = f"ORD-202605{customer_index}{scenario:02d}"

    for payment in session.query(Payment).filter(Payment.idempotency_key.like("qa-payment-%")).all():
        parsed = scenario_from_key(payment.idempotency_key, "qa-payment-")
        if not parsed:
            continue
        customer_index, scenario = parsed
        payment.idempotency_key = f"payment-202605{customer_index}{scenario:02d}"
        payment.mock_transaction_key = f"TX202605{customer_index}{scenario:02d}"

    for procurement in session.query(Procurement).filter(Procurement.procurement_no.like("QA-PRC-%")).all():
        parsed = scenario_from_key(procurement.procurement_no, "QA-PRC-")
        if not parsed:
            continue
        customer_index, scenario = parsed
        procurement.procurement_no = f"PRC-202605{customer_index}{scenario:02d}"

    for item in session.query(ProcurementItem).filter(ProcurementItem.owner_memo.like("%QA%")).all():
        item.owner_memo = "농가 승인 완료"

    for shipment in session.query(Shipment).filter(Shipment.tracking_no.like("QA%")).all():
        parsed = scenario_from_key(shipment.tracking_no, "QA")
        if not parsed:
            continue
        customer_index, scenario = parsed
        shipment.tracking_no = f"68451234{customer_index}{scenario:02d}"

    for return_request in session.query(ReturnRequest).filter(ReturnRequest.return_no.like("QA-RET-%")).all():
        parsed = scenario_from_key(return_request.return_no, "QA-RET-")
        if not parsed:
            continue
        customer_index, scenario = parsed
        return_request.return_no = f"RET-202605{customer_index}{scenario:02d}"
        return_request.reason_detail = "배송 중 상품 일부가 손상되어 반품을 신청했습니다."
        if return_request.decision_reason:
            return_request.decision_reason = "환불 승인이 완료되었습니다."


def main() -> None:
    session = SessionLocal()
    try:
        update_accounts(session)
        update_flow_numbers(session)
        session.commit()
    except Exception:
        session.rollback()
        raise
    finally:
        session.close()

    print("Customer-facing demo data display values refreshed.")
    print("Login accounts:")
    for data in CUSTOMERS.values():
        print(f"- {data['email']} / Qa1234!")


if __name__ == "__main__":
    main()
