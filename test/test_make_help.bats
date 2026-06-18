#!/usr/bin/env bats

## This file tests the "make help" functionality

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

## Note: target help should execute even though no variables have been set
@test "Default target is help" {
    run make -C "${MAKE_DIR}"
    make_output="$output"

    run make -C "${MAKE_DIR}" help
    make_help_output="$output"

    assert_equal "${make_output}" "${make_help_output}"
}

@test "All targets have a help string" {
    targets=$(awk -F ":" '/^[a-zA-Z0-9_-]+:/ {print $1}' Makefile ./*.mk | sort)
    printf "${targets}"
    targets_qtty=$(echo "${targets}" | wc -l)

    help_targets=$(make help | sort | awk '{
        gsub(/^[a-zA-Z0-9_-]+[ \t]+/, "", $1); print $1}')
    help_targets_qtty=$(echo "${help_targets}" | wc -l)

    assert_equal "${targets_qtty}" "${help_targets_qtty}"
}

@test "All targets have the .PHONY attribute" {
    targets=$(awk -F ":" '/^[a-zA-Z0-9_-]+:/ {print $1}' Makefile | sort)

    phony_targets=$(awk -F ":|##" '/^.PHONY:/ {
        gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}' Makefile | sort)

    assert_equal "${targets}" "${phony_targets}"
}

