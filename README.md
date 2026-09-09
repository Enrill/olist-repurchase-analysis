# Olist 이커머스 재구매·이탈 분석

Brazilian E-Commerce(Olist) 공개 데이터셋으로 "왜 재구매율이 낮은가"를 SQL과
통계 검정으로 파고든 개인 프로젝트. Google BigQuery + Power BI 사용.

## 1. 질문
Olist 마켓플레이스의 재구매율은 실제로 얼마나 되고, 배송 지연이 재구매에
영향을 주는가?

## 2. 데이터
[Kaggle - Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
(customers, orders, order_items, order_payments, order_reviews, products,
sellers, category_translation 총 8개 테이블)

## 3. 분석 과정 및 함정

**customer_id vs customer_unique_id**: `customer_id`는 주문마다 새로 생성되는
값이라 이걸로 재구매를 계산하면 재구매율이 항상 0%로 나온다. 실제 고객
식별자는 `customer_unique_id`이며, 확인 결과 `customer_id` 99,441개 중 실제
고유 고객은 96,096명(3,345명이 재구매 고객)이었다.

쿼리: [`queries/`](./queries) 폴더 참고
- `01_cohort_retention.sql` — 월별 코호트 리텐션
- `02_status_funnel.sql` — 주문 상태별 이탈 퍼널
- `03_delivery_delay_repurchase.sql` — 배송 지연 vs 재구매

## 4. 결과

| 발견 | 수치 |
|---|---|
| 월별 재구매율 | **1% 미만** (대부분 코호트에서) |
| 실질 주문 이탈(취소+품절) | **1.24%** — 운영 자체는 안정적 |
| 배송 지연 시 재구매율 | 5.48% vs 정시 6.40% (**상대적으로 14% 낮음**) |
| 통계적 유의성 | χ² = 10.15, **p = 0.0014** (유의미) |

카이제곱 검정: [`analysis/chi_square_test.py`](./analysis/chi_square_test.py)

## 5. 해석 및 제안

- 취소율이 낮은데도 재구매율이 낮다는 건, **운영 문제가 아니라 리텐션 설계
  부재**가 원인일 가능성이 높다.
- 배송 지연이 재구매율에 통계적으로 유의미한 영향을 주므로, **배송 SLA
  관리**와 **재구매 유도 프로모션**(첫 구매 후 N일 리마인드 쿠폰 등)을
  우선순위로 제안한다.

## 6. 대시보드
[`dashboard/`](./dashboard) 폴더에 Power BI 파일(.pbix)과 스크린샷 포함 —
코호트 리텐션 히트맵, 주문 상태 퍼널, 배송지연-재구매율 비교 3개 패널.

## 사용 도구
Google BigQuery(SQL) · Python(scipy) · Power BI
