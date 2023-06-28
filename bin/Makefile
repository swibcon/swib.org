# Makefile
# nbt, 23.08.2022

# read current swib from config
LC_SWIB := $(shell grep ^swib: config.yaml | cut -d: -f2 | column -t | tr '[:upper:]' '[:lower:]' )

WEB_MD_FILES := $(shell find ../var/html/$(LC_SWIB) -name "*.md" | grep -v "../var/html/$(LC_SWIB)/sessions/" )
WEB_HTML_FILES := $(WEB_MD_FILES:.md=.html)
##$(warning $(WEB_HTML_FILES))

SLIDE_MD_FILES := $(shell find ../var/html/$(LC_SWIB)/sessions -name "*.md")
SLIDE_HTML_FILES := $(SLIDE_MD_FILES:.md=.html)
##$(warning $(SLIDE_HTML_FILES))

# current page name (used for menu display)
pagename = $(shell echo $(notdir $(basename $<)) | tr '[:upper:]' '[:lower:]')

# binaries
PANDOC          = /usr/bin/pandoc
#PANDOC          = /usr/local/bin/pandoc
TEMPLATE_DIR    = /opt/swib.org/etc/pandoc_templates
#TEMPLATE_DIR    = ~/git/swib.org/etc/pandoc_templates
WEB_TEMPLATE    := $(TEMPLATE_DIR)/swibweb.html5
SLIDE_TEMPLATE  := $(TEMPLATE_DIR)/sessionslide.html5
EXT_OPTS        := --standalone -f markdown+pipe_tables+fenced_divs+bracketed_spans -t html --email-obfuscation=references
VAR_OPTS        = --variable lc_swib:$(LC_SWIB) --variable lang:en --variable is_$(pagename)

# set different template options
$(WEB_HTML_FILES): TMPL_OPTS=--template $(WEB_TEMPLATE) --css styles/normalize.css --css styles/simple.css
$(SLIDE_HTML_FILES): TMPL_OPTS=--template $(SLIDE_TEMPLATE) --css ../styles/normalize.css --css ../styles/slide.css --css ../styles/simplyCountdown.theme.default.css


all: web slide


web: $(WEB_HTML_FILES)


slide: $(SLIDE_HTML_FILES)


%.html: %.md $(WEB_TEMPLATE) $(SLIDE_TEMPLATE)
	@echo $@
	@$(PANDOC) $(TMPL_OPTS) $(EXT_OPTS) $(VAR_OPTS) -o $@ $<


