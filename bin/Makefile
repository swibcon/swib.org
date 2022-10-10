# Makefile
# nbt, 23.08.2022

# read current swib from config
LC_SWIB := $(shell grep ^swib: config.yaml | cut -d: -f2 | column -t | tr '[:upper:]' '[:lower:]' )

MD_FILES := $(shell find ../var/html/$(LC_SWIB) -name "*.md")
HTML_FILES := $(MD_FILES:.md=.html)
##$(warning $(HTML_FILES))

# current page name (used for menu display)
pagename = $(shell echo $(notdir $(basename $<)) | tr '[:upper:]' '[:lower:]')

# binaries
PANDOC      = /usr/local/bin/pandoc
TEMPLATE_DIR= /opt/swib.org/etc/pandoc_templates
EXT_OPTS    := --standalone -f markdown+pipe_tables+fenced_divs+bracketed_spans -t html --email-obfuscation=references
TMPL_OPTS   := --template $(TEMPLATE_DIR)/default.html5 --css styles/normalize.css --css styles/simple.css
VAR_OPTS    = --variable lang:en --variable is_$(pagename)

all: $(HTML_FILES)

%.html: %.md
	@echo $@
	@$(PANDOC) $(TMPL_OPTS) $(EXT_OPTS) $(VAR_OPTS) -o $@ $<

