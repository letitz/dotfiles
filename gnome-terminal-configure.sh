#!/bin/bash
# vim: tw=80 ts=2 sw=2:

set -eu

# CONSTANTS
# =========

PROGRAM_NAME="$0"

# DConf directory in which gnome-terminal profile configuration is stored.
ROOT_DCONF_DIR='/org/gnome/terminal/legacy/profiles:/'

# The names of ANSI color properties in config files.
# Order matters. These correspond to the ANSI color codes.
ANSI_COLOR_PROPERTIES=(
  "ansi-colors-black"
  "ansi-colors-red"
  "ansi-colors-green"
  "ansi-colors-yellow"
  "ansi-colors-blue"
  "ansi-colors-purple"
  "ansi-colors-cyan"
  "ansi-colors-white"
  "ansi-colors-bright-black"
  "ansi-colors-bright-red"
  "ansi-colors-bright-green"
  "ansi-colors-bright-yellow"
  "ansi-colors-bright-blue"
  "ansi-colors-bright-purple"
  "ansi-colors-bright-cyan"
  "ansi-colors-bright-white"
)

# LOGGING
# =======

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


# CONFIG
# ======
#
# Configuration files have a very basic grammar:
#
#   PROPERTY_NAME = VALUE
#
# The functions below allow reading config file contents.

# config_get_property FILE PROPERTY
# Echoes the given property from the given config file.
function config_get_property() {
  FILE="$1"
  PROPERTY="$2"

  sed -n "s:^${PROPERTY} *= *\(\.*\):\1:p" < "${FILE}"
}

# config_get_property_or_die FILE PROPERTY
# config_get_property, except dies if the property is not found.
function config_get_property_or_die() {
  FILE="$1"
  PROPERTY="$2"

  RESULT=$(config_get_property "${FILE}" "${PROPERTY}")
  if [ -z "$RESULT" ]; then
    die "Error: cannot find property '${PROPERTY}' in file '${FILE}'."
  fi

  echo "${RESULT}"
}

# config_get_font FILE
function config_get_font() {
  FILE="$1"
  config_get_property "${FILE}" "font"
}

# config_get_foreground_color FILE
function config_get_foreground_color() {
  FILE="$1"
  config_get_property "${FILE}" "foreground-color"
}

# config_get_background_color FILE
function config_get_background_color() {
  FILE="$1"
  config_get_property "${FILE}" "background-color"
}

# join_ansi_colors COLOR1 ... COLOR16
# Echoes "[${COLOR1}, ..., ${COLOR16}]".
function join_ansi_colors () {
  echo -n "[$1"
  for i in {2..16}; do
    echo -n ", ${!i}"  # Get the i-th argument to this function.
  done
  echo "]"
}

# config_get_ansi_colors FILE
function config_get_ansi_colors() {
  FILE="$1"

  ANSI_COLORS=()
  for PROPERTY in "${ANSI_COLOR_PROPERTIES[@]}"; do
    # TODO: This does not actually die, because exit is called in a subshell.
    COLOR=$(config_get_property_or_die "${FILE}" "${PROPERTY}")
    ANSI_COLORS+=("${COLOR}")
  done

  join_ansi_colors "${ANSI_COLORS[@]}"
}


# PROFILE
# =======
#
# Gnome-terminal profile preferences are read and written through dconf.
#
# In the following functions, profiles are referenced by their dconf directory
# paths (ending in a '/' character).

# profile_list
function profile_list() {
  dconf list "${ROOT_DCONF_DIR}" | sed 's_:\(.*\)/_\1_'
}

# profile_get_property PROFILE PROPERTY
# Echoes the given property from the given gnome-terminal profile.
function profile_get_property() {
  PROFILE="$1"
  PROPERTY="$2"

  dconf read "${PROFILE}${PROPERTY}"
}

# profile_set_property PROFILE PROPERTY VALUE
# Sets the given profile's given property to the given value.
function profile_set_property() {
  PROFILE="$1"
  PROPERTY="$2"
  VALUE="$3"

  dconf write "${PROFILE}${PROPERTY}" "${VALUE}"
}

# profile_get_name PROFILE
# Echoes the human-readable name for the given gnome-terminal profile.
function profile_get_name() {
  PROFILE="$1"
  profile_get_property "${PROFILE}" "visible-name"
}

# profile_set_name PROFILE VALUE
# Sets the human-readable name for the given gnome-terminal profile.
function profile_set_name() {
  PROFILE="$1"
  VALUE="$2"
  profile_set_property "${PROFILE}" "visible-name" "${VALUE}"
}

# profile_get_font PROFILE
# Echoes the font for the given gnome-terminal profile.
function profile_get_font() {
  PROFILE="$1"
  profile_get_property "${PROFILE}" "font"
}

# profile_set_font PROFILE VALUE
# Sets the font for the given gnome-terminal profile.
function profile_set_font() {
  PROFILE="$1"
  VALUE="$2"
  profile_set_property "${PROFILE}" "font" "${VALUE}"
}

# profile_get_foreground_color PROFILE
# Echoes the foreground color for the given gnome-terminal profile.
function profile_get_foreground_color() {
  PROFILE="$1"
  profile_get_property "${PROFILE}" "foreground-color"
}

# profile_set_foreground_color PROFILE VALUE
# Sets the foreground color for the given gnome-terminal profile.
function profile_set_foreground_color() {
  PROFILE="$1"
  VALUE="$2"
  profile_set_property "${PROFILE}" "foreground-color" "${VALUE}"
}

# profile_get_background_color PROFILE
# Echoes the background color for the given gnome-terminal profile.
function profile_get_background_color() {
  PROFILE="$1"
  profile_get_property "${PROFILE}" "background-color"
}

# profile_set_background_color PROFILE VALUE
# Sets the background color for the given gnome-terminal profile.
function profile_set_background_color() {
  PROFILE="$1"
  VALUE="$2"
  profile_set_property "${PROFILE}" "background-color" "${VALUE}"
}

# profile_get_ansi_colors PROFILE
# Echoes the ANSI color palette for the given gnome-terminal profile.
function profile_get_ansi_colors() {
  PROFILE="$1"
  profile_get_property "${PROFILE}" "palette"
}

# profile_set_ansi_colors PROFILE VALUE
# Sets the ANSI color palette for the given gnome-terminal profile.
function profile_set_ansi_colors() {
  PROFILE="$1"
  VALUE="$2"
  profile_set_property "${PROFILE}" "palette" "${VALUE}"
}

# profile_dump_config PROFILE
function profile_dump_config() {
  PROFILE="$1"

  FONT=$(profile_get_font "${PROFILE}")
  FOREGROUND_COLOR=$(profile_get_foreground_color "${PROFILE}")
  BACKGROUND_COLOR=$(profile_get_background_color "${PROFILE}")

  # TODO: ANSI colors

  echo "font = ${FONT}"
  echo "foreground-color = ${FOREGROUND_COLOR}"
  echo "background-color = ${BACKGROUND_COLOR}"
}

# profile_apply_config PROFILE CONFIG_FILE
# Applies the given configuration to the given gnome-terminal profile.
function profile_apply_config() {
  PROFILE="$1"
  CONFIG_FILE="$2"

  FONT=$(config_get_font "${CONFIG_FILE}")
  FOREGROUND_COLOR=$(config_get_foreground_color "${CONFIG_FILE}")
  BACKGROUND_COLOR=$(config_get_background_color "${CONFIG_FILE}")
  ANSI_COLORS=$(config_get_ansi_colors "${CONFIG_FILE}")

  profile_set_font "${PROFILE}" "${FONT}"
  profile_set_foreground_color "${PROFILE}" "${FOREGROUND_COLOR}"
  profile_set_background_color "${PROFILE}" "${BACKGROUND_COLOR}"
  profile_set_ansi_colors "${PROFILE}" "${ANSI_COLORS}"
}

# INTERACTIVE USE
# ===============

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
    PROFILE_NAME=$(profile_get_name "${PROFILE}")
    log "Found single gnome-terminal profile named '${PROFILE_NAME}', using it."
    echo "${PROFILE}"
    return
  fi

  log "Available gnome-terminal profiles:"

  for i in $(seq 1 "${NUM_PROFILES}"); do
    PROFILE="${PROFILES[$(($i - 1))]}"
    PROFILE_NAME=$(profile_get_name "${PROFILE}")
    log "  #$i: ${PROFILE_NAME}"
  done

  choose_number "Choose a profile" 1 "${NUM_PROFILES}"
}

# usage ERROR
function usage() {
  ERROR="$1"

  log "Error: ${ERROR}"
  log
  log "USAGE: ${PROGRAM_NAME} SUBCOMMAND"
  log
  log "Where SUBCOMMAND can be one of:"
  log
  log "  list"
  log "    Lists the available gnome-terminal profiles."
  log
  log "  get [profile PROFILE_ID] PROPERTY"
  log "    Displays the given gnome-terminal profile property."
  log
  log "  set [profile PROFILE_ID] PROPERTY VALUE"
  log "    Sets the given gnome-terminal profile property to the given value."
  log
  log "  dump [profile PROFILE_ID]"
  log "    Dumps the given gnome-terminal as a configuration file to stdout."
  log
  log "  apply [profile PROFILE_ID] FILE"
  log "    Applies the gnome-terminal configuration file."
  die
}

# expect_arguments COMMAND EXPECTED ACTUAL
function expect_arguments() {
  COMMAND="$1"
  EXPECTED="$2"
  ACTUAL="$3"

  if [ "${ACTUAL}" -ne "${EXPECTED}" ]; then
    die "Error: ${COMMAND} expects ${EXPECTED} arguments, got ${ACTUAL}."
  fi
}

# subcommand_list
function subcommand_list() {
  expect_arguments "list" 0 $#

  profile_list
}

# subcommand_get PROFILE PROPERTY
function subcommand_get() {
  expect_arguments "get" 1 $(($# - 1))

  PROFILE="$1"
  PROPERTY="$2"

  profile_get_property "${PROFILE}" "${PROPERTY}"
}

# subcommand_set PROFILE PROPERTY VALUE
function subcommand_set() {
  expect_arguments "set" 2 $(($# - 1))

  PROFILE="$1"
  PROPERTY="$2"
  VALUE="$3"

  # TODO: quote the value properly
  profile_set_property "${PROFILE}" "${PROPERTY}" "${VALUE}"
}

# subcommand_dump PROFILE
function subcommand_dump() {
  expect_arguments "dump" 0 $(($# - 1))

  PROFILE="$1"

  profile_dump_config "${PROFILE}"
}

# subcommand_apply PROFILE
function subcommand_apply() {
  expect_arguments "apply" 0 $(($# - 1))

  PROFILE="$1"

  # Copy stdin to a temporary file.
  CONFIG_FILE=$(mktemp)
  tee > "${CONFIG_FILE}"

  # Apply the configuration file.
  profile_apply_config "${PROFILE}" "${CONFIG_FILE}"
}

function main() {
  if [ "$#" -le 0 ]; then
    usage "Subcommand required."
  fi

  # TODO: Subcommands:
  #
  # gnome-terminal-configure list
  #
  # gnome-terminal-configure get [profile NAME_OR_ID] font
  # gnome-terminal-configure get [profile NAME_OR_ID] foreground-color
  # gnome-terminal-configure get [profile NAME_OR_ID] background-color
  # gnome-terminal-configure get [profile NAME_OR_ID] ansi-colors
  #
  # gnome-terminal-configure set [profile NAME_OR_ID] font FONT
  # gnome-terminal-configure set [profile NAME_OR_ID] foreground-color COLOR
  # gnome-terminal-configure set [profile NAME_OR_ID] background-color COLOR
  # gnome-terminal-configure set [profile NAME_OR_ID] ansi-colors ANSI_COLORS
  #
  # gnome-terminal-configure dump [profile NAME_OR_ID]
  # gnome-terminal-configure apply [profile NAME_OR_ID]

  SUBCOMMAND="$1"
  shift

  # Validate subcommand
  NEED_PROFILE=1
  case "${SUBCOMMAND}" in
    "list")
      NEED_PROFILE=0
      ;;
    "get")
      ;;
    "set")
      ;;
    "dump")
      ;;
    "apply")
      ;;
    *)
      usage "Unrecognized command '${SUBCOMMAND}'."
      ;;
  esac

  # Commands that do not need a profile can just execute now.
  if [ "${NEED_PROFILE}" -eq 0 ]; then
    "subcommand_${SUBCOMMAND}" "$@"
    return
  fi

  # Parse the optional `profile PROFILE_ID` clause if present.
  if [ "$#" -ge 1 ] && [ "$1" == "profile" ]; then
    if [ "$#" -eq 1 ]; then
      usage "expected profile ID after 'profile' keyword."
    fi

    PROFILE="$2"
    shift 2
  else
    PROFILE=$(choose_profile)
  fi

  # Execute the subcommand.
  "subcommand_${SUBCOMMAND}" "${PROFILE}" "$@"
}

main "$@"
