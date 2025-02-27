ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
NB_CORES := $(shell grep --count '^processor' /proc/cpuinfo)
PYLINT_RC := $(ROOT_DIR)/.pylintrc
PYLINT_DISABLE:= all
PYLINT_JOBS := $(NB_CORES)
PYLINT_SUGGEST_FIX := y
PYLINT_PY_VERSION := 3.6
PYLINT_PARAMETERS := --jobs=$(PYLINT_JOBS) --suggestion-mode=$(PYLINT_SUGGEST_FIX) --py-version=$(PYLINT_PY_VERSION) --rcfile=$(PYLINT_RC)
TARGET := $(shell lscpu | head -1 | sed -e 's/Architecture:\s*//g')
COVERAGE_DIR ?= /tmp/cov
GDBINIT_TMP = $(shell mktemp)
GDBINIT_BACKUP = $(GDBINIT_TMP)
GEFRC_TMP = $(shell mktemp)
GEFRC_BACKUP = $(GEFRC_TMP)
TMPDIR ?= $(shell mktemp -d)
WORKING_DIR := $(TMPDIR)
GEF_PATH := $(WORKING_DIR)/gef.py
PYTEST_PARAMETERS := --verbose --forked --numprocesses=$(NB_CORES)
BRANCH := $(shell git rev-parse --abbrev-ref HEAD)


.PHONY: test test_% Test% testbins clean lint


setup:
	@echo "[+] Downloading gef.py -> '$(GEF_PATH)'"
	@wget -O $(GEF_PATH) -q https://gef.blah.cat/dev

test: testbins setup
	TMPDIR=$(WORKING_DIR) GEF_PATH=$(GEF_PATH) python3 -m pytest $(PYTEST_PARAMETERS) -k "not benchmark"

test_%: testbins setup
	TMPDIR=$(WORKING_DIR) GEF_PATH=$(GEF_PATH) python3 -m pytest $(PYTEST_PARAMETERS) -k $@

testbins: $(wildcard tests/binaries/*.c)
	@TMPDIR=$(WORKING_DIR) $(MAKE) -j $(NB_CORES) -C tests/binaries TARGET=$(TARGET) TMPDIR=$(WORKING_DIR) all

clean:
	TMPDIR=$(WORKING_DIR) $(MAKE) -j $(NB_CORES) -C tests/binaries clean
	@rm -rf $(WORKING_DIR)/gef-* $(WORKING_DIR)/gef.py || true

lint:
	python3 -m pylint $(PYLINT_PARAMETERS) $(GEF_PATH)
	python3 -m pylint $(PYLINT_PARAMETERS) $(wildcard tests/*/*.py)

coverage:
	@! ( [ -d $(COVERAGE_DIR) ] && echo "COVERAGE_DIR=$(COVERAGE_DIR) exists already")
	@mkdir -p $(COVERAGE_DIR)
	@COVERAGE_DIR=$(COVERAGE_DIR) $(MAKE) test
	@coverage combine $(COVERAGE_DIR)/*
	@coverage html --include "*/gef.py"
	@rm -rf $(COVERAGE_DIR)

