#!/bin/zsh
# And because I always forget what the debug version is:
# Tests generated with 
# find -maxdepth 1 -type d -print0 |xargs --null -i zsh -c " cd {}; git status --porcelain -b > /home/billyconn/Projects/zsh-git-cmd/tests/fixtures/{}.test"
# Just renaming these to ensure that we get consistent output

# This lets us use our git shim
autoload -U colors; colors
emulate -L zsh

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

function _create_unnamed_tempfile() {
  local __resultvar=$1
  local __internal_tempfile=$(mktemp)
  local integer __descriptor
  # Keep the descriptor, kill the file
  exec {__descriptor}<>${__internal_tempfile}
  rm ${__internal_tempfile}
  # Since we now have a named unbuffered file, let's use it.
  __internal_tempfile="/dev/fd/${__descriptor}"
  eval $__resultvar="'${__internal_tempfile}'"
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
  old_time=$1
  new_time=$2
  
  local measure percent

  if (( $new_time == $old_time )); then
    measure="unchanged, new: $new_time, old: $old_time"
  elif (( $new_time < .0001 )); then
    measure="?? faster, new: $new_time, old: $old_time"
  elif (( $new_time > $old_time )); then
    percent=(( $old_time * 100 / $new_time))
    measure=$(printf "%0.2f%% slower, new: $new_time, old: $old_time" $percent)
  elif (( $new_time < $old_time )); then
    percent=$(( $old_time * 100 / $new_time))
    measure=$(printf "%0.2f%% faster, new: $new_time, old: $old_time" $percent)
  else
    measure="__ERROR__"
  fi
  echo $measure
}
