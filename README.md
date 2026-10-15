# Harvest Slot

수확 예측 데이터를 바탕으로 과수 농가와 고객의 예약·직배송을 연결하는 플랫폼입니다.

> AI-MegaStudy 팀 파이널 프로젝트입니다. 이 저장소는 Flutter 웹 프론트엔드와 FastAPI 백엔드 연동을 포함합니다. 개인 기여는 팀 전체 구현 내용과 구분해 확인 가능한 범위에서 기록합니다.

## 프로젝트 개요

기존 농산물 유통 과정에서 발생하는 수확 시기와 수요 예측의 불확실성을 줄이고, 농가의 수확·판매 관리와 고객의 구매 경험을 연결하는 것을 목표로 합니다.

## 주요 기능

- **고객 서비스:** 과일 정보 탐색, 상품 확인 및 예약·주문 흐름
- **농가 관리:** 수확·판매 관련 정보와 예약 현황 관리
- **수확량 예측:** 데이터 기반 예측 결과를 서비스 흐름에 활용
- **과일 품질 분석:** 이미지 기반 품질 등급 분류 및 결과 활용
- **날씨 데이터 활용:** 기상 데이터를 예측 관련 피처로 구성
- **API 기반 연동:** 프론트엔드와 백엔드 사이에 공통 응답 구조를 사용

※ 기능별 구현 범위는 현재 코드와 발표자료를 함께 확인해 정리했습니다. 모델의 배포·운영 상태는 실행 환경에 따라 달라질 수 있습니다.

## 기술 스택

### Frontend
- **Flutter / Dart** — 고객용 웹 화면 및 사용자 인터페이스
- **HTTP / REST API** — 백엔드 API 호출
- **Provider** — 발표자료에 기재된 상태 관리 방식
- **SharedPreferences** — 발표자료에 기재된 로컬 저장 방식

### Backend
- **Python / FastAPI** — REST API 서버
- **SQLAlchemy** — ORM 및 데이터베이스 접근
- **MySQL** — 서비스 데이터 저장
- **Pydantic / pydantic-settings** — 요청·응답 검증 및 환경 설정
- **JWT / bcrypt** — 인증 토큰 및 비밀번호 해시 처리
- **python-multipart** — 파일 업로드 요청 처리
- **Uvicorn** — ASGI 서버 실행

### Data / Machine Learning
- **pandas / NumPy** — 데이터 처리
- **scikit-learn** — 수확량 예측을 위한 머신러닝
- **joblib** — 학습된 모델 파일 로드 및 활용
- **Deep Learning / ResNet18** — 사과 이미지의 시점 및 품질 등급 분류를 위한 모델 구조(발표자료 기준)

### External Data / Collaboration
- **KMA Weather API** — 기상 데이터 조회
- **Git / Slack** — 버전 관리 및 팀 협업

> 기술 스택은 발표자료와 저장소의 의존성 파일을 교차 확인해 정리했습니다. Supabase와 Vercel은 다른 개인·실습 프로젝트에서 활용한 도구이므로 이 프로젝트의 기술 스택에는 포함하지 않았습니다.

## AI 및 데이터 분석

### 수확량 예측
- 시장 가격 및 기상 관련 데이터를 활용해 수확량 예측에 필요한 피처를 구성합니다.
- 발표자료에서는 수확량 예측과 추천 판매가 제안 결과를 각각 제시합니다.
- 최종 성능 수치는 발표자료의 평가 조건과 함께 해석해야 하며, 실제 서비스 성능을 보장하는 수치로 해석해서는 안 됩니다.

### 이미지 기반 품질 분석
- 사과 이미지의 시점을 먼저 분류한 뒤 품질 등급을 예측하는 단계형 구조를 발표자료에서 설명합니다.
- 데이터 누수를 줄이기 위해 동일 사과 개체 기준으로 데이터를 분리하는 방식이 소개되어 있습니다.
- 모델 결과는 신뢰도와 판정 정책에 따라 재촬영 또는 점주 검토로 연결될 수 있습니다.

## 시스템 구성

```text
Flutter Web
    |
    | REST API
    v
FastAPI
    |------ MySQL (SQLAlchemy)
    |------ ML prediction module (joblib)
    |------ KMA Weather API
    |------ Image / quality-analysis integration
```

## API 및 코드 구조

백엔드는 기능별로 라우터, 서비스, 스키마, 모델, 리포지토리 계층을 분리하는 구조를 사용합니다. API 문서는 개발 환경에서 `/docs` 및 `/redoc` 경로로 확인할 수 있습니다.

## 실행 안내

### Flutter 웹
프로젝트 루트에서:

```bash
flutter pub get
flutter run -d chrome
```

### FastAPI 백엔드
필요한 Python 패키지를 설치하고 환경변수를 설정한 뒤 실행합니다. 데이터베이스, JWT 비밀키, 기상 API 및 파일 업로드 설정은 각 환경에 맞게 구성해야 합니다.

```bash
pip install -r backend/requirements.txt
uvicorn backend.app.main:app --reload
```

실제 실행에는 유효한 환경 설정과 데이터베이스 연결이 필요합니다. 비밀키나 API 자격 증명은 저장소에 직접 올리지 마세요.

## 개인 기여

본 저장소는 팀 프로젝트의 코드 저장소입니다. 개인 포트폴리오에는 실제 담당한 웹 프론트엔드 개발 범위와 확인 가능한 산출물만 별도로 기재합니다. 백엔드·머신러닝 전체를 개인 단독 구현한 것으로 표현하지 않습니다.

## Related repositories

- [smart_dl](https://github.com/AI-MegaStudy/smart_dl) — 딥러닝 관련 코드
- [smart_ml](https://github.com/AI-MegaStudy/smart_ml) — 머신러닝 및 데이터 분석
- [smart_docs](https://github.com/AI-MegaStudy/smart_docs) — 프로젝트 문서
