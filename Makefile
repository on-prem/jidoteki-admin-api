# Makefile

# Generic
.PHONY: all check run-tests html javascript js minify ui docs

all: check

check: run-tests

run-tests:
		JIDO_ADMIN_PATH=$(PREFIX_DIR)/opt/jidoteki/tinyadmin ./test.l

html:
		jade -o . -P -E html ui/index.jade

javascript:
		cat ui/license.coffee ui/generic.coffee ui/ui.coffee | coffee --no-header -c -s > docs/ui.js

js: javascript

minify:
		head -n 8 docs/ui.js > docs/ui.min.js
		minify docs/ui.js >> docs/ui.min.js

docs:
		cd docs && \
		marked --gfm -i API.md -o api.html && \
		cat strapdown-prefix.html api.html strapdown-suffix.html > index.html && \
		rm api.html

ui: html javascript minify
