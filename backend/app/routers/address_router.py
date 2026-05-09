from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from backend.app.core.database import get_db
from backend.app.core.security import AuthenticatedUser, require_customer
from backend.app.schemas.address_schema import AddressSaveRequest
from backend.app.schemas.common_schema import success_response
from backend.app.services.address_service import AddressService


router = APIRouter()


@router.get("/me/addresses")
def list_my_addresses(
    current_user: AuthenticatedUser = Depends(require_customer),
    db: Session = Depends(get_db),
) -> dict:
    return success_response(AddressService(db).list_my_addresses(current_user.account_id))


@router.post("/me/addresses")
def create_my_address(
    payload: AddressSaveRequest,
    current_user: AuthenticatedUser = Depends(require_customer),
    db: Session = Depends(get_db),
) -> dict:
    return success_response(AddressService(db).save_default_address(current_user.account_id, payload.model_dump()))


@router.put("/me/addresses/{address_id}")
def update_my_address(
    address_id: int,
    payload: AddressSaveRequest,
    current_user: AuthenticatedUser = Depends(require_customer),
    db: Session = Depends(get_db),
) -> dict:
    return success_response(
        AddressService(db).update_default_address(current_user.account_id, address_id, payload.model_dump())
    )


@router.patch("/me/addresses/{address_id}/default")
def set_default_address(
    address_id: int,
    current_user: AuthenticatedUser = Depends(require_customer),
    db: Session = Depends(get_db),
) -> dict:
    return success_response(AddressService(db).set_default_address(current_user.account_id, address_id))


@router.delete("/me/addresses/{address_id}")
def delete_my_address(
    address_id: int,
    current_user: AuthenticatedUser = Depends(require_customer),
    db: Session = Depends(get_db),
) -> dict:
    return success_response(AddressService(db).clear_default_address(current_user.account_id, address_id))
