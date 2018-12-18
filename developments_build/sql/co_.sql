-- get the earliest and latest date for the COs of each job number
WITH cosum AS(
	SELECT job_number,
	min(effectivedate::date) AS co_earliest_effectivedate,
	max(effectivedate::date) AS co_latest_effectivedate
	FROM developments_co
	GROUP BY job_number)

UPDATE developments a
SET co_earliest_effectivedate = b.co_earliest_effectivedate,
	co_latest_effectivedate = b.co_latest_effectivedate
FROM cosum b
WHERE a.job_number=b.job_number;

-- populate the certificate type and number of units associated with the latest co
UPDATE developments a
SET co_latest_certtype = b.certtype,
	co_latest_units = b.units
FROM developments_co b
WHERE a.job_number=b.job_number
AND a.co_latest_effectivedate::date = b.effectivedate::date;