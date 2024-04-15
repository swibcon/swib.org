#!/bin/sh
# nbt, 28.2.2023

# Creates a website with cfp, without creating programme etc. pages

cd ~/git/swib.org/bin

# read conference name from config.yaml
SWIB=`grep ^swib: config.yaml | cut -d: -f2 | column -t`
if [ -z ${SWIB+x} ]; then
  echo variable SWIB is not set
  exit 1
fi
LC_SWIB=`echo $SWIB | tr '[:upper:]' '[:lower:]'`

# get latest cfp version from Github
wget -O ../etc/html_tmpl/cfp.md.inc https://raw.githubusercontent.com/swibcon/swib-orga/main/cfp.md

# compile markdown pages
perl create_website.pl plain

# invoke pandoc to create html
make

# final step after check
echo ""
echo "Final steps:"
echo "- Check http://ite-srv24.zbw-nett.zbw-kiel.de/$LC_SWIB/"
echo "- Execute './sync_to_live.sh'"
echo "- Check https://swib.org"
echo ""

