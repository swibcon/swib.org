#!/bin/sh
# nbt, 15.8.2012

# export SWIB data from Conftool via REST interface

# read conference name from config.yaml
SWIB=`grep ^swib: config.yaml | cut -d: -f2 | column -t`
if [ -z ${SWIB+x} ]; then 
  echo variable SWIB is not set
  exit 1
fi
LC_SWIB=`echo $SWIB | tr '[:upper:]' '[:lower:]'`

# get xml export files for abstract, speaker and session data from conftool

# REST access has to be enabled in Conftool under "Data import and export /
# Integrations With Other Systems / Enable General REST Interface". The
# password set here is used for all REST access.  Additionally, an username is
# required.

SERVER="https://www.conftool.org/$LC_SWIB/rest.php"
USER="exportadmin"
PASSWORD=`cat .conftool_secret`
DOWNLOADSFILE="./.downloads.txt"
OUTPUTDIR="../var/src/$LC_SWIB"

# create output dirs if necessary
mkdir -p $OUTPUTDIR $OUTPUTDIR/bak

# create backup
cp -pf $OUTPUTDIR/*.xml $OUTPUTDIR/bak

# set common parameers for REST access
common_param="page=adminExport"
common_param+="&form_include_deleted=0"
common_param+="&form_export_format=xml"
common_param+="&form_export_header=default"
common_param+="&cmd_create_export=true"

# parameters for abstract export

# create password hash salted with $TIMESTAMP
# shai256sum returns a trailing "  -", so only get the first word
TIMESTAMP=`date +%s`
PASSHASH=`echo -n "$TIMESTAMP$PASSWORD" | sha256sum | awk '{print $1;}'`
ctdata="$common_param&nonce=$TIMESTAMP&passhash=$PASSHASH"
ctdata+="&export_select=papers"
ctdata+="&form_export_papers_options%5B%5D=abstracts"
ctdata+="&form_export_papers_options%5B%5D=authors_extended"
ctdata+="&form_export_papers_options%5B%5D=authors_extended_firstname"
ctdata+="&form_export_papers_options%5B%5D=authors_extended_presenters"
ctdata+="&form_export_papers_options%5B%5D=authors_extended_columns"
ctdata+="&form_export_papers_options%5B%5D=authors_extended_email"
ctdata+="&form_export_papers_options%5B%5D=downloads"

curl --silent --request POST $SERVER --data "$ctdata" --output $OUTPUTDIR/abstracts.xml
sleep 1

# parameters for speakers biography export

# nonce generation same as above
TIMESTAMP=`date +%s`
PASSHASH=`echo -n "$TIMESTAMP$PASSWORD" | sha256sum | awk '{print $1;}'`
ctdata="$common_param&nonce=$TIMESTAMP&passhash=$PASSHASH"
ctdata+="&export_select=papers"
ctdata+="&form_export_papers_options%5B%5D=abstracts"
ctdata+="&form_export_papers_options%5B%5D=authors_extended_presenters"
ctdata+="&form_export_papers_options%5B%5D=authors_extended_columns"
ctdata+="&form_export_papers_options%5B%5D=authors_extended_email"
ctdata+="&form_track=3"
ctdata+="&form_status=1"

curl --silent --request POST $SERVER --data "$ctdata" --output $OUTPUTDIR/speakers.xml
sleep 1

# parameters for session export

# nonce generation same as above
TIMESTAMP=`date +%s`
PASSHASH=`echo -n "$TIMESTAMP$PASSWORD" | sha256sum | awk '{print $1;}'`
ctdata="$common_param&nonce=$TIMESTAMP&passhash=$PASSHASH"
ctdata+="&export_select=sessions"
ctdata+="&form_export_sessions_options%5B%5D=presentations"
ctdata+="&form_export_sessions_options%5B%5D=all"

curl --silent --request POST $SERVER --data "$ctdata" --output $OUTPUTDIR/sessions.xml
sleep 1

# parameters for participants export

# nonce generation same as above
TIMESTAMP=`date +%s`
PASSHASH=`echo -n "$TIMESTAMP$PASSWORD" | sha256sum | awk '{print $1;}'`
ctdata="$common_param&nonce=$TIMESTAMP&passhash=$PASSHASH"
ctdata+="&export_select=participants"
ctdata+="&form_export_participants_options%5B%5D=extended"

curl --silent --request POST $SERVER --data "$ctdata" --output $OUTPUTDIR/participants.xml

