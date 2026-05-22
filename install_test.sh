#!/bin/bash

set -e

# Get the directory of this script
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
TEST_HOME="${TEST_DIR}/test_home_dir"

# --- Sandbox Helpers ---

# Prepares the sandbox environment for a test case by clearing
# any previous configuration and creating an empty HOME directory.
setup() {
    rm -rf "${TEST_HOME}"
    mkdir -p "${TEST_HOME}"
}

# --- Assert Helpers ---

# Helper to assert file existence
assert_exists() {
    if [[ ! -e "${1}" ]] && [[ ! -L "${1}" ]]; then
        echo "FAIL: ${1} does not exist"
        exit 1
    fi
}

# Helper to assert symlink target
assert_symlink() {
    local link="${1}"
    local expected_target="${2}"
    assert_exists "${link}"
    if [[ ! -L "${link}" ]]; then
        echo "FAIL: ${link} is not a symlink"
        exit 1
    fi
    local actual_target
    actual_target=$(readlink "${link}")
    if [[ "${actual_target}" != "${expected_target}" ]]; then
        echo "FAIL: Symlink ${link} points to ${actual_target}, expected ${expected_target}"
        exit 1
    fi
}

# Helper to assert file contains string
assert_contains() {
    local file="${1}"
    local string="${2}"
    assert_exists "${file}"
    if ! grep -qF "${string}" "${file}"; then
        echo "FAIL: ${file} does not contain '${string}'"
        exit 1
    fi
}

# --- Test Cases ---

# Verifies a clean installation of the dotfiles setup on a fresh user environment.
# Asserts that all bash and vim blocks are appended, colorschemes are downloaded,
# and symlinks are created correctly.
test_clean_installation() {
    echo "Running Test Case: Clean Installation..."
    setup

    # Run install
    HOME="${TEST_HOME}" "${TEST_DIR}/install.sh" >/dev/null

    # Assert expected files exist and contain setup markers
    assert_contains "${TEST_HOME}/.bashrc" "# --- Added by dotfiles install.sh (START) ---"
    assert_contains "${TEST_HOME}/.bashrc" "source ${TEST_DIR}/prompt.sh"
    assert_contains "${TEST_HOME}/.vimrc" "set runtimepath^=${TEST_DIR}/vim"
    assert_exists "${TEST_HOME}/.vim/colors/gruvbox8_hard.vim"
    assert_symlink "${TEST_HOME}/.config/nvim" "${TEST_DIR}/nvim"
    assert_exists "${TEST_HOME}/.local/share/nvim/site/colors/gruvbox8_hard.vim"
    assert_exists "${TEST_HOME}/.tmux/plugins/tpm"
    assert_symlink "${TEST_HOME}/.tmux.conf" "${TEST_DIR}/tmux.conf"

    echo "PASS: Clean Installation"
}

# Verifies that the temporary installation directories created in /tmp are
# successfully deleted upon completion, and that any pre-existing stale
# directories with matching prefixes are swept away.
test_temp_dir_cleanup() {
    echo "Running Test Case: Temp Dir Cleanup..."
    setup

    # Create a fake stale directory to test sweeping
    local stale_dir="/tmp/dotfiles-install.stale-test"
    mkdir -p "${stale_dir}"
    touch "${stale_dir}/stale_file"

    # Run install
    HOME="${TEST_HOME}" "${TEST_DIR}/install.sh" >/dev/null

    # Verify that NO temporary directories matching /tmp/dotfiles-install.* exist
    for temp_dir in /tmp/dotfiles-install.*; do
        if [[ -d "${temp_dir}" ]]; then
            echo "FAIL: Found uncleared temporary directory: ${temp_dir}"
            exit 1
        fi
    done
    echo "Verified: All temporary directories matching /tmp/dotfiles-install.* were successfully cleaned up."

    echo "PASS: Temp Dir Cleanup"
}

# Verifies that the installation script is idempotent. Running it a second
# time on a previously configured environment should succeed without altering
# correct targets, duplicating lines, or throwing errors.
test_idempotency() {
    echo "Running Test Case: Idempotency..."
    setup

    # Run 1: Clean Installation
    HOME="${TEST_HOME}" "${TEST_DIR}/install.sh" >/dev/null

    # Run 2: Idempotent execution
    HOME="${TEST_HOME}" "${TEST_DIR}/install.sh" >/dev/null

    # Verify everything is still correct
    assert_symlink "${TEST_HOME}/.config/nvim" "${TEST_DIR}/nvim"
    assert_symlink "${TEST_HOME}/.tmux.conf" "${TEST_DIR}/tmux.conf"

    echo "PASS: Idempotency"
}

# Verifies that the backup functionality works correctly. If a file or symlink
# exists at a target location (e.g., ~/.tmux.conf) but points to a different
# source, the script should back it up to *.bak and create the correct symlink.
test_backup() {
    echo "Running Test Case: Backup..."
    setup

    # Run 1: Clean Installation
    HOME="${TEST_HOME}" "${TEST_DIR}/install.sh" >/dev/null

    # Modify a symlink to point to wrong place
    rm "${TEST_HOME}/.tmux.conf"
    ln -s /dev/null "${TEST_HOME}/.tmux.conf"

    # Run 2: Install again to trigger backup and repair
    HOME="${TEST_HOME}" "${TEST_DIR}/install.sh" >/dev/null

    # Verify backup was created and link was restored
    assert_symlink "${TEST_HOME}/.tmux.conf.bak" "/dev/null"
    assert_symlink "${TEST_HOME}/.tmux.conf" "${TEST_DIR}/tmux.conf"

    echo "PASS: Backup"
}

# Verifies the script's safety guardrails. If a backup target (e.g. *.bak) already
# exists when the script needs to perform a backup, the script should abort safely
# with an exit code of 1 to prevent data loss (overwriting the user's existing backup).
test_backup_safety() {
    echo "Running Test Case: Backup Safety..."
    setup

    # Run 1: Clean Installation
    HOME="${TEST_HOME}" "${TEST_DIR}/install.sh" >/dev/null

    # Run 2: Trigger a backup (creates .tmux.conf.bak)
    rm "${TEST_HOME}/.tmux.conf"
    ln -s /dev/null "${TEST_HOME}/.tmux.conf"
    HOME="${TEST_HOME}" "${TEST_DIR}/install.sh" >/dev/null

    # Modify link again (so it needs backup again)
    rm "${TEST_HOME}/.tmux.conf"
    ln -s /dev/null "${TEST_HOME}/.tmux.conf"

    # Run 3: Install again, it should FAIL because .tmux.conf.bak already exists
    if HOME="${TEST_HOME}" "${TEST_DIR}/install.sh" >/dev/null 2>&1; then
        echo "FAIL: install.sh should have failed because backup already exists"
        exit 1
    else
        echo "Expected failure occurred."
    fi

    echo "PASS: Backup Safety"
}

# --- Main Function ---

# Orchestrates the test suite execution. Runs all isolated test cases in sequence,
# performs final cleanup, and reports.
main() {
    echo "Starting install.sh tests..."
    echo "Using test HOME: ${TEST_HOME}"

    # Run isolated test cases
    test_clean_installation
    test_temp_dir_cleanup
    test_idempotency
    test_backup
    test_backup_safety

    # Final sandbox cleanup
    rm -rf "${TEST_HOME}"

    echo "ALL TESTS PASSED!"
}

main "$@"
