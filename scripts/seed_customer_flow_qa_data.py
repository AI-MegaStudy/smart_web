from __future__ import annotations

from datetime import UTC, date, datetime, timedelta
from pathlib import Path
import sys


PROJECT_ROOT = Path(__file__).resolve().parents[1]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from backend.app.core.database import Base, SessionLocal, engine
from backend.app.core.security import hash_password
from backend.app.core.status import (
    AccountRole,
    AccountStatus,
    HarvestSlotStatus,
    OrderItemStatus,
    OrderStatus,
    PaymentStatus,
    ProcurementStatus,
    RefundStatus,
    ReservationStatus,
    ReturnStatus,
    ShipmentStatus,
)
from backend.app.models import (
    Account,
    CustomerProfile,
    Farm,
    HarvestSlot,
    Order,
    OrderItem,
    OwnerProfile,
    Payment,
    Procurement,
    ProcurementItem,
    Product,
    Refund,
    Reservation,
    ReservationItem,
    ReturnRequest,
    Shipment,
)


QA_PASSWORD = "Qa1234!"
OWNER_EMAIL = "qa.owner@harvest-slot.test"
CUSTOMER_EMAILS = [
    "qa.customer1@harvest-slot.test",
    "qa.customer2@harvest-slot.test",
    "qa.customer3@harvest-slot.test",
]

FLOW_SCENARIOS = [
    "reservation_only",
    "order_created",
    "payment_pending",
    "paid",
    "shipped",
    "delivered",
    "return_requested",
    "refunded",
]


def utc_now() -> datetime:
    return datetime.now(UTC).replace(tzinfo=None)


def set_timestamps(row, created_at: datetime) -> None:
    if hasattr(row, "created_at"):
        row.created_at = created_at
    if hasattr(row, "updated_at"):
        row.updated_at = created_at


def get_or_create_account(session, email: str, role: str, name: str, phone: str):
    account = session.query(Account).filter(Account.email == email).one_or_none()
    if not account:
        account = Account(
            email=email,
            password_hash=hash_password(QA_PASSWORD),
            role=role,
            status=AccountStatus.ACTIVE,
            email_verified=True,
        )
        session.add(account)
        session.flush()

    if role == AccountRole.CUSTOMER:
        profile = account.customer_profile
        if not profile:
            profile = CustomerProfile(
                account_id=account.account_id,
                customer_name=name,
                customer_phone=phone,
                default_receiver_name=name,
                default_receiver_phone=phone,
                default_shipping_address=f"서울시 강남구 QA로 {account.account_id}",
                marketing_agree=False,
            )
            session.add(profile)
            session.flush()
        return account, profile

    profile = account.owner_profile
    if not profile:
        profile = OwnerProfile(
            account_id=account.account_id,
            owner_name=name,
            owner_phone=phone,
            business_number="QA-000-00-00000",
        )
        session.add(profile)
        session.flush()
    return account, profile


def get_or_create_farm(session, owner: OwnerProfile) -> Farm:
    farm = (
        session.query(Farm)
        .filter(Farm.farm_name.in_(["QA 하베스트 농장", "문경 햇살 농장"]))
        .one_or_none()
    )
    if farm:
        farm.farm_name = "문경 햇살 농장"
        farm.farm_description = "충주에서 수확한 제철 사과를 예약 후 순차 발송합니다."
        return farm
    farm = Farm(
        owner_id=owner.owner_id,
        farm_name="문경 햇살 농장",
        farm_region="충북 충주",
        farm_address="충북 충주시 과수원길 11",
        farm_image_url="https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6",
        farm_description="충주에서 수확한 제철 사과를 예약 후 순차 발송합니다.",
        delivery_policy="수확 후 순차 발송합니다.",
        return_policy="배송 완료 후 상품 상태 확인을 거쳐 접수합니다.",
    )
    session.add(farm)
    session.flush()
    return farm


def get_or_create_product(session, farm: Farm) -> Product:
    product = (
        session.query(Product)
        .filter(Product.product_name.in_(["QA 충주 부사 사과", "충주 햇살 부사 사과"]))
        .one_or_none()
    )
    if product:
        product.product_name = "충주 햇살 부사 사과"
        product.product_description = "아삭한 식감과 단맛이 좋은 충주 부사 사과입니다."
        return product
    product = Product(
        farm_id=farm.farm_id,
        product_name="충주 햇살 부사 사과",
        fruit_type="APPLE",
        variety="부사",
        package_unit_kg=5.0,
        base_price=32000,
        product_status="ACTIVE",
        image_url="https://images.unsplash.com/photo-1567306226416-28f0efdc88ce",
        product_description="아삭한 식감과 단맛이 좋은 충주 부사 사과입니다.",
    )
    session.add(product)
    session.flush()
    return product


def get_or_create_slot(session, farm: Farm, product: Product, slot_date: date, sequence: int) -> HarvestSlot:
    slot = (
        session.query(HarvestSlot)
        .filter(
            HarvestSlot.product_id == product.product_id,
            HarvestSlot.confirmed_harvest_start == slot_date,
        )
        .one_or_none()
    )
    if slot:
        return slot
    slot = HarvestSlot(
        farm_id=farm.farm_id,
        product_id=product.product_id,
        confirmed_harvest_start=slot_date,
        confirmed_harvest_end=slot_date + timedelta(days=2),
        confirmed_reservable_kg=500.0,
        reserved_kg=0.0,
        sold_kg=0.0,
        confirmed_price=32000,
        customer_notice=f"농가가 확정한 수확 예정 범위입니다. 순번 {sequence:02d}",
        slot_status=HarvestSlotStatus.OPEN,
        owner_confirmed_at=datetime.combine(slot_date - timedelta(days=5), datetime.min.time()),
        opened_at=datetime.combine(slot_date - timedelta(days=4), datetime.min.time()),
    )
    session.add(slot)
    session.flush()
    return slot


def create_reservation(session, customer: CustomerProfile, slot: HarvestSlot, key: str, created_at: datetime) -> Reservation:
    reservation_no = f"QA-RSV-{key}"
    reservation = session.query(Reservation).filter(Reservation.reservation_no == reservation_no).one_or_none()
    if reservation:
        return reservation

    package_count = 1 + (int(key[-2:]) % 3)
    reserved_kg = float(product_unit_kg(slot)) * package_count
    subtotal_amount = package_count * slot.confirmed_price
    reservation = Reservation(
        customer_id=customer.customer_id,
        reservation_no=reservation_no,
        reservation_status=ReservationStatus.RESERVED,
        reserved_until=utc_now() + timedelta(days=2) if key.endswith("01") else created_at + timedelta(days=1),
        total_reserved_kg=reserved_kg,
        total_amount=subtotal_amount,
    )
    set_timestamps(reservation, created_at)
    session.add(reservation)
    session.flush()

    item = ReservationItem(
        reservation_id=reservation.reservation_id,
        slot_id=slot.slot_id,
        package_count=package_count,
        reserved_kg=reserved_kg,
        unit_price_snapshot=slot.confirmed_price,
        subtotal_amount=subtotal_amount,
        created_at=created_at,
    )
    session.add(item)
    slot.reserved_kg = round(float(slot.reserved_kg) + reserved_kg, 2)
    session.flush()
    return reservation


def product_unit_kg(slot: HarvestSlot) -> float:
    return float(slot.product.package_unit_kg)


def create_order(session, reservation: Reservation, key: str, ordered_at: datetime) -> Order:
    order_no = f"QA-ORD-{key}"
    order = session.query(Order).filter(Order.order_no == order_no).one_or_none()
    if order:
        return order

    customer = reservation.customer
    order = Order(
        reservation_id=reservation.reservation_id,
        order_no=order_no,
        order_status=OrderStatus.PAYMENT_PENDING,
        total_amount=reservation.total_amount,
        receiver_name=customer.default_receiver_name or customer.customer_name,
        receiver_phone=customer.default_receiver_phone or customer.customer_phone,
        shipping_address=customer.default_shipping_address or "서울시 강남구 QA로 1",
        delivery_memo="문 앞에 놓아주세요.",
        ordered_at=ordered_at,
    )
    set_timestamps(order, ordered_at)
    session.add(order)
    reservation.reservation_status = ReservationStatus.ORDERED
    session.flush()

    for reservation_item in reservation.reservation_items:
        order_item = OrderItem(
            order_id=order.order_id,
            reservation_item_id=reservation_item.reservation_item_id,
            package_count=reservation_item.package_count,
            ordered_kg=reservation_item.reserved_kg,
            unit_price=reservation_item.unit_price_snapshot,
            subtotal_amount=reservation_item.subtotal_amount,
            order_item_status=OrderItemStatus.ORDERED,
        )
        set_timestamps(order_item, ordered_at)
        session.add(order_item)
        reservation_item.slot.sold_kg = round(float(reservation_item.slot.sold_kg) + float(reservation_item.reserved_kg), 2)
    session.flush()
    return order


def create_payment(
    session,
    order: Order,
    key: str,
    requested_at: datetime,
    approved: bool,
    refunded: bool = False,
) -> Payment:
    idempotency_key = f"qa-payment-{key}"
    payment = session.query(Payment).filter(Payment.idempotency_key == idempotency_key).one_or_none()
    if payment:
        return payment

    status = PaymentStatus.REQUESTED
    approved_amount = 0
    approved_at = None
    if approved:
        status = PaymentStatus.REFUNDED if refunded else PaymentStatus.APPROVED
        approved_amount = order.total_amount
        approved_at = requested_at + timedelta(minutes=20)

    payment = Payment(
        order_id=order.order_id,
        payment_provider="MOCK",
        payment_method="MOCK_CARD",
        payment_status=status,
        requested_amount=order.total_amount,
        approved_amount=approved_amount,
        mock_transaction_key=f"qa-tx-{key}",
        idempotency_key=idempotency_key,
        requested_at=requested_at,
        approved_at=approved_at,
    )
    set_timestamps(payment, requested_at)
    session.add(payment)
    if approved:
        order.order_status = OrderStatus.PAID
        order.paid_at = approved_at
    session.flush()
    return payment


def create_procurement(session, order: Order, farm: Farm, owner: OwnerProfile, key: str, requested_at: datetime) -> Procurement:
    procurement_no = f"QA-PRC-{key}"
    procurement = session.query(Procurement).filter(Procurement.procurement_no == procurement_no).one_or_none()
    if procurement:
        return procurement

    procurement = Procurement(
        order_id=order.order_id,
        farm_id=farm.farm_id,
        owner_id=owner.owner_id,
        procurement_no=procurement_no,
        procurement_status=ProcurementStatus.APPROVED,
        requested_at=requested_at,
        response_deadline_at=requested_at + timedelta(days=1),
        decided_at=requested_at + timedelta(hours=2),
    )
    set_timestamps(procurement, requested_at)
    session.add(procurement)
    session.flush()

    for order_item in order.order_items:
        procurement_item = ProcurementItem(
            procurement_id=procurement.procurement_id,
            order_item_id=order_item.order_item_id,
            requested_package_count=order_item.package_count,
            requested_kg=order_item.ordered_kg,
            approved_package_count=order_item.package_count,
            approved_kg=order_item.ordered_kg,
            approval_status=ProcurementStatus.APPROVED,
            owner_memo="QA 승인 데이터",
        )
        set_timestamps(procurement_item, requested_at)
        session.add(procurement_item)
    session.flush()
    return procurement


def create_shipment(
    session,
    order: Order,
    key: str,
    shipped_at: datetime,
    delivered_at: datetime | None,
) -> Shipment:
    shipment = session.query(Shipment).filter(Shipment.tracking_no == f"QA{key}").one_or_none()
    if shipment:
        return shipment

    total_package_count = sum(item.package_count for item in order.order_items)
    total_kg = sum(float(item.ordered_kg) for item in order.order_items)
    shipment_status = ShipmentStatus.DELIVERED if delivered_at else ShipmentStatus.SHIPPED
    shipment = Shipment(
        order_id=order.order_id,
        carrier_name="CJ대한통운",
        tracking_no=f"QA{key}",
        shipped_package_count=total_package_count,
        shipped_kg=round(total_kg, 2),
        shipment_status=shipment_status,
        shipped_at=shipped_at,
        delivered_at=delivered_at,
    )
    set_timestamps(shipment, shipped_at)
    session.add(shipment)
    order.order_status = OrderStatus.DELIVERED if delivered_at else OrderStatus.SHIPPED
    for item in order.order_items:
        item.order_item_status = OrderItemStatus.DELIVERED if delivered_at else OrderItemStatus.SHIPPED
    session.flush()
    return shipment


def create_return_request(
    session,
    order: Order,
    payment: Payment,
    key: str,
    requested_at: datetime,
    refunded: bool,
) -> ReturnRequest:
    return_no = f"QA-RET-{key}"
    return_request = session.query(ReturnRequest).filter(ReturnRequest.return_no == return_no).one_or_none()
    if return_request:
        return return_request

    return_request = ReturnRequest(
        order_id=order.order_id,
        return_no=return_no,
        return_status=ReturnStatus.REFUNDED if refunded else ReturnStatus.REQUESTED,
        reason_code="DAMAGED",
        reason_detail="배송 중 상품 일부가 손상되어 QA 반품 데이터를 생성했습니다.",
        requested_amount=order.total_amount,
        approved_amount=order.total_amount if refunded else 0,
        requested_at=requested_at,
        decided_at=requested_at + timedelta(hours=5) if refunded else None,
        decision_reason="QA 환불 승인" if refunded else None,
    )
    set_timestamps(return_request, requested_at)
    session.add(return_request)
    order.order_status = OrderStatus.REFUNDED if refunded else OrderStatus.RETURN_REQUESTED
    for item in order.order_items:
        item.order_item_status = OrderItemStatus.REFUNDED if refunded else OrderItemStatus.RETURN_REQUESTED
    session.flush()

    if refunded:
        payment.payment_status = PaymentStatus.REFUNDED
        refund = Refund(
            return_request_id=return_request.return_request_id,
            payment_id=payment.payment_id,
            refund_status=RefundStatus.COMPLETED,
            requested_amount=order.total_amount,
            refunded_amount=order.total_amount,
            requested_at=requested_at + timedelta(hours=5),
            completed_at=requested_at + timedelta(hours=6),
        )
        set_timestamps(refund, requested_at + timedelta(hours=5))
        session.add(refund)
        session.flush()

    return return_request


def apply_scenario(session, customer, farm, product, owner, customer_index: int, scenario_index: int, scenario: str) -> str:
    key = f"C{customer_index:02d}-{scenario_index:02d}"
    base_time = utc_now().replace(microsecond=0) - timedelta(days=90 - customer_index * 20 - scenario_index * 2)
    if scenario == "reservation_only":
        base_time = utc_now().replace(microsecond=0) - timedelta(minutes=customer_index * 7)

    slot_date = (base_time + timedelta(days=30)).date()
    if scenario == "reservation_only":
        slot_date = date.today() + timedelta(days=30 + customer_index)
    slot = get_or_create_slot(session, farm, product, slot_date, customer_index * 100 + scenario_index)
    reservation = create_reservation(session, customer, slot, key, base_time)
    if scenario == "reservation_only":
        return f"{customer.account.email}: 예약만 생성 {reservation.reservation_no}"

    order = create_order(session, reservation, key, base_time + timedelta(hours=4))
    if scenario == "order_created":
        return f"{customer.account.email}: 주문 생성 {order.order_no}"

    payment = create_payment(
        session,
        order,
        key,
        base_time + timedelta(hours=5),
        approved=scenario in {"paid", "shipped", "delivered", "return_requested", "refunded"},
        refunded=scenario == "refunded",
    )
    if scenario == "payment_pending":
        return f"{customer.account.email}: 결제 대기 {order.order_no}"

    create_procurement(session, order, farm, owner, key, base_time + timedelta(hours=6))
    if scenario == "paid":
        return f"{customer.account.email}: 결제 완료 {order.order_no}"

    delivered_at = None if scenario == "shipped" else base_time + timedelta(days=2)
    create_shipment(session, order, key, base_time + timedelta(days=1), delivered_at)
    if scenario == "shipped":
        return f"{customer.account.email}: 배송 중 {order.order_no}"
    if scenario == "delivered":
        return f"{customer.account.email}: 배송 완료 {order.order_no}"

    create_return_request(
        session,
        order,
        payment,
        key,
        base_time + timedelta(days=3),
        refunded=scenario == "refunded",
    )
    if scenario == "return_requested":
        return f"{customer.account.email}: 반품 신청 {order.order_no}"
    return f"{customer.account.email}: 환불 완료 {order.order_no}"


def main() -> None:
    Base.metadata.create_all(bind=engine)
    session = SessionLocal()
    summaries: list[str] = []
    try:
        _, owner = get_or_create_account(session, OWNER_EMAIL, AccountRole.OWNER, "QA 농장주", "010-9000-0000")
        farm = get_or_create_farm(session, owner)
        product = get_or_create_product(session, farm)

        customers = []
        for index, email in enumerate(CUSTOMER_EMAILS, start=1):
            _, customer = get_or_create_account(session, email, AccountRole.CUSTOMER, f"QA 고객 {index}", f"010-1000-000{index}")
            customers.append(customer)

        for customer_index, customer in enumerate(customers, start=1):
            for scenario_index, scenario in enumerate(FLOW_SCENARIOS, start=1):
                summaries.append(apply_scenario(session, customer, farm, product, owner, customer_index, scenario_index, scenario))

        session.commit()
    except Exception:
        session.rollback()
        raise
    finally:
        session.close()

    print("QA customer flow seed completed.")
    print(f"Login password for QA accounts: {QA_PASSWORD}")
    for summary in summaries:
        print(f"- {summary}")


if __name__ == "__main__":
    main()
