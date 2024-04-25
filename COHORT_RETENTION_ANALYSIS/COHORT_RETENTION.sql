-- ord_no이 다르면 같은 날 주문이어도 다른 주문건으로 간주함
-- first_ord_dt(첫주문일자)로부터 ord_dt가 1달 이내인 주문 건만 고려함
-- ORDER 테이블

SELECT * 
FROM order_master_practive1 omp 

-- 첫주문 테이블
SELECT *
FROM first_ord_table_practice1 fotp 

-- 코호트 나누기
WITH T1 AS
(
SELECT DISTINCT omp.mem_no, fotp.first_ord_dt, omp.ord_no,omp.ord_dt,
	SUM(CASE WHEN fotp.first_ord_dt < omp.ord_dt AND DATE(fotp.first_ord_dt,'+7 DAYS') >= DATE(omp.ord_dt) THEN 1 ELSE 0
	END) OVER (PARTITION BY omp.mem_no) AS W1_orders,
	DENSE_RANK() OVER (PARTITION BY omp.mem_no ORDER BY omp.ord_dt,omp.ord_no) AS sec_order
FROM
	order_master_practive1 omp 
	INNER JOIN
	first_ord_table_practice1 fotp 
ON
	omp.mem_no = fotp.mem_no 
WHERE 
	DATE(first_ord_dt) BETWEEN '2023-07-01' AND '2023-07-31'
	AND 
	DATE(ord_dt) <= DATE(first_ord_dt,'+1 MONTH') 
	),
	T2 AS
	(SELECT mem_no, ord_no,first_ord_dt, ord_dt,
	CASE WHEN W1_orders > 0 THEN 1 ELSE 0 END AS cohort,
	sec_order
	FROM T1)
SELECT COUNT(DISTINCT mem_no) cnt, cohort, sec_order
FROM T2
GROUP BY 
cohort, sec_order