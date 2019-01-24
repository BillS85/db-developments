-- populate the occupancy code fields using the housing_input_lookup_occupancy lookup table
-- initial 
-- post 2008
UPDATE developments a
SET occ_init = b.dcpclassificationnew
FROM housing_input_lookup_occupancy b
WHERE a.occ_init = b.doboccupancycode2008
	AND (right(status_a,4))::numeric >= 2008;
-- pre 2008
UPDATE developments a
SET occ_init = b.dcpclassificationnew
FROM housing_input_lookup_occupancy b
WHERE a.occ_init = b.doboccupancycode1968
	AND (right(status_a,4))::numeric < 2008;
-- no date filter 2008
UPDATE developments a
SET occ_init = b.dcpclassificationnew
FROM housing_input_lookup_occupancy b
WHERE a.occ_init = b.doboccupancycode2008;
-- no date filter 1968
UPDATE developments a
SET occ_init = b.dcpclassificationnew
FROM housing_input_lookup_occupancy b
WHERE a.occ_init = b.doboccupancycode1968;

-- proposed 
-- post 2008
UPDATE developments a
SET occ_prop = b.dcpclassificationnew
FROM housing_input_lookup_occupancy b
WHERE a.occ_prop = b.doboccupancycode2008
	AND (right(status_a,4))::numeric >= 2008;
-- pre 2008
UPDATE developments a
SET occ_prop = b.dcpclassificationnew
FROM housing_input_lookup_occupancy b
WHERE a.occ_prop = b.doboccupancycode1968
	AND (right(status_a,4))::numeric < 2008;
-- no date filter 2008
UPDATE developments a
SET occ_prop = b.dcpclassificationnew
FROM housing_input_lookup_occupancy b
WHERE a.occ_prop = b.doboccupancycode2008;
-- no date filter 1968
UPDATE developments a
SET occ_prop = b.dcpclassificationnew
FROM housing_input_lookup_occupancy b
WHERE a.occ_prop = b.doboccupancycode1968;

-- mark records as Empty Lots
UPDATE developments
SET occ_init = 'Empty Lot'
WHERE job_type = 'New Building' AND occ_init IS NULL;

UPDATE developments
SET occ_prop = 'Empty Lot'
WHERE job_type = 'Demolition' AND occ_prop IS NULL;


-- category
-- set to Residential where exiting or proposed occupany is Residential
UPDATE developments
SET occ_category = 'Residential'
WHERE occ_init LIKE '%Residential%' OR occ_prop LIKE '%Residential%'
OR occ_init LIKE '%Assisted%Living%' OR occ_prop LIKE '%Assisted%Living%';

-- otherwise set to other
UPDATE developments
SET occ_category = 'Other'
WHERE occ_category IS NULL;

-- Set occ_init = 'Garage/Miscellaneous' AND occ_prop = 'Garage/Miscellaneous'
-- Where job_type is Demolition or Alteration
-- AND address contains REAR or where job_description contains GARAGE 
UPDATE developments
SET occ_init = 'Garage/Miscellaneous',
	occ_prop = 'Garage/Miscellaneous'
WHERE (job_type = 'Demolition' 
	AND (upper(job_description) LIKE '%GARAGE%' OR upper(address) LIKE '%REAR%'))
OR (job_type = 'Alteration'
	AND (upper(job_description) LIKE '%GARAGE%' OR upper(address) LIKE '%REAR%') 
	AND (units_net::numeric = 0 OR units_net::numeric IS NULL));