#!/bin/sh
# nbt, 29.6.2023

# Initialize directories and files for new swib
# (does no harm when invoked repeatedly)

# read conference name from config.yaml
SWIB=`grep ^swib: config.yaml | cut -d: -f2 | column -t`
if [ -z ${SWIB+x} ]; then 
  echo variable SWIB is not set
  exit 1
fi
LC_SWIB=`echo $SWIB | tr '[:upper:]' '[:lower:]'`

# create directories
mkdir -p ../var/src/$LC_SWIB
mkdir -p ../var/html/$LC_SWIB/sessions

