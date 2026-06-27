#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

## This file tests the "make test" command and all implications related
## to compiling test files
## This test re-utilizes the "examples/c_project"

setup_file() {
    export MAKE_DIR="$BATS_TEST_DIRNAME/../"
    export PROJECT_DIR="$BATS_TEST_DIRNAME/../examples/c_project"
    export BUILD_DIR="${PROJECT_DIR}/build"
    export ELF_FILE="${PROJECT_DIR}/build/c_project_exe.elf"

    command -v bear
    command -v clang-tidy
    command -v clang-format

    run make -C "${PROJECT_DIR}" clean
}

setup() {
    load "framework/bats-support/load"
    load "framework/bats-assert/load"
    load "framework/bats-file/load"

    rm -rf "${PROJECT_DIR}/build"

    assert_dir_not_exist "${PROJECT_DIR}/build"
}

teardown() {
    run make -C "${PROJECT_DIR}" clean
}

teardown_file() {
    true
}

@test "Using paths with ../ should not generate build artifacts outside the build folder" {
    false
}

@test "Test files should be included in the formatter" {
    run 
    false
}

@test "Test files should be included in the static analysis" {
    false
}

@test "Test files should not be included in normal compilation" {
    false
}

@test "Tests should be run successfully" {
    false
}

