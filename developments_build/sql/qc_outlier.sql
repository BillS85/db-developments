DROP TABLE IF EXISTS qc_outliers;
CREATE TABLE qc_outliers
( job_number text, job_type text, job_description text,units_init text, units_prop text, units_net text, units_complete text,co_latest_units text, address text, bbl text,
	flag text,
	outlier text
);

COPY qc_outliers FROM '/prod/db-developments/developments_build/output/qc_outliers.csv' DELIMITER ',' CSV HEADER;

-- add outlier records to archived table
CREATE TABLE IF NOT EXISTS qc_outliersacrhived (
	job_number text, flag text, outlier text);

INSERT INTO qc_outliersacrhived (
	job_number, flag, outlier)
	SELECT DISTINCT job_number, flag, outlier 
	FROM qc_outliers;

-- create table of records to be verified
DROP TABLE IF EXISTS qc_outliers;
CREATE TABLE qc_outliers AS (
(SELECT job_number, job_type, job_description,units_init, units_prop, units_net, units_complete,co_latest_units,address,bbl,
	'units_net_complete is 50+ units greater than units proposed (NBs only)' as flag,
	 NULL as outlier
FROM developments
WHERE
	job_type = 'New Building'
	AND (units_complete::integer - units_prop::integer) >= 50)
UNION
(SELECT job_number, job_type, job_description,units_init, units_prop, units_net, units_complete,co_latest_units,address,bbl,
	'job_type= DM and units_init > 19' as flag,
	NULL as outlier 
FROM developments
WHERE
	job_type = 'Demolition'
	AND units_init::integer >= 20)
UNION
(SELECT job_number, job_type, job_description,units_init, units_prop, units_net, units_complete,co_latest_units,address,bbl,
	'job_type= A1 and units_net < -50' as flag,
	NULL as outlier   
FROM developments
WHERE
	job_type = 'Alteration'
	AND units_net::integer <= -50)
UNION
(SELECT job_number, job_type, job_description,units_init, units_prop, units_net, units_complete,co_latest_units,address,bbl,
	'top 20 units_net A1' as flag,
	NULL as outlier 
FROM developments
WHERE
	job_type = 'Alteration'
	AND units_net IS NOT NULL
	AND (status <> 'Withdrawn' OR status IS NULL)
	AND x_dup_flag IS NULL
ORDER BY
	units_net DESC
LIMIT 20)
UNION
(SELECT job_number, job_type, job_description,units_init, units_prop, units_net, units_complete,co_latest_units,address,bbl,
	'top 10 units_prop Alteration' as flag,
	NULL as outlier 
FROM developments
WHERE
	job_type = 'Alteration'
	AND units_prop IS NOT NULL
	AND (status <> 'Withdrawn' OR status IS NULL)
	AND x_dup_flag IS NULL
ORDER BY
	units_prop DESC
LIMIT 10)
UNION
(SELECT job_number, job_type, job_description,units_init, units_prop, units_net, units_complete,co_latest_units,address,bbl,
	'job_type= NB and units_init NOT 0' as flag,
	NULL as outlier
FROM developments
WHERE
	job_type = 'New Building'
	AND units_init::integer <> 0)
UNION
(SELECT job_number, job_type, job_description,units_init, units_prop, units_net, units_complete,co_latest_units,address,bbl,
	'job_description contains both %RESID% AND %HOTEL%' as flag,
	NULL as outlier
FROM developments
WHERE
	upper(job_description) LIKE '%RESID%HOTEL%'
	OR upper(job_description) LIKE '%HOTEL%RESID%')
UNION
(SELECT job_number, job_type, job_description,units_init, units_prop, units_net, units_complete,co_latest_units,address,bbl,
	'co_latest_units is negative' as flag,
	NULL as outlier    
FROM developments
WHERE
	co_latest_units::numeric < 0)
);