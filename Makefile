.DEFAULT_GOAL := test

.PHONY: test install

test:
	./install_test.sh

install:
	@./install.sh
