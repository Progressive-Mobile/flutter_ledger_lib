.DEFAULT_GOAL := help
PROJECTNAME=$(shell basename "$(PWD)")
SOURCES=$(sort $(wildcard ./src/*.rs ./src/**/*.rs))

SHELL := /bin/bash

# ##############################################################################
# # GENERAL
# ##############################################################################

.PHONY: help
help: makefile
	@echo
	@echo " Available actions in "$(PROJECTNAME)":"
	@echo
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
	@echo

## init: Install missing dependencies.
.PHONY: init
init:
	rustup override set nightly
	rustup target add aarch64-apple-darwin x86_64-apple-darwin
	rustup target add x86_64-pc-windows-gnu
	rustup toolchain install stable-x86_64-pc-windows-gnu
	@if [ $$(uname) == "Darwin" ] ; then cargo install cargo-lipo ; fi
	cargo install cbindgen

## :

# ##############################################################################
# # RECIPES
# ##############################################################################

## all: Compile iOS, Android and bindings targets
all: macos windows bindings

## macos: Compile the macOS libraries
macos: target/x86_64-apple-darwin/release/libflutter_ledger_lib.dylib target/aarch64-apple-darwin/release/libflutter_ledger_lib.dylib

target/x86_64-apple-darwin/release/libflutter_ledger_lib.dylib: $(SOURCES)
	@if [ $$(uname) == "Darwin" ] ; then \
		cargo lipo --release --targets x86_64-apple-darwin ; \
		cp target/x86_64-apple-darwin/release/libflutter_ledger_lib.dylib ../macos/libflutter_ledger_lib_x86_64.dylib ; \
		else echo "Skipping macOS compilation on $$(uname)" ; \
	fi
	@echo "[DONE] $@"

target/aarch64-apple-darwin/release/libflutter_ledger_lib.dylib: $(SOURCES)
	@if [ $$(uname) == "Darwin" ] ; then \
		cargo lipo --release --targets aarch64-apple-darwin ; \
		cp target/aarch64-apple-darwin/release/libflutter_ledger_lib.dylib ../macos/libflutter_ledger_lib_arch64.dylib ; \
		else echo "Skipping macOS compilation on $$(uname)" ; \
	fi
	@echo "[DONE] $@"

windows: $(SOURCES)
	cargo build --target x86_64-pc-windows-gnu --release ; \
	cp target/x86_64-pc-windows-gnu/release/flutter_ledger_lib.dll ../windows/include/flutter_ledger_lib.dll ; \
	
	@echo "[DONE] $@"


## bindings: Generate the .h file for iOS
bindings: target/bindings.h

target/bindings.h: $(SOURCES)
	cbindgen ./src/lib.rs -c cbindgen.toml | grep -v \#include | uniq > $@
	@echo "[DONE] $@"

## :

# ##############################################################################
# # OTHER
# ##############################################################################

## clean:
.PHONY: clean
clean:
	cargo clean
	rm -f target/bindings.h target/bindings.src.h

## test:
.PHONY: test
test:
	cargo test