#!/usr/bin/env bats

## This file tests the compilation of the "asm_project" in the "examples"
## folder

setup_file() {
    export MAKE_DIR="$BATS_TEST_DIRNAME/../"
    export PROJECT_DIR="$BATS_TEST_DIRNAME/../examples/asm_project"
    export BUILD_DIR="${PROJECT_DIR}/build"
    export ELF_FILE="${BUILD_DIR}/exe.elf"
}

setup() {
    load "framework/bats-support/load"
    load "framework/bats-assert/load"
    load "framework/bats-file/load"

    rm -rf "${BUILD_DIR}"

    assert_dir_not_exist "${BUILD_DIR}"
}

teardown() {
    true
}

teardown_file() {
    true
}

@test "Compilation should succeed" {
    command -v qemu-system-arm
    command -v arm-none-eabi-gcc

    run make -C "${PROJECT_DIR}" compile
    assert_success
    assert_file_exist "${ELF_FILE}"
}

@test "Trying to run a cross compiled file locally should fail" {
    run make -C "${PROJECT_DIR}" run
    assert_failure
}

@test "Launching and killing QEMU simulation environment" {
    run make -C "${PROJECT_DIR}" sim \
        SIM="qemu-system-arm"
    assert_success
    assert_file_exists "${BUILD_DIR}/sim.pid"

    run make -C "${PROJECT_DIR}" kill_sim \
        SIM="qemu-system-arm"
    assert_success
    assert_file_not_exist "${BUILD_DIR}/sim.pid"
}

@test "Running QEMU simulation" {
    command -v gdb-multiarch

    run make -C "${PROJECT_DIR}" debug \
        SIM="qemu-system-arm" \
        GDB="gdb-multiarch" \
        GDBSCRIPT="debug.gdb"
    assert_success
    assert_file_not_exist "${BUILD_DIR}/sim.pid"
    assert_output --partial "Value retrieved from gdb: 12"
}
