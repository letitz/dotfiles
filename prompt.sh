# Additional bash prompt configuration for interactive shells only.

function prompt () {
  # Check for color support.
  local boldblue=
  local boldgreen=
  local purple=
  local nocolor=
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    boldblue="\[\e[1;34m\]"
    boldgreen="\[\e[1;32m\]"
    purple="\[\e[0;35m\]"
    nocolor="\[\e[00m\]"
  fi

  local ps1="${boldgreen}\u@\h${nocolor}:${boldblue}\w ${purple}\D{%T}${nocolor} \$ "

  # If this is an xterm set the title to user@host:dir
  case "$TERM" in
    xterm*|rxvt*)
      ps1="\[\e]0;\u@\h: \w\a\]${ps1}"
      ;;
  esac

  echo "$ps1"
}

PS1=$(prompt)

unset -f prompt
