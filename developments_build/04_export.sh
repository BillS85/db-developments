#!/bin/bash

# make sure we are at the top of the git directory
REPOLOC="$(git rev-parse --show-toplevel)"
cd $REPOLOC

# load config
DBNAME=$(cat $REPOLOC/developments.config.json | jq -r '.DBNAME')
DBUSER=$(cat $REPOLOC/developments.config.json | jq -r '.DBUSER')

# eventually these should copy directly from psql to carto
# for now, write to files which can by copied

# Generate output tables
psql -U $DBUSER -d $DBNAME -f $REPOLOC/developments_build/sql/export.sql
