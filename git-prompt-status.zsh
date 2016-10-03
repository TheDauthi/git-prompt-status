function git_prompt_status() {
  local status_text status_lines tracking_line status_prompt
  local -A prefix_lookup

  status_text=$(command git status --porcelain -b 2> /dev/null)
  # 128 - this directory is not a repo, or git crashed in the crash handler
  # There is no data to be read
  [[ -z $status_text && $? -eq 128 ]] && return

  status_lines=("${(@f)${status_text}}");

  # If the tracking line exists, grab it.
  if [[ $status_lines[1] =~ "^## [^ ]+ \[(.*)\]" ]]; then
    # If there are multiple, split them on the comma
    local branch_statuses=("${(@s/,/)match}")
    for branch_status in ${branch_statuses}; do
      # There are a few other states that we're not looking for...
      [[ $branch_status =~ "(behind|diverged|ahead)" ]] || continue
      prefix_lookup[$match[1]]=0
    done
    shift status_lines
  fi

  for line in ${status_lines}; do
    prefix_lookup[${line[1,3]}]=0
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
  if _match_status_prefix 'ahead' ; then
    status_prompt="$ZSH_THEME_GIT_PROMPT_AHEAD$status_prompt"
  fi
  if _match_status_prefix 'behind' ; then
    status_prompt="$ZSH_THEME_GIT_PROMPT_BEHIND$status_prompt"
  fi
  if _match_status_prefix 'diverged'; then
    status_prompt="$ZSH_THEME_GIT_PROMPT_DIVERGED$status_prompt"
  fi
  echo $status_prompt
}
