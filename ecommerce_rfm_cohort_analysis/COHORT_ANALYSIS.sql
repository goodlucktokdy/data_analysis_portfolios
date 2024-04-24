--첫주문 고객 테이블
SELECT *
FROM first_ord_table fot 

--오더 마스터 테이블
SELECT *
FROM order_master_cohort omc 

--두 테이블 조인
SELECT *
FROM first_ord_table fot 
LEFT JOIN
order_master_cohort omc 
ON
fot.mem_no = omc.mem_no

--
WITH T1 AS
	(
	SELECT DISTINCT fot.mem_no, fot.is_promotion, fot.first_ord_dt, omc.ord_dt,
		CASE WHEN omc.ord_dt = fot.first_ord_dt THEN 0
			 WHEN omc.ord_dt >= fot.first_ord_dt AND DATE(omc.ord_dt) <= DATE(fot.first_ord_dt, '+7 days') THEN 1
			 WHEN omc.ord_dt >= fot.first_ord_dt AND DATE(omc.ord_dt) <= DATE(fot.first_ord_dt, '+14 days') THEN 2
			 WHEN omc.ord_dt >= fot.first_ord_dt AND DATE(omc.ord_dt) <= DATE(fot.first_ord_dt, '+21 days') THEN 3
			 WHEN omc.ord_dt >= fot.first_ord_dt AND DATE(omc.ord_dt) <= DATE(fot.first_ord_dt, '+28 days') THEN 4 END AS week_number		
		FROM first_ord_table fot 
		LEFT JOIN
			order_master_cohort omc 
		ON
			fot.mem_no = omc.mem_no
	),
T2 AS
	(
	SELECT A.mem_no, A.is_promotion, A.week_number, 
		ROW_NUMBER() OVER (PARTITION BY A.mem_no ORDER BY A.week_number) AS "sequence"
		FROM 
			T1 AS A
		WHERE 
			A.week_number IS NOT NULL
		ORDER BY 
			1,2,3,4
	)
SELECT is_promotion, 
	CASE WHEN week_number = 0 THEN '1.W-0'
		 WHEN week_number = 1 AND "sequence" = 2 THEN '2.W-1'
		 WHEN week_number = 2 AND "sequence" = 3 THEN '3.W-2'
		 WHEN week_number = 3 AND "sequence" = 4 THEN '4.W-3'
		 WHEN week_number = 4 AND "sequence" = 5 THEN '5.W-4'
		 ELSE NULL END AS week_range,
		 COUNT(DISTINCT mem_no) AS cnt
	FROM 
		T2
	WHERE
		week_range IS NOT NULL
	GROUP BY 
		is_promotion, week_range
	ORDER BY 
		is_promotion, week_range