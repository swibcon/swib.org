# Overview

## Process

* `get_conftool_data.sh` fetches the source data from the SWIB Conftool website.

* `create_website.pl` creates markdown files for each dynamic page and one turtle file

* `make` invokes pandoc for converting .md to .html files

## Configuration

Config variables are supplied by `config.yaml` - in particular the name of the
current SWIB edition, which is used by all procedures.

## Security / privacy

Password files (.*_secret) and conftool source files, which contain personal
data, are not added to Git (see `/.gitignore`).

