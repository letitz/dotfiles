#!/bin/bash
# vim: tw=80 ts=2 sw=2:

set -eu

ROOT_DCONF_DIR='/org/gnome/terminal/legacy/profiles:/'

# ansi_colors COLOR1 ... COLOR16
function ansi_colors() {
  echo -n "['$1'"
  for i in {2..16}; do    
    echo -n ",'${!i}'"
  done
  echo "]"
}

# colorscheme NAME FG_COLOR BG_COLOR ANSI_COLORS
function colorscheme() {
  NAME="$1"
  FG_COLOR="$2"
  BG_COLOR="$3"
  ANSI_COLORS="$4"

  echo "${NAME};${FG_COLOR};${BG_COLOR};${ANSI_COLORS}"
}

function unpack_colorscheme_field(){
  PACKED="$1"
  FIELD="$2"
  echo "${PACKED}" | cut -d ';' -f "${FIELD}"
}

# colorscheme_name COLORSCHEME
function colorscheme_name() {
  unpack_colorscheme_field "$1" 1
}

# colorscheme_fg_color COLORSCHEME
function colorscheme_fg_color() {
  unpack_colorscheme_field "$1" 2
}

# colorscheme_bg_color COLORSCHEME
function colorscheme_bg_color() {
  unpack_colorscheme_field "$1" 3
}

# colorscheme_ansi_colors COLORSCHEME
function colorscheme_ansi_colors() {
  unpack_colorscheme_field "$1" 4
}

GRUVBOX8_COLORSCHEME=$(colorscheme "gruvbox8" \
    "#ebdbb2" \
    "#1d2021" \
    $(ansi_colors \
        "#1d2021" \
        "#cc241d" \
        "#98971a" \
        "#d79921" \
        "#458588" \
        "#b16286" \
        "#689d6a" \
        "#a89984" \
        "#928374" \
        "#fb4934" \
        "#b8bb26" \
        "#fabd2f" \
        "#83a598" \
        "#d3869b" \
        "#8ec07c" \
        "#ebdbb2"
  )
)

COLORSCHEMES=(
  "${GRUVBOX8_COLORSCHEME}"
)

# log ARGS...
# echo for stderr
function log() {
  echo 1>&2 "$@"
}

# die ARGS...
# log then exit with an error code
function die() {
  log "$@"
  exit 1
}

function get_profile_property() {
  PROFILE="$1"
  PROPERTY="$2" 

  dconf read "${PROFILE}${PROPERTY}"
}

# get_profile_name PROFILE
# Echoes the human-readable name for a gnome-terminal profile subdirectory.
function get_profile_name() {
  get_profile_property "$1" "visible-name"
}

# choose_number BASE_PROMPT MIN MAX
# Asks the user to choose a number between MIN and MAX, inclusive.
# BASE_PROMPT should not end in a newline.
function choose_number() {
  PROMPT="$1"
  MIN_NUMBER="$2"
  MAX_NUMBER="$3"
  while true; do
    read -p "$1 [${MIN_NUMBER} to ${MAX_NUMBER}]: " CHOSEN_NUMBER
    if [ "${CHOSEN_NUMBER}" -lt "${MIN_NUMBER}" ]; then
      continue
    fi
    if [ "${CHOSEN_NUMBER}" -gt "${MAX_NUMBER}" ]; then
      continue
    fi

    echo "${CHOSEN_NUMBER}"
    break
  done
}

# choose_profile
# Echoes the path to a valid gnome-terminal profile to modify.
function choose_profile() {
  # Build an array of profile subdirectories.
  PROFILES=()
  for PROFILE_SUBDIR in $(dconf list "${ROOT_DCONF_DIR}"); do
    PROFILES+=("${ROOT_DCONF_DIR}${PROFILE_SUBDIR}")
  done
  NUM_PROFILES="${#PROFILES[@]}"
  
  if [ "${NUM_PROFILES}" -eq 0 ]; then
    die "Error: found no gnome-terminal profiles to style."
  fi

  if [ "${NUM_PROFILES}" -eq 1 ]; then
    PROFILE="${PROFILES[0]}"
    PROFILE_NAME=$(get_profile_name "${PROFILE}")
    log "Found single gnome-terminal profile ${PROFILE_NAME}, using it."
    echo "${PROFILE}"
    return
  fi

  log "Available gnome-terminal profiles:"
  
  for i in $(seq 1 "${NUM_PROFILES}"); do
    PROFILE="${PROFILES[$(($i - 1))]}"
    PROFILE_NAME=$(get_profile_name "${PROFILE}")
    log "  #$i: ${PROFILE_NAME}"
  done

  choose_number "Choose a profile" 1 "${NUM_PROFILES}"
}

# find_colorscheme COLORSCHEME_NAME
# Echoes the colorscheme if it exists.
# Dies otherwise with a useful message.
function find_colorscheme() {
  COLORSCHEME_NAME="$1"

  NAMES=()
  for COLORSCHEME in "${COLORSCHEMES[@]}"; do
    NAME=$(colorscheme_name ${COLORSCHEME})
    NAMES+=("${NAME}")

    if [ "${NAME,,}" == "${NAME,,}" ]; then
      echo "${COLORSCHEME}"
      return
    fi
  done

  log "Error: no such colorscheme '${COLORSCHEME_NAME}'. Options are:"
  for NAME in "${NAMES[@]}"; do
    log " - ${NAME}"
  done
  exit 1
}

# apply_colorscheme PROFILE COLORSCHEME
# Applies the given packed colorscheme to the given gnome-terminal profile.
function apply_colorscheme() {
  PROFILE="$1"
  COLORSCHEME="$2"

  FG_COLOR=$(colorscheme_fg_color "${COLORSCHEME}")
  BG_COLOR=$(colorscheme_bg_color "${COLORSCHEME}")
  ANSI_COLORS=$(colorscheme_ansi_colors "${COLORSCHEME}")

  dconf write "${PROFILE}foreground-color" "'${FG_COLOR}'"
  dconf write "${PROFILE}background-color" "'${BG_COLOR}'"
  dconf write "${PROFILE}palette" "${ANSI_COLORS}"
}

function main() {
  if [ "$#" -le 0 ]; then
    die "USAGE: style-gnome-terminal COLORSCHEME_NAME"
  fi

  # TODO: Subcommands:
  # 
  # Profiles:
  # 
  #  - profile list
  #  - profile show NAME_OR_ID
  # 
  # Styling:
  #
  # These all take an optional [profile NAME_OR_ID] clause to specify a profile
  # by name or UUID. If unspecified, the program searches for profiles. If there
  # exists a single profile, the program uses it. Otherwise, an interactive
  # choice is presented to the user.
  #
  #  - font get
  #  - font set FONT
  #  - foreground-color get
  #  - foreground-color set COLOR
  #  - background-color get
  #  - background-color set COLOR
  #  - palette get
  #  - palette set COLORS
  #  - colorscheme show NAME
  #  - colorscheme apply NAME
  #
  # The colorscheme subcommand should probably read colorschemes from files
  # instead, for easier integration with other people's colorschemes. Otherwise
  # all colorschemes need to be defined in this script. The main question is the
  # file format. We'd like something easy enough to write, that does not execute
  # arbitrary code (rules our source-ing .sh files containing variables), that
  # does not require onerous dependencies to parse.

  COLORSCHEME_NAME="$1"
  COLORSCHEME=$(find_colorscheme "${COLORSCHEME_NAME}")
  PROFILE=$(choose_profile)
  apply_colorscheme "${PROFILE}" "${COLORSCHEME}"
}

main "$@"
