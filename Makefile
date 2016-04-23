# Makefile

PIL_MODULE_DIR ?= .modules
REPO_PREFIX ?= https://github.com/aw

## Edit below
JSON_REPO = $(REPO_PREFIX)/picolisp-json.git
JSON_DIR = $(PIL_MODULE_DIR)/picolisp-json/HEAD
JSON_REF ?= v1.1.0
## Edit above

# Unit testing
TEST_REPO = $(REPO_PREFIX)/picolisp-unit.git
TEST_DIR = $(PIL_MODULE_DIR)/picolisp-unit/HEAD

# Generic
.PHONY: all clean

all: $(JSON_DIR)

$(JSON_DIR):
		mkdir -p $(JSON_DIR) && \
		git clone $(JSON_REPO) $(JSON_DIR) && \
		cd $(JSON_DIR) && \
		git checkout $(JSON_REF) && \
		$(MAKE)

$(TEST_DIR):
		mkdir -p $(TEST_DIR) && \
		git clone $(TEST_REPO) $(TEST_DIR)

check: all $(TEST_DIR) run-tests

run-tests:
		./test.l

html:
		jade -o . -P -E html ui/index.jade

javascript:
		coffee --no-header -c -o docs/ ui/ui.coffee

js: javascript

minify:
		head -n 8 docs/ui.js > docs/ui.min.js
		minify docs/ui.js >> docs/ui.min.js

ui: html javascript minify

clean:
		rm -rf $(JSON_DIR) $(TEST_DIR)
