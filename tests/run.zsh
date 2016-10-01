#!/bin/zsh
# Test stub for git-status
source ./helpers.zsh

current_path="$HOME/.oh-my-zsh/lib/git.zsh"
updated_path="$(readlink -f ../git-prompt-status.zsh)"
test_function="git_prompt_status"

# I can't use command substitution for once.
# So here's a result variable.
_create_unnamed_tempfile 'TEMPFILE'

# I should trap and clean this...
# exec {tempdesc}>&-

function run_tests() {
  initialize_tests
  for file in fixtures/*; do
    test_status $file
  done
}

function initialize_tests() {
  _load_external_function $current_path $test_function "git_prompt_status_grep"
  _load_external_function $updated_path $test_function "git_prompt_status_hash"
}

################# WARNING #################
# This function has a side effect
# It empties $TEMPFILE and refills it with 
# the function output.
###########################################


function test_status() {
  local test_file=$1
  # We pass this to our git stub so it knows what fake fixture to use
  export ZSH_FIXTURE_FILENAME=$test_file

  # Easier to parse time format
  local TIMEFMT=$'%*E'

  # This lets us use our git shim
  PATH=".:$PATH"

  local ZSH_THEME_GIT_PROMPT_UNTRACKED='U'
  local ZSH_THEME_GIT_PROMPT_ADDED='A'
  local ZSH_THEME_GIT_PROMPT_MODIFIED='M'
  local ZSH_THEME_GIT_PROMPT_RENAMED='R'
  local ZSH_THEME_GIT_PROMPT_DELETED='D'
  local ZSH_THEME_GIT_PROMPT_UNMERGED='F'
  local ZSH_THEME_GIT_PROMPT_AHEAD='>'
  local ZSH_THEME_GIT_PROMPT_BEHIND='<'
  local ZSH_THEME_GIT_PROMPT_DIVERGED='V'

  local hash_prompt_time=$(test_function 'git_prompt_status_hash')
  local hash_prompt_data=$(cat $TEMPFILE)

  local grep_prompt_time=$(test_function 'git_prompt_status_grep')
  local grep_prompt_data=$(cat $TEMPFILE)

  

  local measure=$(compare_test_times $grep_prompt_time $hash_prompt_time)
  if [ "$hash_prompt_data" = "$grep_prompt_data" ]; then
    printf "test passed: %-60s%s\n" $test_file $measure
    printf "    old: $grep_prompt_data\n"
    printf "    new: $hash_prompt_data\n"
  else
    printf "test $fg[red]failed$fg[default]: %-60s%s\n" $test_file $measure
    printf "    old: '$grep_prompt_data'\n"
    printf "    new: '$hash_prompt_data'\n"
  fi

  unset ZSH_FIXTURE_FILENAME
}

run_tests;