UPDATE developments
SET x_outlier = TRUE
WHERE job_number IN
	(SELECT DISTINCT job_number
		FROM qc_outliers
		WHERE outlier <> 'N' OR outlier <> 'C');

-- Remove the data table
DROP TABLE IF EXISTS qc_outliers;