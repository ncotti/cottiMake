#!/usr/bin/env bats

## This file tests the "make print[_XXX]" functionality.
## These are pre-compilation prints.

setup_file() {
    export MAKE_DIR="$BATS_TEST_DIRNAME/../"
}

setup() {
    load "framework/bats-support/load"
    load "framework/bats-assert/load"
    load "framework/bats-file/load"
}

teardown() {
    true
}

teardown_file() {
    true
}

@test "Print source files" {
    run make -C "${MAKE_DIR}" print_srcs
    false
}

@test "Print object files" {
    run make -C "${MAKE_DIR}" print_objs
    false
}


@test "Print header files" {
    run make -C ${MAKE_DIR} print_headers
    false
}


@test "Print all" {
    true
}