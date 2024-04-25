--고객의 로그데이터 분석을 통한 배너유입 후 구매 전환율 분석
--세션 아이디는 여기서는 고려하지 않았음
-- 주문 테이블
SELECT *
FROM
	order_master_log oml 

--로그 테이블
SELECT *
FROM 
	log_table lt 

WITH log AS
(
SELECT DISTINCT lt.mem_no, session_id, lt.log_dt, lt.log_stamp, 
	MIN(lt.referrer) OVER (PARTITION BY lt.mem_no ORDER BY lt.referrer) bnr
FROM
	log_table lt 
	),
ord AS
(
	SELECT bnr, log.mem_no, log_dt, log_stamp, ord_stamp
	FROM
		log
	LEFT JOIN
		order_master_log oml 
	ON
		oml.mem_no = log.mem_no
		AND 
		DATE(log.log_dt) = DATE(oml.ord_stamp)
		AND 
		-- 당연히 서비스 이용시작시간 로그보다 ord_stamp(구매시간)이 더 이후여야 하기 때문에 밑의 조건 추가해야 함
		DATETIME(log.log_stamp) <= DATETIME(oml.ord_stamp)
		--원래 실무에서는 SESSIONID도 키값으로 잡아서 조인 해줘야 하나 여기서는 제외함 
	),
ord_cnt AS 
(SELECT bnr, mem_no, 
	CASE WHEN COUNT(DISTINCT ord_stamp) >= 1 THEN 1
		ELSE 0 END AS is_order
FROM 
	ord
GROUP BY
	bnr, mem_no)
SELECT bnr, SUM(is_order) AS unique_order_from_users
FROM
	ord_cnt
WHERE is_order IS NOT NULL
GROUP BY bnr