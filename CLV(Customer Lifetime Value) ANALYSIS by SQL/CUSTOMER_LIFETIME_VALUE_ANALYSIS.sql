-- ARPU * RETENTION_RATE를 통해 CLV 구하기

-- ARPU 구하기
WITH T1 AS
	(
	SELECT oml.mem_no, oml.ord_dt, oml.order_amount, fotl.age_range, fotl.first_ord_dt
	FROM
		order_master_ltv oml 
	LEFT JOIN
		first_ord_table_ltv fotl 
	ON
		oml.mem_no = fotl.mem_no 
),
T2 AS 
	(
	SELECT mem_no, COUNT(mem_no) AS tot_cnt, SUM(order_amount) AS tot_amount
	FROM 
		T1
	WHERE ord_dt BETWEEN '2023-01-01' AND '2023-06-31'
	GROUP BY
		age_range
),
COHORT AS
(
	SELECT age_range, 
		CASE WHEN first_ord_dt = ord_dt THEN 'M-1'
			WHEN first_ord_dt < ord_dt AND ord_dt < '2023-02-01' AND ord_dt >= '2023-01-01' THEN 'M-1'
			WHEN ord_dt >= '2023-02-01' AND ord_dt < '2023-03-01' THEN 'M-2'
			WHEN ord_dt >= '2023-03-01' AND ord_dt < '2023-04-01' THEN 'M-3'
			WHEN ord_dt >= '2023-04-01' AND ord_dt < '2023-05-01' THEN 'M-4'
			WHEN ord_dt >= '2023-05-01' AND ord_dt < '2023-06-01' THEN 'M-5'
			WHEN ord_dt >= '2023-06-01' AND ord_dt < '2023-07-01' THEN 'M-6'
			ELSE NULL END AS ord_month
		, COUNT(DISTINCT mem_no) AS retention_base
		, ROUND(AVG(order_amount),2) AS arpu
	FROM
		T1
	WHERE ord_dt < '2023-07-01'
	GROUP BY
		age_range, ord_month
	ORDER BY 
		ord_month, age_range
	),
ARPU_RETENTION AS	
	(
	SELECT
		age_range,
		ord_month,
		1.000 * retention_base / MAX(retention_base) OVER (PARTITION BY age_range) AS retention_rate,
		arpu
	FROM 
		COHORT
	)
SELECT age_range, ord_month, retention_rate, arpu,
	ROUND(arpu * retention_rate,2) AS LTV
FROM
	ARPU_RETENTION
