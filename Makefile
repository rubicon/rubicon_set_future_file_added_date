SHELL := /bin/bash

.PHONY: all setup fmt lint test install

all: fmt lint test

setup:
	@command -v shellcheck >/dev/null || (echo "Install shellcheck: brew install shellcheck" && exit 1)
	@command -v shfmt >/dev/null || (echo "Install shfmt: brew install shfmt" && exit 1)
	@command -v bats >/dev/null || (echo "Install bats: brew install bats-core" && exit 1)
	@echo "Tools OK"

fmt:
	shfmt -w .

lint:
	shellcheck rubicon_set_future_file_added_date.sh

test:
	mkdir -p test && bats -r test

install:
	INSTALL_DIR=$$(if [ -d /opt/homebrew/bin ]; then echo /opt/homebrew/bin; else echo /usr/local/bin; fi); \
	install -m 0755 ./rubicon_set_future_file_added_date.sh $$INSTALL_DIR/rubicon-set-date && \
	echo "Installed to $$INSTALL_DIR/rubicon-set-date"
