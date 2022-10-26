#!/bin/sh
# nbt, 17.10.2022

# sync the local html/swib{yy} directory to the live webserver

# read conference name from config.yaml
SWIB=`grep ^swib: config.yaml | cut -d: -f2 | column -t`
if [ -z ${SWIB+x} ]; then 
  echo variable SWIB is not set
  exit 1
fi
LC_SWIB=`echo $SWIB | tr '[:upper:]' '[:lower:]'`

# read upload {user}@{host}:{basedir} from file
# (authentication by ssh key)
UPLOAD_SRV=`cat .swib_upload`

rsync -ravuz --exclude '*~' --exclude 'swib??_participants_*.html' ../var/html/$LC_SWIB/ $UPLOAD_SRV/$LC_SWIB

