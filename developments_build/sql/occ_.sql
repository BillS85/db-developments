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
WHERE dob_type = 'NB' AND occ_init IS NULL;

UPDATE developments
SET occ_prop = 'Empty Lot'
WHERE dob_type = 'DM' AND occ_prop IS NULL;


-- category
-- set to Residential where exiting or proposed occupany is Residential
UPDATE developments
SET occ_category = 'Residential'
WHERE occ_init LIKE '%Residential%' OR occ_prop LIKE '%Residential%'
OR occ_init LIKE '%Assisted%Living%' OR occ_prop LIKE '%Assisted%Living%';

-- otherwise set to other
UPDATE developments
SET occ_category = 'Other'
WHERE dcp_occ_category IS NULL;