-- sum stats for job_type
DROP TABLE IF EXISTS dev_qc_jobtypestats;
CREATE TABLE dev_qc_jobtypestats AS (
	SELECT job_type, COUNT(*) 
	FROM housing_export 
	GROUP BY job_type 
	ORDER BY job_type);

-- sum stats for x_geomsource
DROP TABLE IF EXISTS dev_qc_geocodedstats;
CREATE TABLE dev_qc_geocodedstats AS (
	SELECT x_geomsource, COUNT(*) 
	FROM housing_export
	GROUP BY x_geomsource
	ORDER BY x_geomsource);

-- general counts of output
DROP TABLE IF EXISTS dev_qc_countsstats;
CREATE TABLE dev_qc_countsstats AS (
SELECT 'sum of units_net' AS stat, SUM(units_net::numeric) as count
FROM housing_export a
UNION
SELECT 'sum of units_prop' AS stat, SUM(units_prop::numeric) as count
FROM housing_export a
UNION
SELECT 'sum of units_complete' AS stat, SUM(units_complete::numeric) as count
FROM housing_export a
UNION
SELECT 'number of alterations with +/- 100 units' AS stat, COUNT(*) as count
FROM housing_export a
WHERE job_type = 'Alteration' AND (units_net::numeric >= 100 OR units_net::numeric <= 100)
UNION
SELECT 'number of inactive records' AS stat, COUNT(*) as count
FROM housing_export a
WHERE x_inactive = 'TRUE'
UNION
SELECT 'number of mixused records' AS stat, COUNT(*) as count
FROM housing_export a
WHERE x_mixeduse = 'TRUE'
UNION
SELECT 'number of outlier records' AS stat, COUNT(*) as count
FROM housing_export a
WHERE x_outlier = 'TRUE'
);
-- UNION
-- SELECT 'number of hotel/residential records' AS stat, COUNT(*) as count
-- FROM housing_export a
-- WHERE job_type = 'Alteration' AND (units_net::numeric >= 100 OR units_net::numeric <= 100)

-- reporting possible duplicate records where the records have the same job_type and address and units_net > 0
DROP TABLE IF EXISTS dev_qc_potentialdups;
CREATE TABLE dev_qc_potentialdups AS (
	WITH housing_export_rownum AS (
	SELECT a.*, ROW_NUMBER()
    	OVER (PARTITION BY address, job_type
      	ORDER BY address, job_type) AS row_number
  		FROM housing_export a
  		WHERE units_net::numeric > 0)
	SELECT * 
	FROM housing_export_rownum 
	WHERE row_number = 2); 

DROP TABLE IF EXISTS dev_qc_occupancyresearch;
CREATE TABLE dev_qc_occupancyresearch AS (
	SELECT * FROM housing_export 
	WHERE occ_init = 'Assembly: Other' 
	OR occ_prop = 'Assembly: Other' 
	OR job_number IN (
		SELECT DISTINCT jobnumber 
		FROM dob_jobapplications
		WHERE occ_init = 'H-2' 
		OR occ_prop = 'H-2'));
