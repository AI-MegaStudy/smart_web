#!/usr/bin/env python
import sys
from datetime import date, datetime, timedelta

sys.path.insert(0, '.')

from sqlalchemy import inspect, select

from backend.app.core.database import Base, engine
from backend.app.core.security import hash_password
from backend.app.core.status import (
    AccountRole,
    AccountStatus,
    HarvestSlotStatus,
    ProductStatus,
)
from backend.app.models import Account, CustomerProfile, Farm, HarvestSlot, OwnerProfile, Product
from backend.app.core.database import SessionLocal

print('Creating database tables...')
Base.metadata.create_all(engine)
print('Tables created successfully!')

with SessionLocal() as session:
    test_account = session.execute(
        select(Account).where(Account.email == 'aaa@gmail.com')
    ).scalar_one_or_none()
    if not test_account:
        test_account = Account(
            email='aaa@gmail.com',
            password_hash=hash_password('qwer1234'),
            role=AccountRole.CUSTOMER,
            status=AccountStatus.ACTIVE,
            email_verified=True,
        )
        session.add(test_account)
        session.flush()
        session.add(
            CustomerProfile(
                account_id=test_account.account_id,
                customer_name='테스트 고객',
                customer_phone='010-1234-5678',
                default_receiver_name='테스트 고객',
                default_receiver_phone='010-1234-5678',
                default_shipping_address='서울시 강남구 테헤란로 123',
                marketing_agree=False,
            )
        )

    owner_account = session.execute(
        select(Account).where(Account.email == 'owner@example.com')
    ).scalar_one_or_none()
    if not owner_account:
        owner_account = Account(
            email='owner@example.com',
            password_hash=hash_password('qwer1234'),
            role=AccountRole.OWNER,
            status=AccountStatus.ACTIVE,
            email_verified=True,
        )
        session.add(owner_account)
        session.flush()
        owner_profile = OwnerProfile(
            account_id=owner_account.account_id,
            owner_name='청송 예은농장',
            owner_phone='010-9876-5432',
            business_number='123-45-67890',
        )
        session.add(owner_profile)
        session.flush()
    else:
        owner_profile = owner_account.owner_profile

    farm = session.execute(
        select(Farm).where(Farm.farm_name == '청송 예은농장')
    ).scalar_one_or_none()
    if not farm:
        farm = Farm(
            owner_id=owner_profile.owner_id,
            farm_name='청송 예은농장',
            farm_region='경북 청송',
            farm_address='경상북도 청송군 현서면 수확로 10',
            farm_image_url='https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6',
            farm_description='당도와 신선도를 기준으로 수확 일정을 확정하는 산지 직송 농장입니다.',
            delivery_policy='수확 후 선별하여 순차 발송합니다.',
            return_policy='상품 이상 시 수령 후 24시간 내 문의해 주세요.',
        )
        session.add(farm)
        session.flush()

    seed_products = [
        ('청송 햇사과 예약박스', '사과', '부사', 3.0, 39900),
        ('제주 감귤 산지직송 박스', '감귤', '노지감귤', 5.0, 32900),
        ('나주 신고배 수확예약', '배', '신고', 5.0, 45900),
    ]
    for index, (name, fruit_type, variety, unit_kg, price) in enumerate(seed_products, start=1):
        product = session.execute(
            select(Product).where(Product.product_name == name)
        ).scalar_one_or_none()
        if not product:
            product = Product(
                farm_id=farm.farm_id,
                product_name=name,
                fruit_type=fruit_type,
                variety=variety,
                package_unit_kg=unit_kg,
                base_price=price,
                product_status=ProductStatus.ACTIVE,
                image_url=f'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?seed={index}',
                product_description='농가가 확정한 수확 예정 범위에 맞춰 예약 후 받아보는 상품입니다.',
            )
            session.add(product)
            session.flush()

        open_slot = session.execute(
            select(HarvestSlot).where(
                HarvestSlot.product_id == product.product_id,
                HarvestSlot.slot_status == HarvestSlotStatus.OPEN,
            )
        ).scalar_one_or_none()
        if not open_slot:
            session.add(
                HarvestSlot(
                    farm_id=farm.farm_id,
                    product_id=product.product_id,
                    confirmed_harvest_start=date.today() + timedelta(days=7 + index),
                    confirmed_harvest_end=date.today() + timedelta(days=10 + index),
                    confirmed_reservable_kg=500,
                    reserved_kg=0,
                    sold_kg=0,
                    confirmed_price=price,
                    customer_notice='기상과 생육 상황에 따라 일정이 조정될 수 있습니다.',
                    slot_status=HarvestSlotStatus.OPEN,
                    owner_confirmed_at=datetime.utcnow(),
                    opened_at=datetime.utcnow(),
                )
            )

    session.commit()
    print('Seed data is ready!')

tables = [(name,) for name in inspect(engine).get_table_names()]
print('Available tables:')
for table in tables:
    print(f'  - {table[0]}')

print('\nDatabase initialization complete!')
