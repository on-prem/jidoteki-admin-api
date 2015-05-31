# Makefile

PIL_MODULE_DIR ?= .modules

## Edit below
JSON_REPO = https://github.com/aw/picolisp-json.git
JSON_DIR = $(PIL_MODULE_DIR)/picolisp-json/HEAD
JSON_REF ?= v0.6.2
## Edit above

# Unit testing
TEST_REPO = https://github.com/aw/picolisp-unit.git
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

clean:
		rm -rf $(JSON_DIR) $(TEST_DIR)
