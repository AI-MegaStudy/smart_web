# 예은 파트 백엔드 연결 및 발표용 표

작성일: 2026-05-01

## 화면별 연결 표

| 화면 | 라우트 | 현재 역할 | 백엔드 연결 필요 데이터 | 발표 시 설명 포인트 |
| --- | --- | --- | --- | --- |
| 홈 | `/` | 예약 가능 상품 진입 화면 | 대표 상품 3개, 수확 예정 범위, 잔여 수량 | 수확 슬롯 기반 예약 서비스의 첫 진입 화면 |
| 상품 목록 | `/products` | 품종/패키지/잔여량 비교 | 상품 목록, 필터 조건, 재고, 가격, 이미지 | 사용자가 수확 예정 범위를 보고 상품을 선택 |
| 상품 상세 | `/product-detail` | 패키지와 수확 슬롯 선택 | 상품 상세, 수확 슬롯별 확정/예약/잔여 수량 | 예약은 상품 단위가 아니라 수확 슬롯 단위로 진행 |
| 예약함 | `/cart` | 선택 상품과 수량 확인 | 예약 임시 저장 목록, 수량, 만료 시간 | 주문 전 예약 보관 단계 |
| 주문서 작성 | `/order-form` | 배송지/주문 정보 입력 | 기본 배송지, 주문 요약, 배송 메모 | 예약을 실제 주문으로 전환 |
| 결제 | `/payment` | 결제 정보 확인 | 결제 금액, 결제 수단, 입금/승인 상태 | 결제 완료 후 예약 확정 흐름 |
| 예약 확인 | `/reservation-confirm` | 예약 주문 완료 안내 | 주문번호, 결제 금액, 예약 상태 | 완료 후 주문 내역에서 추적 가능 |
| 내 주문 | `/orders` | 최근 예약 주문 목록 | 주문 목록, 상태, 금액, 썸네일 | 주문번호 클릭으로 상세 추적 |
| 주문 상세 | `/order-detail` | 주문/결제/배송 진행 상태 | 주문 상태 타임라인, 운송장, 주문 요약 | 결제 완료부터 배송 완료까지 단계별 추적 |
| 반품 신청 | `/return-request` | 배송 완료 주문 반품 요청 | 반품 대상, 사유, 이미지 증빙, 환불 금액 | 배송 완료 이후 예외 처리 흐름 |
| 회원가입 | `/signup` | 가입 정보 입력 | 이메일, 비밀번호, 이름, 전화번호 | 이메일 인증 전 단계 |
| 이메일 인증 | `/email-verification` | 인증번호 확인 | 인증번호 발송/검증 상태 | 가입 신뢰성 확보 |
| 로그인 | `/login` | 사용자 로그인 | 이메일, 비밀번호, 토큰 | 주문/예약 내역 조회를 위한 인증 |
| 예약현황 | `/reservation-status` | 상품별 예약 가능 상태 확인 | 상품별 잔여량, 수확일, 예약 가능 상태 | 관리자/사용자 모두 이해 가능한 상태 요약 |

## 백엔드 API 초안

| 기능 | 메서드 | 예상 엔드포인트 | 요청/응답 핵심 필드 |
| --- | --- | --- | --- |
| 상품 목록 조회 | `GET` | `/api/products` | `id`, `name`, `price`, `imageUrl`, `stockKg`, `harvestDate`, `reservable` |
| 상품 상세 조회 | `GET` | `/api/products/{productId}` | 상품 상세, 패키지 옵션, 수확 슬롯 목록 |
| 수확 슬롯 조회 | `GET` | `/api/products/{productId}/harvest-slots` | `slotId`, `dateRange`, `confirmedKg`, `reservedKg`, `remainingKg` |
| 예약함 조회 | `GET` | `/api/cart` | 예약 상품 목록, 수량, 만료 시간 |
| 예약함 추가/수정 | `POST/PATCH` | `/api/cart/items` | `productId`, `slotId`, `packageKg`, `quantity` |
| 주문 생성 | `POST` | `/api/orders` | 배송지, 배송 메모, 예약함 항목 |
| 결제 처리 | `POST` | `/api/payments` | `orderId`, `amount`, `paymentMethod`, `status` |
| 주문 목록 조회 | `GET` | `/api/orders` | 주문번호, 상태, 금액, 주문일, 썸네일 |
| 주문 상세 조회 | `GET` | `/api/orders/{orderId}` | 진행 단계, 배송 정보, 결제 정보, 주문 요약 |
| 반품 신청 | `POST` | `/api/orders/{orderId}/returns` | 반품 사유, 상세 사유, 증빙 이미지, 요청 금액 |
| 이메일 인증 발송 | `POST` | `/api/auth/email-code` | `email` |
| 이메일 인증 검증 | `POST` | `/api/auth/email-code/verify` | `email`, `code` |
| 로그인 | `POST` | `/api/auth/login` | `email`, `password`, `accessToken` |

## 발표 흐름

1. 상품 목록에서 수확 예정 범위와 잔여 수량을 확인한다.
2. 상품 상세에서 패키지와 수확 슬롯을 선택한다.
3. 예약함에서 수량과 금액을 확인한다.
4. 주문서 작성에서 배송지를 확인하고 주문을 생성한다.
5. 결제 후 예약 확인 화면으로 이동한다.
6. 내 주문과 주문 상세에서 진행 상태를 추적한다.
7. 배송 완료 이후 문제가 있으면 반품 신청으로 예외 처리를 진행한다.

## 현재 구현 상태

| 항목 | 상태 |
| --- | --- |
| UI 화면 흐름 | 구현 완료 |
| 샘플 데이터 | `lib/yeeun/vm/product_view_model.dart`에서 관리 |
| 백엔드 연결 | 미연결 |
| 이미지 | `assets/images/apple*.jpg` 사용 |
| 검증 | `flutter analyze`, `flutter test` 통과 |
