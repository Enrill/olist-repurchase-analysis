-- Olist 고객 코호트 리텐션 분석
-- 질문: 고객의 첫 구매월(코호트) 기준으로, 이후 몇 %가 재구매하는가?
--
-- 주의: customer_id는 주문마다 새로 생성되는 값이라 재구매 분석에 쓰면 안 됨.
--       실제 고객 식별자는 customer_unique_id.

WITH orders_casted AS (
  SELECT
    o.order_id,
    o.customer_id,
    c.customer_unique_id,
    CAST(o.order_purchase_timestamp AS TIMESTAMP) AS purchase_ts
  FROM `olist-analysis-507907.olist.orders` o
  JOIN `olist-analysis-507907.olist.customers` c
    ON o.customer_id = c.customer_id
),
first_purchase AS (
  SELECT
    customer_unique_id,
    DATE_TRUNC(DATE(MIN(purchase_ts)), MONTH) AS cohort_month
  FROM orders_casted
  GROUP BY customer_unique_id
),
cohort_raw AS (
  SELECT
    f.cohort_month,
    DATE_TRUNC(DATE(o.purchase_ts), MONTH) AS order_month,
    COUNT(DISTINCT o.customer_unique_id) AS active_customers
  FROM orders_casted o
  JOIN first_purchase f USING (customer_unique_id)
  GROUP BY f.cohort_month, order_month
),
cohort_size AS (
  SELECT cohort_month, active_customers AS cohort_size
  FROM cohort_raw
  WHERE cohort_month = order_month
)
SELECT
  r.cohort_month,
  r.order_month,
  r.active_customers,
  ROUND(r.active_customers / s.cohort_size * 100, 2) AS retention_pct
FROM cohort_raw r
JOIN cohort_size s USING (cohort_month)
ORDER BY r.cohort_month, r.order_month;

-- 결과: 월별 재구매율이 대부분 1% 미만으로, Olist는 재구매보다
--       신규 고객 획득에 의존하는 마켓플레이스 구조임을 확인.
