#!/bin/bash

JUNEST_ROOT=$(readlink -f $(dirname $0)/../..)

source "$JUNEST_ROOT/tests/utils/utils.sh"

source "$JUNEST_ROOT/lib/utils/utils.sh"
source "$JUNEST_ROOT/lib/core/common.sh"
source "$JUNEST_ROOT/lib/core/chroot.sh"

# Disable the exiterr
set +e

function oneTimeSetUp(){
    setUpUnitTests
}

function setUp(){
    cwdSetUp
    junestSetUp
    init_mocks
}

function tearDown(){
    junestTearDown
    cwdTearDown
}

function init_mocks() {
    chroot_cmd() {
        [ "$JUNEST_ENV" != "1" ] && return 1
        echo "chroot_cmd $@"
    }
    GROOT=chroot_cmd
}

function test_run_env_as_groot_cmd(){
    assertCommandSuccess run_env_as_groot "" "false" pwd
    assertEquals "chroot_cmd -b $HOME -b /tmp -b /proc -b /sys -b /dev $JUNEST_HOME /bin/sh --login -c pwd" "$(cat $STDOUTF)"
}

function test_run_env_as_groot_no_cmd(){
    assertCommandSuccess run_env_as_groot "" "false" ""
    assertEquals "chroot_cmd -b $HOME -b /tmp -b /proc -b /sys -b /dev $JUNEST_HOME /bin/sh --login -c /bin/sh --login" "$(cat $STDOUTF)"
}

function test_run_env_as_groot_nested_env(){
    JUNEST_ENV=1
    assertCommandFailOnStatus 106 run_env_as_groot "" "false" ""
    unset JUNEST_ENV
}

function test_run_env_as_groot_cmd_with_backend_args(){
    assertCommandSuccess run_env_as_groot "-n -b /home/blah" "false" pwd
    assertEquals "chroot_cmd -b $HOME -b /tmp -b /proc -b /sys -b /dev -n -b /home/blah $JUNEST_HOME /bin/sh --login -c pwd" "$(cat $STDOUTF)"
}

function test_run_env_as_chroot_cmd(){
    assertCommandSuccess run_env_as_chroot "" "false" pwd
    assertEquals "chroot_cmd $JUNEST_HOME /bin/sh --login -c pwd" "$(cat $STDOUTF)"
}

function test_run_env_as_chroot_no_cmd(){
    assertCommandSuccess run_env_as_chroot "" "false" ""
    assertEquals "chroot_cmd $JUNEST_HOME /bin/sh --login -c /bin/sh --login" "$(cat $STDOUTF)"
}

function test_run_env_as_choot_nested_env(){
    JUNEST_ENV=1
    assertCommandFailOnStatus 106 run_env_as_chroot "" "false" ""
    unset JUNEST_ENV
}

function test_run_env_as_chroot_cmd_with_backend_args(){
    assertCommandSuccess run_env_as_chroot "-n -b /home/blah" "false" pwd
    assertEquals "chroot_cmd -n -b /home/blah $JUNEST_HOME /bin/sh --login -c pwd" "$(cat $STDOUTF)"
}

source $JUNEST_ROOT/tests/utils/shunit2
