-- set the geometry to be the center of the lot
UPDATE developments a
SET geom = ST_Centroid(b.geom)
FROM dcp_mappluto b
WHERE a.geo_bbl = b.bbl;

UPDATE developments a
SET geom = ST_Centroid(b.geom)
FROM dcp_mappluto b
WHERE a.bbl = b.bbl
AND a.geom IS NULL
AND b.geom IS NOT NULL;