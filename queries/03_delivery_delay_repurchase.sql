-- 배송 지연 여부와 재구매의 관계
-- 가설: 배송이 늦으면 재구매율이 낮을 것이다.

WITH orders_casted AS (
  SELECT
    o.order_id, c.customer_unique_id, o.order_status,
    CAST(o.order_delivered_customer_date AS TIMESTAMP) AS delivered_ts,
    CAST(o.order_estimated_delivery_date AS TIMESTAMP) AS estimated_ts
  FROM `olist-analysis-507907.olist.orders` o
  JOIN `olist-analysis-507907.olist.customers` c ON o.customer_id = c.customer_id
),
delivery_flag AS (
  SELECT order_id, customer_unique_id,
    CASE WHEN delivered_ts > estimated_ts THEN '지연' ELSE '정시' END AS delivery_status
  FROM orders_casted
  WHERE order_status = 'delivered' AND delivered_ts IS NOT NULL
),
repurchase AS (
  SELECT customer_unique_id, COUNT(*) AS order_cnt
  FROM orders_casted GROUP BY customer_unique_id
)
SELECT
  d.delivery_status,
  COUNTIF(r.order_cnt > 1) AS repeat_customers,
  COUNTIF(r.order_cnt = 1) AS one_time_customers
FROM delivery_flag d
JOIN repurchase r USING (customer_unique_id)
GROUP BY d.delivery_status;

-- 결과: 지연 429/7397, 정시 5670/82974
--       재구매율 지연 5.48% vs 정시 6.40% (14% 상대적 감소, chi2=10.15, p=0.0014)
