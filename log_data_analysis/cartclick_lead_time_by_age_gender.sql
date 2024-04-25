-- LAST SESSION의 MAX-MIN을 LEAD TIME으로 간주할 것임
-- CARTCLK의 시작시간부터 CARTCLK의 마지막 시간을 LEAD_TIME으로 정의할 것임
WITH log AS
(
	SELECT ltp.mem_no, ltp.event, ltp.session_id, 
		DATETIME(log_stamp) AS log_stamp,
		(JULIANDAY(MAX(ltp.log_stamp)) - JULIANDAY(MIN(ltp.log_stamp))) * 1440 AS lead_time, 
		MAX(ltp.log_stamp) OVER (PARTITION BY ltp.mem_no) AS last_time
		
	FROM
		log_table_practice2 ltp 
	LEFT JOIN
		first_ord_table_practice2 fotp 
	ON
		ltp.mem_no = fotp.mem_no
	WHERE 
		ltp.event = 'CartClk'
	GROUP BY 
		ltp.mem_no,session_id
		)
SELECT B.age, B.gender, 
	ROUND(AVG(A.lead_time),2) AS average_lead_time	
FROM log A
	INNER JOIN
	first_ord_table_practice2 B
ON
	A.mem_no = B.mem_no 
WHERE 
	log_stamp = last_time
GROUP BY 
	age, gender   