#!/usr/bin/env sh

# Undo (this file) is a POSIX compliant shell script.

#| undo [-i|-p] command [arguments ...]
#|
#|     -i   confirm before executing
#|     -p   only print the reverse command

# Copyright (C) 2012 by Wei Dai. All rights reserved.

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


# Argument Parsing
# ================

help_msg() {
  < "$0" sed -n '/^#|/{
    s/^#| \{0,1\}//
    p
  }'
}

# Exit if no command is given to undo.
# This script *does not* and *cannot* access the command-line history.
[ $# -eq 0 ] && help_msg && exit 1

[ "$1" = -v -o "$1" = --version ] && echo "0.1.0" && exit 0
[ "$1" = -h -o "$1" = --help ] && help_msg && exit 0

[ "$1" = -i ] && interactive=1 && shift
[ "$1" = -p ] && no_eval=1 && shift

command="$1" && shift

# Helpers
# =======

# Shell quote arguments.
# Synopsis: quote argument...
quote() {
  while [ "$1" ]; do
    printf %s "$1" | sed 's/\([|&;<>()$`\\"'"'"' 	*?#~=%\[]\)/\\\1/g'
    [ "$2" ] && printf ' '
    shift
  done
  printf '\n'
}

# Print messages to STDERR and exit with given exit code.
# Synopsis: fail [exit code] messages...
fail() {
  [ "$1" -ge 0 ] 2> /dev/null && local code="$1" && shift
  printf '%s\n' "$*" >&2
  exit ${code:-1}
}

# Returns true if $1 matches some of the following arguments.
# Synopsis: cmd cmd...
cmd() {
  while [ "$1" ]; do
    [ "$1" = "$command" ] && return 0 || shift
  done
  return 1
}

# Fallback on this if no more reverse_cmd is defined.
reverse_cmd() {
  fail 1 "cannot generate reverse command for \`$command'."
}

# Run code on each arg and format them by format.
# Synopsis: format_args format [code] -- args...
format_args() {
  local format="$1" args=; shift
  [ "$1" != -- ] && local code="$1" && shift
  [ "$1" = -- ] && shift
  while [ "$1" ]; do
    case $1 in
      -*) ;;
       *) local arg="$1"; eval "$code"; args="$args $(quote "$arg")";;
    esac
    shift
  done
  printf "$format" "${args# }"
}

# Undo Recipes
# ============

# A recipe defines `reverse_cmd' for one or more commands. `reverse_cmd' takes
# target command's arguments as arguments. Target command is accessible via
# `$command' variable. `reverse_cmd' should print reverse command to STDOUT and
# return 0 if target command can be reversed. Otherwise, `reverse_cmd' should
# always return with a non-0 return code and nothing should be print to STDOUT.
# Error and help messages should be print to STDERR.

cmd cp mv && \
  reverse_cmd() {
    local count=$# src= target= file_dir= opts=
    local nl="$(printf '\nX')" && nl="${nl%X}"
    while [ "$1" ]; do
      case $1 in
        -*) [ "$1" = "-r" ] && opts="$opts $1"; count=$(($count - 1));;
         *) [ "$2" ] && src="$src$1$nl" || target="$1";;
      esac
      shift
    done
    if [ -d "$target" ]; then
      printf %s "$src" | while read -r path; do
        case $path in
          /*) ;;
           *) path="./$path";;
        esac
        path="${path%%/}"
        fname="$(quote "${path##*/}")"
        orig_dir="$(quote "${path%/*}/")"
        target="$(quote "${target%%/}")"
        if [ $count -eq 2 -a ! -e "$target/$fname" ]; then
          # [cp|mv] dir1 dir2
          if [ "$command" = cp ]; then
            printf %s "rm$opts $target"
          elif [ "$command" = mv ]; then
            printf %s "mv $target $(quote "${path#./}")"
          fi
        else
          if [ "$command" = cp ]; then
            printf %s "rm $target/$fname; "
          elif [ "$command" = mv ]; then
            printf %s "mv $target/$fname $orig_dir; "
          fi
        fi
      done
    elif [ -f "$target" ]; then
      if [ $count -eq 2 ]; then
        if [ "$command" = cp ]; then
          printf %s "rm $(quote "$target")"
        elif [ "$command" = mv ]; then
          printf %s "mv $(quote "$target") $(quote "$src")"
        fi
      else
        fail 1 'cannot generate reverse command.'
      fi
    else
      fail 1 'cannot generate reverse command.'
    fi
  }

cmd mkdir && \
  reverse_cmd() {
    format_args 'rmdir %s' -- "$@"
  }

cmd rmdir && \
  reverse_cmd() {
    printf %s "mkdir $(quote "$@")"
  }

cmd tar && \
  reverse_cmd() {
    case $1 in
      *x*) # extract
        # Turn extract option to list and remove verbose option
        local opt="$(printf %s "$1" | sed 's/x/t/;s/v//g')"; shift
        printf %s "tar $opt $* | xargs rm 2>/dev/null; "
        printf %s "tar $opt $* | tac | xargs rmdir 2>/dev/null;"
        ;;
      *) fail 1 'cannot generate reverse command.';;
    esac
  }

cmd gzip && \
  reverse_cmd() {
    format_args 'gunzip %s' 'arg="${arg}.gz"' -- "$@"
  }

cmd gunzip && \
  reverse_cmd() {
    format_args 'gzip %s' 'arg="${arg%.gz}"' -- "$@"
  }

cmd git && \
  reverse_cmd() {
    case $1 in
      add) shift; format_args 'git reset HEAD -- %s' -- "$@";;
        *) fail 1 "cannot generate reverse command for git action \`$1'.";;
    esac
  }

# Source system-leval recipes
[ -s "/etc/undo_recipes" ] && . "/etc/undo_recipes"
# Source user-level recipes
[ -s "$HOME/.undo_recipes" ] && . "$HOME/.undo_recipes"

# Action Logic
# ============

# Get reverse command or exit with return code from `reverse_cmd'.
cmd="$(reverse_cmd "$@")" || exit $?

[ -z "$cmd" ] && fail 1 'Internal error, no reverse command generated.'

if [ "$interactive" ]; then
  printf '%s\n%s' "$cmd" 'Proceed [y/N]? '
  read action && [ "$action" = y ] && eval "$cmd"
else
  printf '%s\n' "$cmd"
  [ -z "$no_eval" ] && eval "$cmd"
fi

