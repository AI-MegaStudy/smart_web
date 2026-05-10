from __future__ import annotations

import sys
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parents[1]
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

from backend.app.core.database import SessionLocal
from backend.app.models import Farm, HarvestSlot, MLPrediction, Procurement, Product

PRIMARY_FARM_NAME = "문경 햇살 농장"
PRIMARY_REGION = "경북 문경"
PRIMARY_ADDRESS = "경북 문경시 산북면 과수원길 27"
PRIMARY_DESCRIPTION = "문경 산지에서 수확한 사과를 예약 일정에 맞춰 보내드립니다."


def main() -> None:
    session = SessionLocal()
    try:
        primary = (
            session.query(Farm)
            .filter(Farm.farm_name == PRIMARY_FARM_NAME)
            .order_by(Farm.farm_id)
            .first()
        )
        if primary is None:
            primary = session.query(Farm).order_by(Farm.farm_id).first()
            if primary is None:
                raise RuntimeError("No farm row exists.")

        primary.farm_name = PRIMARY_FARM_NAME
        primary.farm_region = PRIMARY_REGION
        primary.farm_address = PRIMARY_ADDRESS
        primary.farm_description = PRIMARY_DESCRIPTION

        primary_id = primary.farm_id

        session.query(Product).update({Product.farm_id: primary_id}, synchronize_session=False)
        session.query(HarvestSlot).update({HarvestSlot.farm_id: primary_id}, synchronize_session=False)
        session.query(Procurement).update({Procurement.farm_id: primary_id}, synchronize_session=False)
        session.query(MLPrediction).update({MLPrediction.farm_id: primary_id}, synchronize_session=False)

        duplicate_farms = (
            session.query(Farm)
            .filter(Farm.farm_id != primary_id)
            .order_by(Farm.farm_id)
            .all()
        )
        for farm in duplicate_farms:
            session.delete(farm)

        session.commit()

        print(f"primary_farm_id={primary_id}")
        print(f"primary_farm_name={PRIMARY_FARM_NAME}")
        print(f"deleted_duplicate_farms={len(duplicate_farms)}")
    except Exception:
        session.rollback()
        raise
    finally:
        session.close()


if __name__ == "__main__":
    main()
