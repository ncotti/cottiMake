#!/usr/bin/env bats

## This file tests the compilation of the "c_project" in the "examples"
## folder

setup_file() {
    export MAKE_DIR="$BATS_TEST_DIRNAME/../"
    export PROJECT_DIR="$BATS_TEST_DIRNAME/../examples/c_project"
    export BUILD_DIR="${PROJECT_DIR}/build"
    export ELF_FILE="${PROJECT_DIR}/build/c_project_exe.elf"
}

setup() {
    load "framework/bats-support/load"
    load "framework/bats-assert/load"
    load "framework/bats-file/load"

    rm -rf "${PROJECT_DIR}/build"

    assert_dir_not_exist "${PROJECT_DIR}/build"
}

teardown() {
    true
}

teardown_file() {
    true
}

@test "Compiling two consecutive times should not re-compile anything" {
    run make -C "${PROJECT_DIR}" compile
    assert_success

    run make -C "${PROJECT_DIR}" compile
    assert_success
    assert_output --partial "Nothing to compile."
}

@test "Clean command works as expected" {
    run make -C "${PROJECT_DIR}" clean
    assert_success
    assert_output --partial "Nothing to clean."

    run make -C "${PROJECT_DIR}" compile
    assert_success

    run make -C "${PROJECT_DIR}" clean
    assert_success
    assert_output --partial "erased"
    assert_dir_not_exist ${BUILD_DIR}

    run make -C "${PROJECT_DIR}" clean
    assert_success
    assert_output --partial "Nothing to clean."
}

@test "Expected compilation output" {
    run make -C "${PROJECT_DIR}" compile
    assert_success
    assert_output --partial "src/helper.c"
    assert_output --partial "src/main.c"
    assert_output --partial "src/nested_src/add.c"
    assert_output --partial "src/nested_src/sub.c"
    assert_output --partial "build/c_project_exe.elf"
}

@test "Binary file generation" {
    run make -C "${PROJECT_DIR}" bin
    assert_success
    assert_output --partial "[LD]"
    assert_output --partial "[BIN]"

    make -C "${PROJECT_DIR}" clean
    make -C "${PROJECT_DIR}" compile
    run make -C "${PROJECT_DIR}" bin
    assert_success
    assert_output --partial "[BIN]"
    refute_output --partial "[CC]"
    refute_output --partial "[LD]"
}

@test "Disassembly generation" {
    run make -C "${PROJECT_DIR}" dasm
    assert_success
    assert_output --partial "[DASM]"
    assert_output --partial "build/info/src/helper.d"
    assert_output --partial "build/info/c_project_exe.d"

    run make -C "${PROJECT_DIR}" dasm
    assert_success
    assert_output --partial "Nothing to disassemble."
}

@test "Header generation" {
    run make -C "${PROJECT_DIR}" headers
    assert_success
    assert_output --partial "[HEAD]"
    assert_output --partial "build/info/src/helper.header"
    assert_output --partial "build/info/c_project_exe.header"

    run make -C "${PROJECT_DIR}" headers
    assert_success
    assert_output --partial "Nothing to generate."
}