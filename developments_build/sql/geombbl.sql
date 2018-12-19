-- set the geometry to be the center of the lot
UPDATE developments a
SET geom = ST_Centroid(b.geom)
FROM dcp_mappluto b
WHERE a.geo_bbl::text = b.bbl::text;

UPDATE developments a
SET geom = ST_Centroid(b.geom)
FROM dcp_mappluto b
WHERE a.bbl::text||'.00' = b.bbl::text
AND a.geom IS NULL
AND b.geom IS NOT NULL;