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

-- set the number of incomplete units
UPDATE developments
SET (CASE 
			WHEN units_net IS NOT NULL AND dcp_status LIKE '%Complete%' THEN '0'
			WHEN units_net IS NOT NULL AND dcp_status <> 'Complete' THEN (units_net::numeric - units_net_complete::numeric)::text
			WHEN units_net IS NULL AND units_prop IS NOT NULL AND latest_cofo IS NOT NULL AND units_prop <> 'NONE' AND units_prop <> 'NON5' THEN (units_prop::numeric - latest_cofo::numeric)::text
			ELSE units_net
		END);

		
SET units_incomplete = units_prop::numeric - co_latest_units::numeric;

UPDATE housing
SET units_net_complete =
	-- Calculation is not performed if units_net or u_prop were NULL
		(CASE
			WHEN dcp_status = 'Complete (demolition)' AND units_net IS NOT NULL THEN units_net
			WHEN latest_cofo IS NULL AND units_net IS NOT NULL THEN '0' 
			WHEN dob_type = 'A1' AND latest_cofo IS NOT NULL AND units_net IS NOT NULL THEN (latest_cofo::numeric - units_init::numeric)::text
			WHEN dob_type = 'NB' AND latest_cofo IS NOT NULL AND units_net IS NOT NULL THEN latest_cofo
		END),
	units_net_incomplete =
		(CASE 
			WHEN units_net IS NOT NULL AND dcp_status LIKE '%Complete%' THEN '0'
			WHEN units_net IS NOT NULL AND dcp_status <> 'Complete' THEN (units_net::numeric - units_net_complete::numeric)::text
			WHEN units_net IS NULL AND units_prop IS NOT NULL AND latest_cofo IS NOT NULL AND units_prop <> 'NONE' AND units_prop <> 'NON5' THEN (units_prop::numeric - latest_cofo::numeric)::text
			ELSE units_net
		END);