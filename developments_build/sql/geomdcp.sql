-- add in DCP geometries from housing_input_dcpattributes
-- cannot overwrite existing geometry

-- use bbl centroid
UPDATE developments a
SET geom = ST_Centroid(b.geom),
	x_geomsource = 'BBL DCP'
FROM (SELECT a.job_number, ST_Centroid(b.geom) as geom
	FROM housing_input_dcpattributes a
	LEFT JOIN dcp_mappluto b
	ON a.bbl||'.00'::text=b.bbl::text
	WHERE a.bbl IS NOT NULL) b
WHERE a.job_number = b.job_number
AND a.geom IS NULL
AND b.geom IS NOT NULL;

-- use lat and long
UPDATE developments a
SET geom = ST_SetSRID(ST_MakePoint(b.longitude::double precision, b.latitude::double precision),4326),
	x_geomsource = 'Lat/Long DCP'
FROM housing_input_dcpattributes b
WHERE a.job_number = b.job_number
AND a.geom IS NULL
AND b.longitude IS NOT NULL AND b.latitude::double precision > 0;

-- use created geometry
-- UPDATE developments a
-- SET geom = b.geom,
-- 	x_geomsource = 'Geom DCP'
-- FROM housing_input_dcpattributes b
-- WHERE a.job_number = b.job_number
-- AND a.geom IS NULL
-- AND b.geom IS NOT NULL;

-- use bin centroid
UPDATE developments a
SET geom = b.geom,
	x_geomsource = 'BIN DCP'
FROM (SELECT c.job_number, ST_Centroid(d.geom) as geom
	FROM housing_input_dcpattributes c
	LEFT JOIN doitt_buildingfootprints d
	ON c.bin::text=d.bin::text
	WHERE c.bin IS NOT NULL) b
WHERE a.job_number = b.job_number
AND a.geom IS NULL
AND b.geom IS NOT NULL;