-- add in DCP geometries from housing_input_dcpattributes
-- cannot overwrite existing geometry

-- use bbl centroid
UPDATE developments a
SET geom = ST_Centroid(b.geom),
x_geomsource = 'dcp'
FROM (SELECT a.job_number, ST_Centroid(b.geom) as geom
	FROM housing_input_dcpattributes a
	LEFT JOIN dcp_mappluto b
	ON a.bbl||'.00'::text=b.bbl::text
	WHERE a.bbl IS NOT NULL) b
WHERE a.job_number = b.job_number
AND a.geom IS NULL
AND b.geom IS NOT NULL;

-- use created geometry
UPDATE developments a
SET geom = b.geom
FROM housing_input_dcpattributes b
WHERE a.job_number = b.job_number
AND a.geom IS NULL
AND b.geom IS NOT NULL;

-- use lat and long
UPDATE developments a
SET geom = ST_SetSRID(ST_MakePoint(b.longitude::double precision, b.latitude::double precision),4326)
FROM housing_input_dcpattributes b
WHERE a.job_number = b.job_number
AND a.geom IS NULL
AND b.longitude IS NOT NULL;

-- use bin centroid
UPDATE developments a
SET geom = b.geom
FROM (SELECT a.job_number, ST_Centroid(b.geom) as geom
	FROM housing_input_dcpattributes a
	LEFT JOIN doitt_buildingfootprints b
	ON a.bin::text=b.bin::text
	WHERE a.bin IS NOT NULL
	AND a.geom IS NULL) b
WHERE a.job_number = b.job_number
AND a.geom IS NULL
AND b.geom IS NOT NULL;