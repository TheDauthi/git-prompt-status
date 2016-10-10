#!/bin/zsh
# Tests generated with
# find -maxdepth 1 -type d -print0 |xargs --null -i zsh -c " cd {}; git status --porcelain -b > /home/billyconn/Projects/zsh-git-cmd/tests/fixtures/{}.test"

autoload -U colors; colors
emulate -L zsh

# _iterate_hash 'statuses_seen' 'printf "%s -> %s\n"'
function _iterate_hash() {
  local hashname=$1
  local method=$2
  for k in "${(@kP)hashname}"; do
    v="${${(@P)hashname}[$k]}"
    eval "$method $k $v"
  done
}

#### BOILERPLATE ####
function _copy_function() {
  test -n "$(declare -f $1)" || return
  eval "${_/$1/$2}"
  return 0
}

function _rename_function() {
  _copy_function $@ || return
  unset -f $1
  return 0
}

function _load_external_function() {
  external_name=${3:-$2}
  source="$(source $1; declare -f $2)"
  eval "${source/$2/$external_name}"
  return 0
}

# This functionality is a stub for later changes
function _add_shim() {
  local shim=$1
  local absolute_shim=$(abspath $shim)
  local absolute_path=$(dirname $absolute_shim)
  PATH="$absolute_path:$PATH"
}

function _create_unnamed_tempfile() {
  local __resultvar=$1
  local __internal_tempfile=$(mktemp)
  local integer __descriptor
  # Keep the descriptor, kill the file
  exec {__descriptor}<>${__internal_tempfile}
  rm ${__internal_tempfile}
  # Since we now have a named unbuffered file, let's use it.
  __internal_tempfile="/dev/fd/${__descriptor}"
  # Return it through the requested result
  eval $__resultvar="'${__internal_tempfile}'"
}

# Used for systems where writing to a removed fd is
# not something I want to try to debug tonight
function _create_named_tempfile() {
  local __resultvar=$1
  local __internal_tempfile=$(mktemp)
  # Return it through the requested result
  eval $__resultvar="'${__internal_tempfile}'"
  eval "zshexit() { rm \$$__resultvar }"
}

function test_function() {
  # First let's clean the buffer
  printf '' > $TEMPFILE

  # What will we be testing tonight, brain?
  local function_name=$1

  # Same thing we test every night, pinky, the output and timing of a function
  local function_time=$( { time ("$function_name" >$TEMPFILE ) } 2>&1)
  printf '%s\n' $function_time
  return 0
}

function compare_test_times() {
  local old_time=$1
  local new_time=$2

  local measure percent timing

  timing=$(printf 'new: %s, old: %s' $new_time $old_time)

  if (( new_time == old_time )); then
    measure=$(printf 'unchanged, %s' $timing)
  elif (( new_time < .00000001 )); then
    measure=$(printf '?? faster, %s' $timing)
  else
    (( percent = (old_time * 100 / new_time) - 100 ))
    if (( new_time > old_time )); then
      measure=$(printf '%0.2f%% slower, %s' $percent $timing)
    elif (( new_time < old_time )); then
      measure=$(printf '%0.2f%% faster, %s' $percent $timing)
    else
      measure="__ERROR__"
    fi
  fi
  echo $measure
}

# BSD replacement for readlink -f
function abspath()
{
  local target=$1
  cd $(dirname "$target")
  target=$(basename "$target")

  # Iterate down a (possible) chain of symlinks
  while [ -L "$target" ]
  do
      target=$(readlink "$target")
      cd $(dirname "$target")
      target=$(basename "$target")
  done

  # Compute the canonicalized name by finding the physical path 
  # for the directory we're in and appending the target file.
  local parent_dir=`pwd -P`
  local absolute_path="$parent_dir/$target"

  echo $absolute_path
}