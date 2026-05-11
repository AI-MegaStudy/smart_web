from __future__ import annotations

from datetime import timedelta
from pathlib import Path
import sys


PROJECT_ROOT = Path(__file__).resolve().parents[1]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from backend.app.core.database import SessionLocal
from backend.app.core.status import HarvestSlotStatus
from backend.app.models import Farm, HarvestSlot, Product, Reservation


BUSAN_PRODUCT_NAME = "충주 햇살 부사 사과"
YANGGWANG_PRODUCT_NAME = "충주 햇살 양광 사과"
YANGGWANG_PRICE = 34000
YANGGWANG_PACKAGE_KG = 5.0


def get_farm(session) -> Farm:
    farm = session.query(Farm).filter(Farm.farm_name == "문경 햇살 농장").one_or_none()
    if farm:
        return farm
    farm = session.query(Farm).first()
    if not farm:
        raise RuntimeError("farm data is required before adding yanggwang demo data")
    return farm


def get_or_create_yanggwang_product(session, farm: Farm) -> Product:
    product = (
        session.query(Product)
        .filter(Product.product_name.in_([YANGGWANG_PRODUCT_NAME, "충주 햇살 신고사과", "충주 햇살 신고 사과"]))
        .one_or_none()
    )
    if product:
        product.product_name = YANGGWANG_PRODUCT_NAME
        product.fruit_type = "APPLE"
        product.variety = "양광"
        product.package_unit_kg = YANGGWANG_PACKAGE_KG
        product.base_price = YANGGWANG_PRICE
        product.product_status = "ACTIVE"
        product.product_description = "과즙이 풍부하고 산뜻한 단맛이 좋은 충주 양광 사과입니다."
        return product

    product = Product(
        farm_id=farm.farm_id,
        product_name=YANGGWANG_PRODUCT_NAME,
        fruit_type="APPLE",
        variety="양광",
        package_unit_kg=YANGGWANG_PACKAGE_KG,
        base_price=YANGGWANG_PRICE,
        product_status="ACTIVE",
        image_url="https://images.unsplash.com/photo-1570913149827-d2ac84ab3f9a",
        product_description="과즙이 풍부하고 산뜻한 단맛이 좋은 충주 양광 사과입니다.",
    )
    session.add(product)
    session.flush()
    return product


def get_or_create_yanggwang_slot(session, farm: Farm, product: Product, source_slot: HarvestSlot, sequence: int) -> HarvestSlot:
    slot = (
        session.query(HarvestSlot)
        .filter(
            HarvestSlot.product_id == product.product_id,
            HarvestSlot.confirmed_harvest_start == source_slot.confirmed_harvest_start,
        )
        .one_or_none()
    )
    if slot:
        slot.confirmed_price = YANGGWANG_PRICE
        slot.customer_notice = "농가가 확정한 양광 사과 수확 예정 범위입니다."
        slot.slot_status = HarvestSlotStatus.OPEN
        return slot

    slot = HarvestSlot(
        farm_id=farm.farm_id,
        product_id=product.product_id,
        prediction_id=None,
        confirmed_harvest_start=source_slot.confirmed_harvest_start,
        confirmed_harvest_end=source_slot.confirmed_harvest_end or source_slot.confirmed_harvest_start + timedelta(days=2),
        confirmed_reservable_kg=500.0,
        reserved_kg=0.0,
        sold_kg=0.0,
        confirmed_price=YANGGWANG_PRICE,
        customer_notice=f"농가가 확정한 양광 사과 수확 예정 범위입니다. 순번 {sequence:02d}",
        slot_status=HarvestSlotStatus.OPEN,
        owner_confirmed_at=source_slot.owner_confirmed_at,
        opened_at=source_slot.opened_at,
        closed_at=source_slot.closed_at,
    )
    session.add(slot)
    session.flush()
    return slot


def reservation_index(reservation: Reservation) -> int | None:
    digits = "".join(ch for ch in reservation.reservation_no if ch.isdigit())
    if len(digits) < 2:
        return None
    return int(digits[-2:])


def recalculate_money(session, reservation: Reservation) -> None:
    total_kg = 0.0
    total_amount = 0
    for item in reservation.reservation_items:
        slot = session.get(HarvestSlot, item.slot_id)
        if not slot:
            continue
        item.unit_price_snapshot = slot.confirmed_price
        item.subtotal_amount = item.package_count * item.unit_price_snapshot
        item.reserved_kg = round(item.package_count * float(slot.product.package_unit_kg), 2)
        total_kg += float(item.reserved_kg)
        total_amount += item.subtotal_amount

        if item.order_item:
            item.order_item.unit_price = item.unit_price_snapshot
            item.order_item.subtotal_amount = item.subtotal_amount
            item.order_item.ordered_kg = item.reserved_kg

    reservation.total_reserved_kg = round(total_kg, 2)
    reservation.total_amount = total_amount

    order = reservation.order
    if not order:
        return
    order.total_amount = total_amount
    for payment in order.payments:
        payment.requested_amount = total_amount
        if payment.approved_amount:
            payment.approved_amount = total_amount
    if order.return_request:
        order.return_request.requested_amount = total_amount
        if order.return_request.approved_amount:
            order.return_request.approved_amount = total_amount
        if order.return_request.refund:
            order.return_request.refund.requested_amount = total_amount
            if order.return_request.refund.refunded_amount:
                order.return_request.refund.refunded_amount = total_amount
    if order.shipment:
        order.shipment.shipped_package_count = sum(item.package_count for item in order.order_items)
        order.shipment.shipped_kg = round(sum(float(item.ordered_kg) for item in order.order_items), 2)


def mix_yanggwang_into_existing_flow(session, farm: Farm, product: Product) -> int:
    changed = 0
    reservations = (
        session.query(Reservation)
        .filter(Reservation.reservation_no.like("RSV-202605%"))
        .order_by(Reservation.reservation_no)
        .all()
    )
    for reservation in reservations:
        index = reservation_index(reservation)
        if index is None or index % 2 != 0:
            continue
        for item in reservation.reservation_items:
            source_slot = item.slot
            if not source_slot:
                continue
            yanggwang_slot = get_or_create_yanggwang_slot(session, farm, product, source_slot, index)
            if source_slot.product_id != product.product_id:
                source_slot.reserved_kg = max(0.0, round(float(source_slot.reserved_kg) - float(item.reserved_kg), 2))
                source_slot.sold_kg = max(0.0, round(float(source_slot.sold_kg) - float(item.reserved_kg), 2))
                item.slot_id = yanggwang_slot.slot_id
                item.unit_price_snapshot = YANGGWANG_PRICE
                yanggwang_slot.reserved_kg = round(float(yanggwang_slot.reserved_kg) + float(item.reserved_kg), 2)
                if reservation.order:
                    yanggwang_slot.sold_kg = round(float(yanggwang_slot.sold_kg) + float(item.reserved_kg), 2)
            changed += 1
        session.flush()
        recalculate_money(session, reservation)
    return changed


def main() -> None:
    session = SessionLocal()
    try:
        farm = get_farm(session)
        product = get_or_create_yanggwang_product(session, farm)
        changed = mix_yanggwang_into_existing_flow(session, farm, product)
        session.commit()
    except Exception:
        session.rollback()
        raise
    finally:
        session.close()

    print(f"Shingo apple demo data mixed into existing customer flows: {changed} reservation items updated.")


if __name__ == "__main__":
    main()
