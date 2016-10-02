function git_prompt_status() {
  local status_prompt prefix_lines prefixes
  local -A prefix_lookup
  
  # Documenting the ugly sed line below for future maintainers
  # - Break if it doesn't match the behind/diverged/ahead line
  # - Remove everything not in the brackets, leaving a CSV of statuses
  # - Remove spaces
  # - Split statuses into separate lines

  local prefix_lines=$({command git status --porcelain -b \
    | sed -Ee  '/^## [^ ]+ .*(behind|diverged|ahead)/!b
                s/.*\[(.*)\].*/\1/g
                s/[ ]//g
                y/,/\n/' \
    | cut -c-3 \
    | sort -u } 2>/dev/null)

  local prefixes=("${(@f)${prefix_lines}}");

  # Generate a hash table of all of the index items
  for prefix in ${prefixes}; do
    prefix_lookup[$prefix]=0
  done
  
  local _match_status_prefix() {
    return $(( ${+prefix_lookup[$1]} == 0 ))
  }

  if _match_status_prefix '?? '; then
    status_prompt="$ZSH_THEME_GIT_PROMPT_UNTRACKED$status_prompt"
  fi

  if _match_status_prefix 'A  '; then 
    status_prompt="$ZSH_THEME_GIT_PROMPT_ADDED$status_prompt"
  elif _match_status_prefix 'M  '; then
    status_prompt="$ZSH_THEME_GIT_PROMPT_ADDED$status_prompt"
  fi

  if _match_status_prefix ' M '; then 
    status_prompt="$ZSH_THEME_GIT_PROMPT_MODIFIED$status_prompt"
  elif _match_status_prefix 'AM '; then
    status_prompt="$ZSH_THEME_GIT_PROMPT_MODIFIED$status_prompt"
  elif _match_status_prefix ' T '; then
    status_prompt="$ZSH_THEME_GIT_PROMPT_MODIFIED$status_prompt"
  fi

  if _match_status_prefix 'R  '; then 
    status_prompt="$ZSH_THEME_GIT_PROMPT_RENAMED$status_prompt"
  fi
  if _match_status_prefix ' D '; then 
    status_prompt="$ZSH_THEME_GIT_PROMPT_DELETED$status_prompt"
  elif _match_status_prefix 'D  '; then
    status_prompt="$ZSH_THEME_GIT_PROMPT_DELETED$status_prompt"
  elif _match_status_prefix 'AD '; then
    status_prompt="$ZSH_THEME_GIT_PROMPT_DELETED$status_prompt"
  fi
  if $(command git rev-parse --verify refs/stash >/dev/null 2>&1); then
    status_prompt="$ZSH_THEME_GIT_PROMPT_STASHED$status_prompt"
  fi
  if _match_status_prefix 'UU '; then
    status_prompt="$ZSH_THEME_GIT_PROMPT_UNMERGED$status_prompt"
  fi;
  if _match_status_prefix 'ahe' ; then
    status_prompt="$ZSH_THEME_GIT_PROMPT_AHEAD$status_prompt"
  fi
  if _match_status_prefix 'beh' ; then
    status_prompt="$ZSH_THEME_GIT_PROMPT_BEHIND$status_prompt"
  fi
  if _match_status_prefix 'div'; then
    status_prompt="$ZSH_THEME_GIT_PROMPT_DIVERGED$status_prompt"
  fi
  echo $status_prompt
}
