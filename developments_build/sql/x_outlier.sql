UPDATE developments
SET x_outlier = TRUE
WHERE job_number IN
	(SELECT DISTINCT job_number
		FROM qc_outliers
		WHERE outlier IS DISTINCT FROM 'N' OR outlier IS DISTINCT FROM 'C');

-- Remove the data table
DROP TABLE IF EXISTS qc_outliers;