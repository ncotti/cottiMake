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

    run make -C "${PROJECT_DIR}" --no-print-directory compile
    assert_success
    refute_output
}

@test "Clean command works as expected" {
    run make -C "${PROJECT_DIR}" --no-print-directory clean
    assert_success
    refute_output

    run make -C "${PROJECT_DIR}" compile
    assert_success

    run make -C "${PROJECT_DIR}" clean
    assert_success
    assert_output --partial "erased"
    assert_dir_not_exist "${BUILD_DIR}"

    run make -C "${PROJECT_DIR}" --no-print-directory clean
    assert_success
    refute_output
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

    run make -C "${PROJECT_DIR}" --no-print-directory dasm
    assert_success
    refute_output
}

@test "Header generation" {
    run make -C "${PROJECT_DIR}" headers
    assert_success
    assert_output --partial "[HEAD]"
    assert_output --partial "build/info/src/helper.header"
    assert_output --partial "build/info/c_project_exe.header"

    run make -C "${PROJECT_DIR}" --no-print-directory headers
    assert_success
    refute_output
}

@test "Run executable" {
    run make -C "${PROJECT_DIR}" run
    assert_success
    assert_output --partial "Executing: ${ELF_FILE}"
    assert_output --partial "C_project_out: 3"

    run make -C "${PROJECT_DIR}" run \
        EXEFLAGS="--flag"
    assert_success
    assert_output --partial "Executing: ${ELF_FILE} --flag"
    assert_output --partial "C_project_out: 3"
}

@test "Debug executable" {
    # run make -C "${PROJECT_DIR}" debug
    # assert_success
    # assert_output --partial "Debugging build/c_project.elf"
    # assert_output --partial "C_project_out: 3"
    false
    # Some output from gdb script?
}
