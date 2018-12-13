import pandas as pd
import subprocess
import os
import sqlalchemy as sql
import json
from nyc_geoclient import Geoclient

# make sure we are at the top of the repo
wd = subprocess.check_output('git rev-parse --show-toplevel', shell = True)
os.chdir(wd[:-1]) #-1 removes \n

# load config file
with open('developments.config.json') as conf:
    config = json.load(conf)

DBNAME = config['DBNAME']
DBUSER = config['DBUSER']
# load necessary environment variables
# set variables with following command: export SECRET_KEY="somesecretvalue"
app_id = config['GEOCLIENT_APP_ID']
app_key = config['GEOCLIENT_APP_KEY']

# connect to postgres db
engine = sql.create_engine('postgresql://{}@localhost:5432/{}'.format(DBUSER, DBNAME))

# read in housing table
developments = pd.read_sql_query('SELECT job_number, address_house, address_street, boro FROM developments WHERE address_house IS NOT NULL AND address_street IS NOT NULL AND address IS NOT NULL AND boro IS NOT NULL AND geo_bbl IS NULL LIMIT 1000;', engine)

# replace single quotes with doubled single quotes for psql compatibility 
developments['address_house'] = [i.replace("'", "''") for i in developments['address_house']]
developments['address_street'] = [i.replace("'", "''") for i in developments['address_street']]


# get the geo data
g = Geoclient(app_id, app_key)

def get_loc(num, street, borough):
    geo = g.address(num, street, borough)
    try:
        bbl = geo['bbl']
    except:
        bbl = 'none'
    try:
        b_in = geo['buildingIdentificationNumber']
    except:
        b_in = 'none'
    try:
        hnum = geo['houseNumber']
    except:
        hnum = 'none'
    try:
        sname = geo['boePreferredStreetName']
    except:
        sname = 'none'
    try:
        bcode = geo['bblBoroughCode']
    except:
        bcode = 'none'
    try:
        cd = geo['communityDistrict']
    except:
        cd = 'none'
    try:
        nta = geo['nta']
    except:
        nta = 'none'
    try:
        ntan = geo['ntaName']
    except:
        ntan = 'none'
    try:
        cblock = geo['censusBlock2010']
    except:
        cblock = 'none'
    try:
        csd = geo['communitySchoolDistrict']
    except:
        csd = 'none'
    try:
        lat = geo['latitude']
    except:
        lat = 'none'
    try:
        lon = geo['longitude']
    except:
        lon = 'none'
    loc = pd.DataFrame({'bbl' : [bbl],
                        'bin' : [b_in],
                        'hnum': [hnum],
                        'sname': [sname],
                        'bcode': [bcode],
                        'cd'   : [cd],
                        'nta'  : [nta],
                        'ntan' : [ntan],
                        'cblock': [cblock],
                        'csd'   : [csd],
                        'lat' : [lat],
                        'lon' : [lon]})
    return(loc)

locs = pd.DataFrame()
for i in range(len(developments)):
    new = get_loc(developments['address_house'][i],
                  developments['address_street'][i],
                  developments['boro'][i]
    )
    locs = pd.concat((locs, new))
locs.reset_index(inplace = True)

# update developments spatial information from geosupport results
for i in range(len(developments)):
    if (locs['bbl'][i] != 'none'):
        upd = "UPDATE developments a SET geo_bbl = " + str(locs['bbl'][i]) + ", geo_bin = " + str(locs['bin'][i]) + ", geo_address = " + str(locs['hnum'][i]) + ", geo_address = geo_address||' '||" + str(locs['sname'][i]) + ", geo_boro = " + str(locs['bcode'][i]) + ", geo_cd = " + str(locs['cd'][i]) + ", geo_ntacode2010 = " + str(locs['nta'][i]) + ", geo_ntaname2010 = " + str(locs['ntan'][i]) + ", geo_censusblock2010 = " + str(locs['cblock'][i]) + ", geo_csd = " + str(locs['csd'][i]) + ", latitude = " + str(locs['lat'][i]) + ", longitude = " + str(locs['lon'][i]) + " WHERE a.job_number = '" + developments['job_number'][i] + "';"
    elif locs['bbl'][i] == 'none': 
        upd = "UPDATE developments a SET geom = NULL WHERE a.job_number = '" + developments['job_number'][i] + "';"
    engine.execute(upd)


# not deleting because if I ever figure it out this is probably a better way of doing this... 
#md = sql.MetaData(engine)
#table = sql.Table('sca', md, autoload=True)
#upd = table.update(values={
