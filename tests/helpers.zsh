#!/bin/zsh
# And because I always forget what the debug version is:
# Tests generated with 
# find -maxdepth 1 -type d -print0 |xargs --null -i zsh -c " cd {}; git status --porcelain -b > /home/billyconn/Projects/zsh-git-cmd/tests/fixtures/{}.test"
# Just renaming these to ensure that we get consistent output

autoload -U colors
colors

ZSH_TEST_GIT_PROMPT_UNTRACKED='U'
ZSH_TEST_GIT_PROMPT_ADDED='A'
ZSH_TEST_GIT_PROMPT_MODIFIED='M'
ZSH_TEST_GIT_PROMPT_RENAMED='R'
ZSH_TEST_GIT_PROMPT_DELETED='D'
ZSH_TEST_GIT_PROMPT_UNMERGED='F'
ZSH_TEST_GIT_PROMPT_AHEAD='+'
ZSH_TEST_GIT_PROMPT_BEHIND='-'
ZSH_TEST_GIT_PROMPT_DIVERGED='V'

function git_prompt_status_new() {
  local TESTFILE=$1
  local STATUS index_lookup
  local status_text=$({cat $TESTFILE \
    | sed -Ee  '/^## [^ ]+ .*(behind|diverged|ahead)/!b;
                s/.*\[(.*)\].*/\1/g; 
                s/[ ]//g;
                y/,/\n/' \
    | cut -c-3 \
    | sort -u } 2>/dev/null)

  local INDICES=("${(@f)${status_text}}");

  typeset -A index_lookup

  # Generate a hash table of all of the index items
  for index in ${INDICES}; do
    index_lookup[$index]=0
  done
  
  local _match_status_prefix() {
    return $(( ${+index_lookup[$1]} == 0 ))
  }

  if _match_status_prefix '?? '; then
    STATUS="$ZSH_TEST_GIT_PROMPT_UNTRACKED$STATUS"
  fi
  if _match_status_prefix 'A  '; then 
    STATUS="$ZSH_TEST_GIT_PROMPT_ADDED$STATUS"
  elif _match_status_prefix 'M  '; then
    STATUS="$ZSH_TEST_GIT_PROMPT_ADDED$STATUS"
  fi

  if _match_status_prefix ' M '; then 
    STATUS="$ZSH_TEST_GIT_PROMPT_MODIFIED$STATUS"
  elif _match_status_prefix 'AM '; then
    STATUS="$ZSH_TEST_GIT_PROMPT_MODIFIED$STATUS"
  elif _match_status_prefix ' T '; then
    STATUS="$ZSH_TEST_GIT_PROMPT_MODIFIED$STATUS"
  fi

  if _match_status_prefix 'R  '; then 
    STATUS="$ZSH_TEST_GIT_PROMPT_RENAMED$STATUS"
  fi
  if _match_status_prefix ' D '; then 
    STATUS="$ZSH_TEST_GIT_PROMPT_DELETED$STATUS"
  elif _match_status_prefix 'D  '; then
    STATUS="$ZSH_TEST_GIT_PROMPT_DELETED$STATUS"
  elif _match_status_prefix 'AD '; then
    STATUS="$ZSH_TEST_GIT_PROMPT_DELETED$STATUS"
  fi
# Commented out for testing: we're not using REAL git
# I could override "command git", but suspect it's not worth the extra effort.

# if $(command git rev-parse --verify refs/stash >/dev/null 2>&1); then
#   STATUS="$ZSH_TEST_GIT_PROMPT_STASHED$STATUS"
# fi
  if _match_status_prefix 'UU '; then
    STATUS="$ZSH_TEST_GIT_PROMPT_UNMERGED$STATUS"
  fi;
  if _match_status_prefix 'ahe' ; then
    STATUS="$ZSH_TEST_GIT_PROMPT_AHEAD$STATUS"
  fi
  if _match_status_prefix 'beh' ; then
    STATUS="$ZSH_TEST_GIT_PROMPT_BEHIND$STATUS"
  fi
  if _match_status_prefix 'div'; then
    STATUS="$ZSH_TEST_GIT_PROMPT_DIVERGED$STATUS"
  fi
  echo $STATUS
}

# Get the status of the working tree
function git_prompt_status_old() {
  local TESTFILE=$1
  local INDEX STATUS
  INDEX=$(cat $TESTFILE 2> /dev/null)
  STATUS=""
  if $(echo "$INDEX" | command grep -E '^\?\? ' &> /dev/null); then
    STATUS="$ZSH_TEST_GIT_PROMPT_UNTRACKED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^A  ' &> /dev/null); then
    STATUS="$ZSH_TEST_GIT_PROMPT_ADDED$STATUS"
  elif $(echo "$INDEX" | grep '^M  ' &> /dev/null); then
    STATUS="$ZSH_TEST_GIT_PROMPT_ADDED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^ M ' &> /dev/null); then
    STATUS="$ZSH_TEST_GIT_PROMPT_MODIFIED$STATUS"
  elif $(echo "$INDEX" | grep '^AM ' &> /dev/null); then
    STATUS="$ZSH_TEST_GIT_PROMPT_MODIFIED$STATUS"
  elif $(echo "$INDEX" | grep '^ T ' &> /dev/null); then
    STATUS="$ZSH_TEST_GIT_PROMPT_MODIFIED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^R  ' &> /dev/null); then
    STATUS="$ZSH_TEST_GIT_PROMPT_RENAMED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^ D ' &> /dev/null); then
    STATUS="$ZSH_TEST_GIT_PROMPT_DELETED$STATUS"
  elif $(echo "$INDEX" | grep '^D  ' &> /dev/null); then
    STATUS="$ZSH_TEST_GIT_PROMPT_DELETED$STATUS"
  elif $(echo "$INDEX" | grep '^AD ' &> /dev/null); then
    STATUS="$ZSH_TEST_GIT_PROMPT_DELETED$STATUS"
  fi
# Commented out for testing: we're not using REAL git
# I could override "command git", but suspect it's not worth the extra effort.

# if $(command git rev-parse --verify refs/stash >/dev/null 2>&1); then
#   STATUS="$ZSH_TEST_GIT_PROMPT_STASHED$STATUS"
# fi
  if $(echo "$INDEX" | grep '^UU ' &> /dev/null); then
    STATUS="$ZSH_TEST_GIT_PROMPT_UNMERGED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^## [^ ]\+ .*ahead' &> /dev/null); then
    STATUS="$ZSH_TEST_GIT_PROMPT_AHEAD$STATUS"
  fi
  if $(echo "$INDEX" | grep '^## [^ ]\+ .*behind' &> /dev/null); then
    STATUS="$ZSH_TEST_GIT_PROMPT_BEHIND$STATUS"
  fi
  if $(echo "$INDEX" | grep '^## [^ ]\+ .*diverged' &> /dev/null); then
    STATUS="$ZSH_TEST_GIT_PROMPT_DIVERGED$STATUS"
  fi
  echo $STATUS
}

function test_status() {
  # setopt localoptions xtrace
  local test_file=$1
  # Split this up for debugging purposes
  local TIMEFMT=$'%*E'
  local new_prompt=$(git_prompt_status_new $test_file)
  local old_prompt=$(git_prompt_status_old $test_file)
  # Does anyone know a better way of doing this?
  
  local new_prompt_time=$( ( time ( git_prompt_status_new $test_file > /dev/null ) > /dev/null) 2>&1)
  local old_prompt_time=$( ( time ( git_prompt_status_old $test_file > /dev/null ) > /dev/null) 2>&1)
  local measure percent

  if (( $new_prompt_time == $old_prompt_time )); then
    measure="no difference"
  elif (( $new_prompt_time < .0001 )); then
    measure="?? faster, new: $new_prompt_time, old: $old_prompt_time"
  elif (( $new_prompt_time > $old_prompt_time )); then
    percent=(( $old_prompt_time * 100 / $new_prompt_time))
    measure=$(printf "%0.3f %% slower, new: $new_prompt_time, old: $old_prompt_time" $percent)
  elif (( $new_prompt_time < $old_prompt_time )); then
    percent=$(( $old_prompt_time * 100 / $new_prompt_time))
    measure=$(printf "%0.3f %% faster, new: $new_prompt_time, old: $old_prompt_time" $percent)
  else
    measure="I forgot a case"
  fi


  if [[ $new_prompt == $old_prompt ]]; then
    printf "test passed: %-80s%s\n" $test_file $measure
  else
    printf "test $fg[red]failed$fg[default]: %-80s%s\n" $test_file $measure
    printf "    old: $old_prompt\n"
    printf "    new: $new_prompt\n"
  fi
}

