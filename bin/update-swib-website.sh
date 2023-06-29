#! /bin/bash

# write stdout and stderr to file
exec 1>update-swib-website.log 2>&1

# run scripts conditionally
# echoing current date each time
date && \
./get_conftool_data.sh && \
date && \
perl create_website.pl && \
date && \
make && \
date

# exit code of commands above
echo $?