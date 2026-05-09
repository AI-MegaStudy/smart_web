from fastapi import HTTPException
from sqlalchemy.orm import Session

from backend.app.models.account import CustomerProfile
from backend.app.repositories.account_repo import AccountRepository


class AddressService:
    def __init__(self, session: Session):
        self.session = session
        self.account_repo = AccountRepository(session)

    def list_my_addresses(self, account_id: int) -> list[dict]:
        profile = self._get_customer_profile(account_id)
        if not profile.default_shipping_address:
            return []
        return [self._serialize(profile)]

    def save_default_address(self, account_id: int, payload: dict) -> dict:
        profile = self._get_customer_profile(account_id)
        profile.default_receiver_name = payload["receiver_name"]
        profile.default_receiver_phone = payload["receiver_phone"]
        profile.default_shipping_address = self._format_address(payload)
        self.session.commit()
        self.session.refresh(profile)
        return self._serialize(profile, payload)

    def update_default_address(self, account_id: int, address_id: int, payload: dict) -> dict:
        profile = self._get_customer_profile(account_id)
        self._ensure_default_address_id(profile, address_id)
        return self.save_default_address(account_id, payload)

    def set_default_address(self, account_id: int, address_id: int) -> dict:
        profile = self._get_customer_profile(account_id)
        self._ensure_default_address_id(profile, address_id)
        return self._serialize(profile)

    def clear_default_address(self, account_id: int, address_id: int) -> dict:
        profile = self._get_customer_profile(account_id)
        self._ensure_default_address_id(profile, address_id)
        profile.default_receiver_name = None
        profile.default_receiver_phone = None
        profile.default_shipping_address = None
        self.session.commit()
        return {"deleted": True}

    def _get_customer_profile(self, account_id: int) -> CustomerProfile:
        account = self.account_repo.get_account(account_id)
        if not account or not account.customer_profile:
            raise HTTPException(status_code=404, detail="customer profile not found")
        return account.customer_profile

    @staticmethod
    def _ensure_default_address_id(profile: CustomerProfile, address_id: int) -> None:
        if address_id != profile.customer_id:
            raise HTTPException(status_code=404, detail="address not found")

    @staticmethod
    def _format_address(payload: dict) -> str:
        zip_code = (payload.get("zip_code") or "").strip()
        address = payload["address"].strip()
        detail = (payload.get("detail_address") or "").strip()
        prefix = f"({zip_code}) " if zip_code else ""
        suffix = f" {detail}" if detail else ""
        return f"{prefix}{address}{suffix}"

    @staticmethod
    def _serialize(profile: CustomerProfile, payload: dict | None = None) -> dict:
        return {
            "address_id": profile.customer_id,
            "address_label": (payload or {}).get("address_label") or "기본 배송지",
            "receiver_name": profile.default_receiver_name or profile.customer_name,
            "receiver_phone": profile.default_receiver_phone or profile.customer_phone,
            "zip_code": (payload or {}).get("zip_code") or "",
            "address": profile.default_shipping_address or "",
            "detail_address": (payload or {}).get("detail_address") or "",
            "delivery_memo": (payload or {}).get("delivery_memo") or "문 앞에 놓아주세요",
            "is_default": True,
            "is_recent": False,
        }
