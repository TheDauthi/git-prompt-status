function git_prompt_status() {
  local INDEX STATUS
  typeset -A prefix_lookup

  local status_text=$({command git status --porcelain -b \
    | sed -Ee  '/^## [^ ]+ .*(behind|diverged|ahead)/!b
                s/.*\[(.*)\].*/\1/g
                s/[ ]//g
                y/,/\n/' \
    | cut -c-3 \
    | sort -u } 2>/dev/null)
  
  # Array expansion
  local status_prefixes=("${(@f)${status_text}}");

  # Generate a hash table of all of the index items
  for prefix in ${status_prefixes}; do
    prefix_lookup[$prefix]=0
  done
  
  local _match_status_prefix() {
    return $(( ${+prefix_lookup[$1]} == 0 ))
  }

  if _match_status_prefix '?? '; then
    STATUS="$ZSH_THEME_GIT_PROMPT_UNTRACKED$STATUS"
  fi
  if _match_status_prefix 'A  '; then 
    STATUS="$ZSH_THEME_GIT_PROMPT_ADDED$STATUS"
  elif _match_status_prefix 'M  '; then
    STATUS="$ZSH_THEME_GIT_PROMPT_ADDED$STATUS"
  fi

  if _match_status_prefix ' M '; then 
    STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  elif _match_status_prefix 'AM '; then
    STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  elif _match_status_prefix ' T '; then
    STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  fi

  if _match_status_prefix 'R  '; then 
    STATUS="$ZSH_THEME_GIT_PROMPT_RENAMED$STATUS"
  fi
  if _match_status_prefix ' D '; then 
    STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$STATUS"
  elif _match_status_prefix 'D  '; then
    STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$STATUS"
  elif _match_status_prefix 'AD '; then
    STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$STATUS"
  fi
  if $(command git rev-parse --verify refs/stash >/dev/null 2>&1); then
    STATUS="$ZSH_THEME_GIT_PROMPT_STASHED$STATUS"
  fi
  if _match_status_prefix 'UU '; then
    STATUS="$ZSH_THEME_GIT_PROMPT_UNMERGED$STATUS"
  fi;
  if _match_status_prefix 'ahe' ; then
    STATUS="$ZSH_THEME_GIT_PROMPT_AHEAD$STATUS"
  fi
  if _match_status_prefix 'beh' ; then
    STATUS="$ZSH_THEME_GIT_PROMPT_BEHIND$STATUS"
  fi
  if _match_status_prefix 'div'; then
    STATUS="$ZSH_THEME_GIT_PROMPT_DIVERGED$STATUS"
  fi
  echo $STATUS
}
