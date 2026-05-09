from pydantic import BaseModel, ConfigDict, Field


class AddressSaveRequest(BaseModel):
    address_label: str | None = Field(default=None, json_schema_extra={"example": "내집"})
    receiver_name: str = Field(json_schema_extra={"example": "홍길동"})
    receiver_phone: str = Field(json_schema_extra={"example": "010-1111-2222"})
    zip_code: str | None = Field(default=None, json_schema_extra={"example": "06236"})
    address: str = Field(json_schema_extra={"example": "서울시 강남구 테헤란로 123"})
    detail_address: str | None = Field(default=None, json_schema_extra={"example": "101동 1203호"})
    delivery_memo: str | None = Field(default=None, json_schema_extra={"example": "문 앞에 놓아주세요"})
    is_default: bool = Field(default=True)

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "address_label": "내집",
                "receiver_name": "홍길동",
                "receiver_phone": "010-1111-2222",
                "zip_code": "06236",
                "address": "서울시 강남구 테헤란로 123",
                "detail_address": "101동 1203호",
                "delivery_memo": "문 앞에 놓아주세요",
                "is_default": True,
            }
        }
    )
