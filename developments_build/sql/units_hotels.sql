-- set units_prop to 0 when multiple dwelling units are coverted to hotels
-- to reflect the loss of residential units when multiple dwellings are converted into hotels (but only for alterations resulting in a significant increase in "units")
UPDATE developments
SET units_prop = '0'
WHERE job_type = 'Alteration' 
	AND occ_init LIKE '%Residential%'
	AND occ_prop LIKE '%Hotel%'
	AND x_mixeduse IS NULL 
	AND units_prop::numeric > (unit_init::numeric+2);

-- set units_init to 0 when hotels are converted into multiple dwellings
-- to reflect the gain of residential units when hotels are converted into multiple dwellings (but only for alterations resulting in a significant decrease in "units")
UPDATE developments
SET units_init = '0'
WHERE job_type = 'Alteration' 
	AND occ_init LIKE '%Hotel%'
	AND occ_prop LIKE '%Residential%'
	AND x_mixeduse IS NULL 
	AND unit_init::numeric > (units_prop::numeric+2);