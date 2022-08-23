# Makefile
# nbt, 23.08.2022

MD_FILES := $(shell find ../var/html/swib21 -name "*.md")
HTML_FILES := $(MD_FILES:.md=.html)

# binaries
PANDOC=/usr/local/bin/pandoc
EXT_OPTS    := --standalone -f markdown+pipe_tables+fenced_divs+bracketed_spans -t html
TMPL_OPTS   := --template ../etc/pandoc_templates/default.html5 --css /styles/simple.css

all: $(HTML_FILES)

$(HTML_FILES): $(MD_FILES)
	@echo $@
	@$(PANDOC) $(TMPL_OPTS) $(EXT_OPTS) -o $@ $<

