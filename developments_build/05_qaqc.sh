#!/bin/bash

# make sure we are at the top of the git directory
REPOLOC="$(git rev-parse --show-toplevel)"
cd $REPOLOC

# load config
DBNAME=$(cat $REPOLOC/developments.config.json | jq -r '.DBNAME')
DBUSER=$(cat $REPOLOC/developments.config.json | jq -r '.DBUSER')

# some final processing is done in Esri to create the Esri file formats
# please go to NYC Planning's Bytes of the Big Apple to download the offical versions of PLUTO and MapPLUTO
# https://www1.nyc.gov/site/planning/data-maps/open-data.page

echo "Exporting QAQC scripts"
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/qc_.sql
psql -U $DBUSER -d $DBNAME -c "COPY(SELECT * FROM dev_qc_jobtypestats) TO '$REPOLOC/developments_build/output/qc_jobtypestats.csv' DELIMITER ',' CSV HEADER;"
psql -U $DBUSER -d $DBNAME -c "COPY(SELECT * FROM dev_qc_geocodedstats) TO '$REPOLOC/developments_build/output/qc_geocodedstats.csv' DELIMITER ',' CSV HEADER;"
psql -U $DBUSER -d $DBNAME -c "COPY(SELECT * FROM dev_qc_countsstats) TO '$REPOLOC/developments_build/output/qc_countsstats.csv' DELIMITER ',' CSV HEADER;"
psql -U $DBUSER -d $DBNAME -c "COPY(SELECT * FROM dev_qc_potentialdups) TO '$REPOLOC/developments_build/output/qc_potentialdups.csv' DELIMITER ',' CSV HEADER;"
psql -U $DBUSER -d $DBNAME -c "COPY(SELECT * FROM dev_qc_occupancyresearch) TO '$REPOLOC/developments_build/output/qc_occupancyresearch.csv' DELIMITER ',' CSV HEADER;"