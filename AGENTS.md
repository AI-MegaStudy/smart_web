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

## 5.1 SMART_WEB 내부 백엔드 연동 규칙

2026-05-09 기준 `SMART_WEB` 저장소 안에 백엔드 코드가 포함되어 있다.

백엔드 위치:

```text
C:\Users\User_KO\Documents\GitHub\smart_web\backend
```

이 백엔드는 FastAPI 기반이며, 사용자 웹과 연결할 때 아래 기준을 따른다.

- FastAPI 앱 진입점은 `backend.app.main:app`이다.
- API Base URL은 `/api/v1`이다.
- 로컬 개발 기본 주소는 `http://localhost:8000/api/v1`로 본다.
- Swagger 확인 주소는 `http://localhost:8000/docs`이다.
- DB 연결은 `backend/app/core/config.py` 기준 MySQL 계열이다.
- DB URL은 `mysql+pymysql://<user>:<password>@<host>:3306/harvest_slot_db?charset=utf8mb4` 형태로 조합된다.
- 로컬 MySQL, 팀 공용 MySQL, AWS RDS MySQL 모두 환경변수 설정으로 연결 가능하다.

백엔드 코드는 사용자 요청이 명확히 있을 때만 수정한다. 사용자 웹 담당 작업에서는 기본적으로 백엔드 코드를 직접 고치지 않고, `SMART_WEB/lib`의 Repository와 ViewModel을 백엔드 API에 맞춰 연결한다.

프론트 연결 시 반드시 지킬 기준:

- View에서 FastAPI를 직접 호출하지 않는다.
- API 호출은 Repository에서 처리한다.
- ViewModel은 Repository를 통해 데이터를 가져오고 화면 상태만 관리한다.
- 백엔드 응답은 `{ data, message, error }` 구조이므로 Repository에서 `data`를 꺼내 화면 모델로 변환한다.
- 인증이 필요한 API는 `Authorization: Bearer <access_token>` 헤더를 사용한다.
- 백엔드 상태 코드는 사용자 화면에서 한글 표시로 변환한다.
- 고객 화면에 API 경로, DB 필드명, 내부 상태 코드를 직접 노출하지 않는다.

현재 사용자 웹과 바로 연결 가능한 주요 API:

- `POST /auth/customers/signup`
- `POST /auth/email/send`
- `POST /auth/email/resend`
- `POST /auth/email/verify`
- `GET /auth/email/status`
- `POST /auth/login`
- `GET /me`
- `GET /products?featured=true`
- `GET /products`
- `GET /products/{product_id}`
- `GET /products/{product_id}/slots`
- `POST /reservations/preview`
- `POST /reservations`
- `GET /me/reservations`
- `POST /orders/from-reservation`
- `POST /payments/mock-approve`
- `GET /me/orders`
- `GET /me/orders/{order_id}`
- `GET /me/orders/{order_id}/payments`
- `GET /me/orders/{order_id}/shipment`
- `POST /returns`
- `GET /me/returns`

아직 백엔드 협의가 필요한 부분:

- 여러 배송지 관리 API: 관련 필드는 있으나 API가 없으므로 프론트 담당자가 백엔드에 직접 추가한다.
- 회원정보 수정 API: `PUT /me`
- 일부 백엔드 문서와 스키마 예시의 한글 깨짐 정리

팀장 컨펌 반영 결정사항:

- 배송지 관리는 `CustomerProfile`의 기본 배송지 필드만으로는 부족하므로 `GET/POST/PUT/DELETE /me/addresses`, `PATCH /me/addresses/{address_id}/default` 계열 API를 직접 추가해서 연결한다.
- 고객센터와 푸터 정보는 DB에 없으므로 `GET /service-info` 같은 API를 만들지 않고 프론트 더미 데이터로 유지한다.
- 푸터 전화번호, 이메일, 운영 시간은 사용자 웹 화면에서 정적 데이터로 관리한다.

관련 정리 문서:

- `docs/ksm/백엔드_내장구조_연동정리_2026-05-09.md`
- `docs/ksm/백엔드_SMART_WEB_연결검토_2026-05-08.md`

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

## 13. Karpathy-style AI 코딩 지침

아래 지침은 AI 코딩 작업의 실수를 줄이기 위한 보조 규칙이다. 이 지침과 위의 `SMART_WEB` 프로젝트 규칙이 충돌하면 반드시 기존 프로젝트 규칙을 우선한다.

핵심 목표:

- 애매한 요구를 혼자 추측하지 않고, 필요한 가정과 불확실성을 드러낸다.
- 필요 이상으로 복잡한 코드, 추상화, 설정 옵션을 만들지 않는다.
- 요청과 직접 관련 없는 파일, 포맷, 변수명, 구조를 임의로 바꾸지 않는다.
- 성공 기준을 명확히 정하고 테스트 또는 수동 검증으로 확인한다.

### 13.1 Think Before Coding

- 구현 전에 요구사항을 어떻게 이해했는지 짧게 정리한다.
- 확실하지 않은 부분은 가정으로 명시한다.
- 가능한 해석이 여러 개라면 선택지와 tradeoff를 말한다.
- 결과에 영향을 주는 애매함이 있으면 구현 전에 질문한다.
- 더 단순하거나 더 안전한 접근이 있으면 먼저 알린다.

### 13.2 Simplicity First

- 요청한 문제를 해결하는 가장 단순한 코드를 작성한다.
- 요청받지 않은 기능을 추가하지 않는다.
- 한 번만 쓰는 코드를 새 추상화로 만들지 않는다.
- 미래 확장성만을 이유로 설정 옵션, 플러그인 구조, 범용 프레임워크를 만들지 않는다.
- 기존 코드베이스의 패턴과 helper를 우선 사용한다.
- 외부 입력, 사용자 입력, 네트워크 응답은 필요한 만큼 검증한다.

### 13.3 Surgical Changes

- 요청과 직접 관련된 파일과 줄만 수정한다.
- 관련 없는 리팩토링, 포맷 변경, 주석 수정, 변수명 변경을 하지 않는다.
- 기존 코드 스타일을 따른다.
- 관련 없는 dead code나 문제를 발견해도 임의로 수정하지 않고 마지막에 언급만 한다.
- 내 변경으로 생긴 unused import, unused variable, orphan code는 정리한다.

### 13.4 Goal-Driven Execution

- 작업을 시작할 때 성공 기준을 명확히 정리한다.
- 가능하면 테스트를 먼저 추가하거나 기존 테스트로 현재 문제를 확인한다.
- 버그 수정은 재현, 실패 확인, 수정, 통과 확인 순서로 진행한다.
- 테스트가 어려우면 수동 검증 절차를 명확히 적고 그 기준으로 확인한다.
- 완료 답변에는 변경 요약과 검증 결과를 포함한다.

### 13.5 Recommended Full Instruction

```text
이 작업은 Karpathy-style AI coding guidelines를 따라 진행해줘.

1. Think Before Coding
- 바로 구현하지 말고 먼저 요구사항 이해, 가정, 애매한 부분을 짧게 정리해줘.
- 해석이 여러 개면 선택지를 말하고 tradeoff를 설명해줘.
- 결과에 영향을 주는 애매함이 있으면 구현 전에 질문해줘.

2. Simplicity First
- 요청한 문제를 해결하는 가장 단순한 코드를 작성해줘.
- 요청하지 않은 기능, 미래 확장성을 위한 구조, 한 번만 쓰는 추상화는 추가하지 마.
- 기존 코드베이스의 패턴과 helper를 우선 사용해줘.

3. Surgical Changes
- 요청과 직접 관련된 파일과 줄만 수정해줘.
- 관련 없는 리팩토링, 포맷 변경, 주석 수정, 변수명 변경은 하지 마.
- 네 변경으로 생긴 unused import나 orphan code만 정리해줘.
- 관련 없는 문제를 발견하면 수정하지 말고 마지막에 언급해줘.

4. Goal-Driven Execution
- 성공 기준을 먼저 정리해줘.
- 가능하면 테스트 또는 재현 방법으로 현재 문제를 확인해줘.
- 최소 변경으로 구현한 뒤 테스트나 수동 검증으로 성공 기준을 확인해줘.
- 완료 답변에는 변경 요약과 검증 결과를 포함해줘.
```
