#!/bin/sh
# nbt, 2020-11-03

# recreate statistics charts for SWIB

SWIB=swib21
cd /opt/swib/bin

# get most current conftool data
./get_conftool_data.sh

# create pages
perl create_participants_charts.pl > /dev/null

# copy to open dir
scp -qp ../var/html/$SWIB/${SWIB}_participants_by_*.html ite-srv26:/var/www/html/beta/tmp/${SWIB}_a5825ae92/
