#!/bin/bash

# make sure we are at the top of the git directory
REPOLOC="$(git rev-parse --show-toplevel)"
cd $REPOLOC

# load config
DBNAME=$(cat $REPOLOC/housing.config.json | jq -r '.DBNAME')
DBUSER=$(cat $REPOLOC/housing.config.json | jq -r '.DBUSER')

start=$(date +'%T')
echo "Starting to build Developments DB"
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/create.sql
# populate job application data
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/jobnumber.sql
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/clean.sql
echo 'Transforming data attributes to DCP values'
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/bbl.sql
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/address.sql
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/jobtype.sql
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/occ_.sql
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/status.sql

echo 'Adding on DCP researched attributes'
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/dcpattributes.sql

echo 'Calculating data attributes'
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/statusq.sql
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/units_.sql


echo 'Adding on CO data attributes'
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/cotable.sql 
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/co_.sql




echo 'Populating DCP data flags'
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/x_inactive.sql
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/x_mixeduse.sql

echo 'Geocoding geoms...'
source activate py2
python $REPOLOC/developments_build/python/geocode_address.py
source deactivate

psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/geombbl.sql

