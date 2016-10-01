
function git_prompt_status() {
  ZSH_THEME_GIT_PROMPT_UNTRACKED='U'
  ZSH_THEME_GIT_PROMPT_ADDED='A'
  ZSH_THEME_GIT_PROMPT_MODIFIED='M'
  ZSH_THEME_GIT_PROMPT_RENAMED='R'
  ZSH_THEME_GIT_PROMPT_DELETED='D'
  ZSH_THEME_GIT_PROMPT_UNMERGED='F'
  ZSH_THEME_GIT_PROMPT_AHEAD='Z'
  ZSH_THEME_GIT_PROMPT_DIVERGED='S'

  local STATUS=''
  local INDEX=$(command git status --porcelain -b 2>/dev/null \
    | sed -Ee  '/^## [^ ]+ .*(behind|diverged|ahead)/!b; s/^## [^ ]+ .*(behind|diverged|ahead)/\1/' 2>/dev/null \
    | cut -c-3 \
    | sort -u 2>/dev/null)

  local INDICES=("${(@f)${INDEX}}");
  
  local __match_status_prefix() {
    local MATCH=$1
    local MATCH_LENGTH=${#MATCH}
    for index in ${INDICES}; do
      if [[ $index[1,$MATCH_LENGTH] == $MATCH ]]; then
        return 0
      fi
    done;
    return 1
  }
  if __match_status_prefix '??'; then
    STATUS="$ZSH_THEME_GIT_PROMPT_UNTRACKED$STATUS"
  fi
  if __match_status_prefix 'A  '; then 
    STATUS="$ZSH_THEME_GIT_PROMPT_UNTRACKED$STATUS"
  elif __match_status_prefix 'M  '; then
    STATUS="$ZSH_THEME_GIT_PROMPT_ADDED$STATUS"
  fi

  if __match_status_prefix ' M '; then 
    STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  elif __match_status_prefix 'AM '; then
    STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  elif __match_status_prefix ' T '; then
    STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  fi

  if __match_status_prefix 'R  '; then 
    STATUS="$ZSH_THEME_GIT_PROMPT_RENAMED$STATUS"
  fi
  if __match_status_prefix ' D '; then 
    STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$STATUS"
  elif __match_status_prefix 'D  '; then
    STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$STATUS"
  elif __match_status_prefix 'AD '; then
    STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$STATUS"
  fi

  if $(command git rev-parse --verify refs/stash >/dev/null 2>&1); then
    STATUS="$ZSH_THEME_GIT_PROMPT_STASHED$STATUS"
  fi
  
  if __match_status_prefix 'UU '; then
    STATUS="$ZSH_THEME_GIT_PROMPT_UNMERGED$STATUS"
  fi;
  if __match_status_prefix 'ahe' ; then
    STATUS="$ZSH_THEME_GIT_PROMPT_AHEAD$STATUS"
  fi
  if __match_status_prefix 'beh' ; then
    STATUS="$ZSH_THEME_GIT_PROMPT_AHEAD$STATUS"
  fi
  if __match_status_prefix 'div'; then
    STATUS="$ZSH_THEME_GIT_PROMPT_DIVERGED$STATUS"
  fi
  echo "$STATUS"
}