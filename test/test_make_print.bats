#!/usr/bin/env bats

## This file tests the "make print[_XXX]" functionality.
## These are pre-compilation prints.

setup_file() {
    export MAKE_DIR="$BATS_TEST_DIRNAME/.."

    export src_dir1="$BATS_FILE_TMPDIR/src1"
    export src_dir2="$BATS_FILE_TMPDIR/src2"

    export inc_dir1="$BATS_FILE_TMPDIR/inc1"
    export inc_dir2="$BATS_FILE_TMPDIR/inc2"

    export not_dir1="$BATS_FILE_TMPDIR/not_dir"
    export not_dir2="$BATS_FILE_TMPDIR/wrong_dir"

    export src_file1="${src_dir1}/main.c"
    export src_file2="${src_dir1}/help.c"
    export src_file3="${src_dir2}/hello.c"
    export src_file4="${src_dir2}/bye.c"

    export inc_file1="${inc_dir1}/main.h"
    export inc_file2="${inc_dir1}/help.h"
    export inc_file3="${inc_dir2}/hello.h"
    export inc_file4="${inc_dir2}/bye.h"

    export obj_file1="build/${src_dir1}/main.o"
    export obj_file2="build/${src_dir1}/help.o"
    export obj_file3="build/${src_dir2}/hello.o"
    export obj_file4="build/${src_dir2}/bye.o"

    export empty_dir="$BATS_FILE_TMPDIR/empty_dir"

    mkdir "${src_dir1}" "${src_dir2}" "${inc_dir1}" "${inc_dir2}"
    mkdir "${empty_dir}"
    touch "${src_file1}" "${src_file2}" "${src_file3}" "${src_file4}"
    touch "${inc_file1}" "${inc_file2}" "${inc_file3}" "${inc_file4}"

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

# When no external "SRC_DIRS" is declared, an error message should be shown
@test "No SRC_DIRS declared and print_src or print_obj is called" {
    run make -C "${MAKE_DIR}" -f cottimake.mk print_src
    assert_failure
    assert_output --partial "[ERROR #001]"

    run make -C "${MAKE_DIR}" -f cottimake.mk print_obj
    assert_failure
    assert_output --partial "[ERROR #001]"
}

@test "Print source files" {
    run make -C "${MAKE_DIR}" -f cottimake.mk print_src \
        SRC_DIRS="${src_dir1} ${src_dir2}"
    assert_success
    assert_output --partial "Source files:"
    assert_output --partial --stdin <<EOF
${src_file2}
${src_file1}
${src_file4}
${src_file3}

EOF
}

@test "Print object files" {
    run make -C "${MAKE_DIR}" -f cottimake.mk print_obj \
        SRC_DIRS="${src_dir1} ${src_dir2}"
    assert_success
    assert_output --partial "Object files:"
    assert_output --partial --stdin <<EOF
${obj_file2}
${obj_file1}
${obj_file4}
${obj_file3}
build/exe.elf

EOF
}

@test "No INC_DIRS declared and print_header is called" {
    run make -C "${MAKE_DIR}" -f cottimake.mk print_header \
        SRC_DIRS="${src_dir1}"
    assert_success
    assert_output --partial "Header files:"
}

@test "Print headers" {
    run make -C "${MAKE_DIR}" -f cottimake.mk print_header \
        SRC_DIRS="${src_dir1}" \
        INC_DIRS="${inc_dir1}"
    assert_success
    assert_output --partial "Header files:"
    assert_output --partial --stdin <<EOF
${inc_file2}
${inc_file1}

EOF
}

@test "Print sources, objects and headers" {
    run make -C "${MAKE_DIR}" -f cottimake.mk print \
        SRC_DIRS="${src_dir1}" \
        INC_DIRS="${inc_dir1} ${inc_dir2}"

    assert_success
    assert_output --partial "Source files:"
    assert_output --partial "Object files:"
    assert_output --partial "Header files:"
    assert_output --partial --stdin <<EOF
${src_file2}
${src_file1}

EOF
    assert_output --partial --stdin <<EOF
${obj_file2}
${obj_file1}
build/exe.elf

EOF

    assert_output --partial --stdin <<EOF
${inc_file2}
${inc_file1}
${inc_file4}
${inc_file3}

EOF
}
