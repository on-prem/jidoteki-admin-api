# Makefile

# Generic
.PHONY: all check run-tests html javascript js minify ui

all: check

check: run-tests

run-tests:
		JIDO_ADMIN_PATH=$(PREFIX_DIR)/opt/jidoteki/tinyadmin PIL_NAMESPACES=false ./test.l

html:
		jade -o . -P -E html ui/index.jade

javascript:
		cat ui/license.coffee ui/generic.coffee ui/ui.coffee | coffee --no-header -c -s > docs/ui.js

js: javascript

minify:
		head -n 8 docs/ui.js > docs/ui.min.js
		minify docs/ui.js >> docs/ui.min.js

ui: html javascript minify
