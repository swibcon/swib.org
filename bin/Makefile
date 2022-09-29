# Makefile
# nbt, 23.08.2022

# read current swib from config
LC_SWIB := $(shell grep ^swib: config.yaml | cut -d: -f2 | column -t | tr '[:upper:]' '[:lower:]' )

MD_FILES := $(shell find ../var/html/$(LC_SWIB) -name "*.md")
HTML_FILES := $(MD_FILES:.md=.html)
##$(warning $(HTML_FILES))

# binaries
PANDOC=/usr/local/bin/pandoc
EXT_OPTS    := --standalone -f markdown+pipe_tables+fenced_divs+bracketed_spans -t html
TMPL_OPTS   := --template ../etc/pandoc_templates/default.html5 --css /$(LC_SWIB)/styles/simple.css

all: $(HTML_FILES)

$(HTML_FILES): $(MD_FILES)
	@echo $@
	@$(PANDOC) $(TMPL_OPTS) $(EXT_OPTS) -o $@ $<

