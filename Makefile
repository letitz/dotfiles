.DEFAULT_GOAL := test

.PHONY: test install format lint

test:
	./install_test.sh

install:
	./install.sh

format:
	shfmt -w install.sh install_test.sh

lint:
	shellcheck install.sh install_test.sh
	shfmt -d install.sh install_test.sh
