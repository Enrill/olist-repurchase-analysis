-- 주문 상태별 분포 (퍼널)
-- 질문: 전체 주문 중 취소/품절 등 실질적 이탈이 차지하는 비중은?

SELECT
  order_status,
  COUNT(*) AS cnt,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct
FROM `olist-analysis-507907.olist.orders`
GROUP BY order_status
ORDER BY cnt DESC;

-- 결과: delivered 97.02%. 진짜 이탈(canceled+unavailable)은 1.24%로 낮음.
--       shipped/processing 등은 실이탈이 아니라 데이터 추출 시점의 스냅샷 효과.
