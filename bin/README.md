# Overview

## Process

* `get_conftool_data.sh` fetches the source data from the SWIB Conftool website.

* `create_website.pl` creates markdown files for each dynamic page and one turtle file

* `make` invokes Pandoc for converting .md to .html files

## Configuration

Config variables are supplied by `config.yaml` - in particular the name of the
current SWIB edition, which is used by all procedures.

## Security / privacy

Password files (eg, .conftool_secret) and conftool source files, which contain
personal data, are not added to Git (see `/.gitignore`).

## Connection between contributions and speakers

For creating the author links from the programme page to their speaker entry,
the author email addresses in the "Presentation" are essential. Currently
(SWIB22), for the the "Submitted by" form fields of the "Contributors
Biography" are used.

### TODO

Currently, this creates some confusion and additional work, since the
internally saved "Sumitting Author" (by user ID)  is not necessarily identical
with the form fields "Submitted by". Additionally, when people add their
co-authors, they are often not aware that they should supply the co-authors
details in "Submitted by". Check for 2023, if other form settings and use of 
Conftool variables could improve the situation.

## Empty author and abstract fields

Empty entries for abstracts (e.g., for "Closing") and authors (e.g., for
"Lighning talks") are not allowed by Contftool. So a '.' in the abstract
indicates that abstract output should be omitted, and '.' in the first
firstname and lastname Author entries indicate, that author and organisation
should be omitted for the contribution.

