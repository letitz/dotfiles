#!/bin/bash

set -e
shopt -s inherit_errexit

# Get the directory of this script (top-level constant)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# --- Helper Functions ---

# Escapes special regular expression characters in a string so it can be
# safely used inside a sed search/replace command.
#
# Arguments:
#   $1 - The string to escape.
# Outputs:
#   The escaped string to stdout.
escape_for_sed() {
    local str="${1}"
    # Use printf instead of echo to safely handle arbitrary strings
    # (e.g., leading hyphens or backslashes) without option expansion.
    printf '%s\n' "${str}" | sed 's/[^^$*.[\]]/\\&/g'
}

# Safely writes or updates a block of configuration text inside a target file.
# The block content is read from a source file. If the target file does not
# exist, it is created. If the block is already present, it is replaced.
# The block is wrapped in unique markers derived from the comment prefix.
#
# Arguments:
#   $1 - Target file path (e.g., ~/.bashrc).
#   $2 - Source file path containing the block content (no markers).
#   $3 - Comment prefix used for the target file (e.g., '#' for Bash, '"' for Vim).
update_file_with_block() {
    local target_file="${1}"
    local source_file="${2}"
    local comment_prefix="${3}"

    local start_marker="${comment_prefix} --- Added by dotfiles install.sh (START) ---"
    local end_marker="${comment_prefix} --- Added by dotfiles install.sh (END) ---"

    # Ensure target directory exists
    mkdir -p "$(dirname "${target_file}")"

    # Step 1: If target file does not exist, touch it (create it empty)
    if [[ ! -f "${target_file}" ]]; then
        echo "[+] Creating ${target_file}..."
        touch "${target_file}"
    fi

    # Step 2: If the block is already present, delete it
    if grep -qF "${start_marker}" "${target_file}"; then
        echo "[+] Updating ${target_file} (removing existing block)..."
        local esc_start
        esc_start=$(escape_for_sed "${start_marker}")
        local esc_end
        esc_end=$(escape_for_sed "${end_marker}")

        sed -i "/${esc_start}/,/${esc_end}/d" "${target_file}"
    else
        echo "[+] Configuring ${target_file} (appending block)..."
    fi

    # Step 3: Centralized step to append the new block wrapped in markers
    # Ensure there is a newline before the block if the file is not empty,
    # but only if the last line doesn't already end the file with an empty line.
    if [[ -s "${target_file}" ]]; then
        local last_line
        last_line=$(tail -n 1 "${target_file}")
        if [[ -n "${last_line}" ]]; then
            echo "" >>"${target_file}"
        fi
    fi

    {
        echo "${start_marker}"
        cat "${source_file}"
        echo "${end_marker}"
    } >>"${target_file}"
}

# Resolves a dotfiles template by name, expands its {{DOTFILES_DIR}} placeholders
# using the global DOTFILES_DIR constant, and writes/updates it inside a target
# file using update_file_with_block.
#
# Arguments:
#   $1 - Target file path (e.g., ~/.bashrc).
#   $2 - Template name (e.g., "bashrc", "vimrc" - resolves to templates/<name>).
#   $3 - Comment prefix used for the target file (e.g., '#').
#   $4 - Path to the temporary installation directory.
update_file_with_template() {
    local target_file="${1}"
    local template_name="${2}"
    local comment_prefix="${3}"
    local temp_dir="${4}"

    local template_path="${DOTFILES_DIR}/templates/${template_name}"
    if [[ ! -f "${template_path}" ]]; then
        echo "[-] Error: Template ${template_name} not found at ${template_path}"
        exit 1
    fi

    # Store expanded template under the same name inside the central temp dir
    local temp_block_file="${temp_dir}/${template_name}"
    sed "s|{{DOTFILES_DIR}}|${DOTFILES_DIR}|g" "${template_path}" >"${temp_block_file}"

    update_file_with_block "${target_file}" "${temp_block_file}" "${comment_prefix}"

    rm "${temp_block_file}"
}

# Creates a symlink pointing to a source target. If a file, directory, or
# incorrect symlink already exists at the target location, it warns the user,
# backs it up by appending '.bak', and then creates the symlink.
# Safe: aborts if the '.bak' file already exists to prevent data loss.
#
# Arguments:
#   $1 - The source path (what the symlink points to).
#   $2 - The target symlink path (where the symlink is created).
create_symlink() {
    local source="${1}"
    local target="${2}"

    # If target exists (as file, dir, or symlink)
    if [[ -e "${target}" ]] || [[ -L "${target}" ]]; then
        # If it is already a symlink pointing to the correct source, we are done.
        local current_link
        current_link=$(readlink "${target}" || true)
        if [[ -L "${target}" ]] && [[ "${current_link}" = "${source}" ]]; then
            echo "[i] Symlink ${target} already points to ${source}"
            return
        fi

        # Otherwise, we need to back it up and replace it.
        echo "[!] Warning: ${target} exists. Backing up to ${target}.bak"
        if [[ -e "${target}.bak" ]] || [[ -L "${target}.bak" ]]; then
            echo "[-] Error: Backup ${target}.bak already exists. Manual intervention required."
            exit 1
        fi
        mv "${target}" "${target}.bak"
    fi

    # Now create the symlink
    echo "[+] Creating symlink ${target} -> ${source}"
    mkdir -p "$(dirname "${target}")"
    ln -s "${source}" "${target}"
}

# Downloads a file to the specified target path if it does not already exist.
#
# Arguments:
#   $1 - The URL to download the file from.
#   $2 - The target file path.
#   $3 - A description for log messages (e.g., "Vim colorscheme").
download_file() {
    local url="${1}"
    local target_path="${2}"
    local description="${3}"

    if [[ ! -f "${target_path}" ]]; then
        echo "[+] Downloading ${description}..."
        curl -sSLo "${target_path}" --create-dirs "${url}"
    else
        echo "[i] ${description} already downloaded."
    fi
}

# Copies a file from source to destination if the destination does not already exist.
# Creates target parent directories if they are missing.
#
# Arguments:
#   $1 - The source file path.
#   $2 - The destination file path.
#   $3 - A description for log messages (e.g., "Vim colorscheme").
copy_file() {
    local src="${1}"
    local dest="${2}"
    local description="${3}"

    if [[ ! -f "${dest}" ]]; then
        echo "[+] Installing ${description}..."
        mkdir -p "$(dirname "${dest}")"
        cp "${src}" "${dest}"
    else
        echo "[i] ${description} already installed."
    fi
}

# Sweeps up and deletes all temporary directories matching the prefix
# /tmp/dotfiles-install.* to clean up both the active installation temp
# directory and any pre-existing stale directories.
cleanup_temp_dirs() {

    for temp_dir in /tmp/dotfiles-install.*; do
        if [[ -d "${temp_dir}" ]]; then
            echo "[i] Removing temporary directory: ${temp_dir}"
            rm -rf "${temp_dir}"
        fi
    done
}

# --- Configuration Sections ---

# Appends or updates the dotfiles Bash configuration block in the user's ~/.bashrc.
# Uses the "bashrc" template and '#' comment markers.
#
# Arguments:
#   $1 - Path to the temporary installation directory.
configure_bash() {
    local temp_dir="${1}"
    echo "[+] Configuring Bash..."
    local BASHRC="${HOME}/.bashrc"
    update_file_with_template "${BASHRC}" "bashrc" "#" "${temp_dir}"
}

# Configures Vim by copying the centrally downloaded colorscheme file and
# appending/updating the dotfiles runtimepath settings in the user's ~/.vimrc.
# Uses the "vimrc" template and '"' comment markers.
#
# Arguments:
#   $1 - Path to the temporary installation directory.
configure_vim() {
    local temp_dir="${1}"
    echo "[+] Configuring Vim..."
    local colorscheme_source="${temp_dir}/gruvbox8_hard.vim"
    local VIM_COLOR_FILE="${HOME}/.vim/colors/gruvbox8_hard.vim"
    copy_file "${colorscheme_source}" "${VIM_COLOR_FILE}" "Vim colorscheme"

    local VIMRC="${HOME}/.vimrc"
    update_file_with_template "${VIMRC}" "vimrc" "\"" "${temp_dir}"
}

# Configures Neovim by symlinking the repository's nvim configuration folder
# to ~/.config/nvim and copying the centrally downloaded colorscheme file.
#
# Arguments:
#   $1 - Path to the temporary installation directory.
configure_neovim() {
    local temp_dir="${1}"
    echo "[+] Configuring Neovim..."
    create_symlink "${DOTFILES_DIR}/nvim" "${HOME}/.config/nvim"

    local colorscheme_source="${temp_dir}/gruvbox8_hard.vim"
    local NVIM_COLOR_FILE="${HOME}/.local/share/nvim/site/colors/gruvbox8_hard.vim"
    copy_file "${colorscheme_source}" "${NVIM_COLOR_FILE}" "Neovim colorscheme"
}

# Configures Tmux by cloning the Tmux Plugin Manager (TPM) if it's missing
# and symlinking the repository's tmux.conf to ~/.tmux.conf.
#
# Arguments:
#   $1 - Path to the temporary installation directory.
configure_tmux() {
    echo "[+] Configuring Tmux..."
    local TPM_DIR="${HOME}/.tmux/plugins/tpm"
    if [[ ! -d "${TPM_DIR}" ]]; then
        echo "[+] Cloning Tmux Plugin Manager..."
        git clone https://github.com/tmux-plugins/tpm "${TPM_DIR}"
    else
        echo "[i] TPM already installed."
    fi

    create_symlink "${DOTFILES_DIR}/tmux.conf" "${HOME}/.tmux.conf"
}

# Prints a completion message listing all remaining manual installation steps
# that cannot be safely or reliably automated.
print_completion_message() {
    echo "[+] Installation complete!"
    echo "[!] Remaining manual steps:"
    echo "    1. Run tmux and press 'Ctrl-A I' to install plugins."
    echo "    2. Install 'Hack font' manually if needed."
    echo "    3. Apply gruvbox8 theme to gnome-terminal manually."
    echo "    4. (Optional) If prompt in tmux is not colored, install 'ncurses-term' package."
}

# --- Main Function ---

# Main entrypoint for the script. Manages central resources (like the temporary
# download directory and colorscheme download) and executes all configuration
# steps sequentially.
#
# Arguments:
#   $@ - Optional arguments passed to the script.
main() {
    echo "[+] Installing dotfiles from ${DOTFILES_DIR}"

    # Create a temporary directory in /tmp for central downloads
    local temp_download_dir
    temp_download_dir=$(mktemp -d -t dotfiles-install.XXXXXX)
    echo "[i] Created temporary directory: ${temp_download_dir}"

    # Download colorscheme once to the temp directory
    local colorscheme_url="https://raw.githubusercontent.com/lifepillar/vim-gruvbox8/master/colors/gruvbox8_hard.vim"
    local colorscheme_temp="${temp_download_dir}/gruvbox8_hard.vim"
    download_file "${colorscheme_url}" "${colorscheme_temp}" "Vim colorscheme"

    configure_bash "${temp_download_dir}"
    configure_vim "${temp_download_dir}"
    configure_neovim "${temp_download_dir}"
    configure_tmux

    cleanup_temp_dirs

    print_completion_message
}

main "$@"
