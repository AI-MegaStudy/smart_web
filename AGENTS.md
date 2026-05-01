# SMART_DOCS / SMART_WEB 작업 규칙

이 저장소와 연결된 `SMART_WEB` 작업을 할 때 Codex는 반드시 이 문서를 먼저 확인하고, 아래 기준에서 벗어나지 않는다.

## 1. 프로젝트 목표

`SMART_WEB`의 목표는 Harvest Slot 사용자 예약 웹을 Flutter Web으로 구현하는 것이다.

사용자 웹 담당 범위는 다음이다.

- 사용자 웹 디자인 구현
- 사용자 웹 화면 기능 구현
- 기획서 범위 안에서 필요한 사용자 편의 기능 제안 및 구현
- 백엔드 담당자에게 필요한 API 연결 지점 정리

관리자 앱, 백엔드, 머신러닝, 딥러닝 자체 구현은 사용자 웹 담당 범위가 아니다. 단, 사용자 웹 화면이 연결해야 하는 데이터와 상태는 이해하고 반영한다.

## 2. 반드시 참고할 문서

작업 전 목적에 맞게 아래 문서를 확인한다.

- 사용자 웹 요구사항: `00_harvest_slot_docs_v3_2/05_사용자_예약웹_기획서.md`
- 사용자 웹 화면 정의: `00_harvest_slot_docs_v3_2/06_사용자_예약웹_화면설계_기능정의서.md`
- API 연결: `00_harvest_slot_docs_v3_2/09_API_설계서.md`
- DB 필드 확인: `00_harvest_slot_docs_v3_2/10_DB_ERD_설계서.md`
- Flutter 구현 기준: `00_harvest_slot_docs_v3_2/15_Flutter_사용자웹_구현가이드.md`
- 디자인 기준: `00_harvest_slot_docs_v3_2/17_디자인시스템_UIUX가이드.md`
- QA 기준: `00_harvest_slot_docs_v3_2/18_테스트_QA_시나리오.md`
- 웹 프로토타입: `01_web_prototype/prototype_user_web_m3/index.html`
- 웹 프로토타입 페이지: `01_web_prototype/prototype_user_web_m3/pages/`
- 웹 요약 문서: `사용자웹_필요정보_정리.md`

## 3. 구현 위치

실제 Flutter Web 구현은 `C:\Users\User_KO\Documents\GitHub\smart_web`에서 진행한다.

`SMART_DOCS`는 기획, 프로토타입, 규칙, 참고 자료 저장소로 본다.

## 4. 언어 규칙

- 변수명, 함수명, 클래스명, 파일명은 영어를 사용해도 된다.
- 화면에 보이는 문구, 주석성 문서, README, 커밋 설명 요청 결과는 한글을 우선 사용한다.
- 고객 화면에는 개발자용 상태 코드, DB 테이블명, API 경로를 직접 노출하지 않는다.
- 고객 화면에는 ML 예측값을 직접 노출하지 않는다.

## 5. 아키텍처 규칙

`SMART_WEB/lib`는 MVVM 기준으로 구성한다.

```text
lib/
  app/
  core/
  data/
    models/
    repositories/
  domain/
  presentation/
    view_models/
    views/
    widgets/
```

규칙:

- View는 화면 표시와 사용자 입력 전달만 담당한다.
- View에서 API를 직접 호출하지 않는다.
- ViewModel은 화면 상태, 검증, Repository 호출을 담당한다.
- Repository는 API 호출과 데이터 변환을 담당한다.
- Model은 API 요청, 응답, 화면 데이터 구조를 담당한다.

## 6. 사용자 웹 핵심 흐름

아래 흐름을 깨지 않게 구현한다.

```text
홈
→ 상품 목록
→ 상품 상세
→ 수확 슬롯 선택
→ 로컬 예약함
→ 예약 확인
→ 서버 예약 생성
→ 주문서 작성
→ Mock 결제
→ 주문 완료
→ 주문 상세 확인
→ 배송 확인
→ 반품 신청
```

## 7. API 연결 규칙

Base URL은 `/api/v1` 기준으로 둔다.

인증이 필요한 API는 아래 헤더를 사용한다.

```text
Authorization: Bearer <access_token>
```

주요 연결:

- `POST /auth/customers/signup`
- `POST /auth/email/verify`
- `POST /auth/email/resend`
- `POST /auth/login`
- `GET /me`
- `GET /products?featured=true`
- `GET /products`
- `GET /products/{product_id}`
- `GET /products/{product_id}/slots`
- `POST /reservations/preview`
- `POST /reservations`
- `POST /orders/from-reservation`
- `POST /payments/mock-approve`
- `GET /me/orders`
- `GET /me/orders/{order_id}`
- `GET /me/orders/{order_id}/shipment`
- `POST /returns`

## 8. 예약함 규칙

- 로컬 예약함은 서버 저장 전 단계다.
- 브라우저 저장소와 Flutter 상태로 관리한다.
- 예약 생성 전까지 서버에 예약 기록을 만들지 않는다.
- 수량은 `package_count * package_unit_kg`로 계산한다.
- 고객이 kg를 직접 입력하는 흐름은 만들지 않는다.
- 최종 수량과 가격 검증은 서버 예약 생성 API에서 처리한다.

## 9. 디자인 규칙

디자인 키워드:

- 신선함
- 정직한 농가
- 예약 안정성
- 수확 직배송
- 명확한 상태 안내

공통 컴포넌트:

- `ProductCard`
- `HarvestSlotCard`
- `StatusBadge`
- `PriceText`
- `NoticeBox`
- `FormSection`

상품 상세, 예약 확인, 주문 상세에는 수확 일정 변동 가능성을 안내한다.

권장 문구:

```text
농가가 확정한 수확 예정 범위입니다.
기상과 생육 상황에 따라 일정이 조정될 수 있습니다.
```

## 10. 상태 표시 규칙

서버 상태 코드는 고객 화면에서 한글로 표시한다.

| 서버 상태 | 고객 표시 |
|---|---|
| `PAYMENT_PENDING` | 결제 대기 |
| `PAID` | 결제 완료 |
| `PROCUREMENT_REQUESTED` | 농가 확인 중 |
| `PROCUREMENT_APPROVED` | 농가 승인 완료 |
| `PROCUREMENT_PARTIAL_APPROVED` | 일부 수량 확인 필요 |
| `PROCUREMENT_REJECTED` | 농가 승인 불가 |
| `QUALITY_CHECKING` | 선별 중 |
| `READY_TO_SHIP` | 발송 준비 |
| `SHIPPED` | 배송 중 |
| `DELIVERED` | 배송 완료 |
| `RETURN_REQUESTED` | 반품 요청 접수 |
| `REFUNDED` | 환불 완료 |

## 11. 추가 기능 판단 기준

기획서에 없는 기능을 추가할 때는 아래 조건을 모두 만족해야 한다.

- 사용자 예약, 주문, 배송 확인 흐름을 더 명확하게 만든다.
- 기존 API 또는 작은 응답 필드 추가로 구현 가능하다.
- 백엔드 담당자에게 연결 요구사항을 설명할 수 있다.
- 관리자 앱, ML, DL 담당자의 범위를 침범하지 않는다.

권장 추가 기능:

- 예약 만료 카운트다운
- 기본 배송지 선택
- 잔여 수량 적음 배지
- 주문 상태 타임라인
- 반품 가능 조건 안내

## 12. Codex 사용 규칙

Codex에게 작업을 요청할 때는 다음처럼 요청한다.

```text
AGENTS.md와 사용자웹_필요정보_정리.md를 먼저 읽고, SMART_WEB에서 사용자 웹의 상품 목록 화면을 MVVM 구조로 구현해줘. 화면 문구는 한글로 유지해줘.
```

디자인 시안이나 발표용 HTML을 개선할 때만 `huashu-design`을 사용한다.

```text
huashu-design으로 사용자 웹 예약 확인 화면을 발표용 HTML 프로토타입으로 개선해줘.
```

실제 Flutter 운영 코드 구현은 `huashu-design`보다 이 규칙 문서와 Flutter 구현 가이드를 우선한다.
