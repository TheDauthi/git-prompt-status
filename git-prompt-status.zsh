function git_prompt_status() {
  local status_text status_lines tracking_line status_prompt

  # A lookup table of each git status encountered
  local -A statuses_seen

  # Maps a git status prefix to an internal constant
  # This cannot use the prompt constants, as they may be empty
  local -A prefix_constant_map=(
    '?? '       'UNTRACKED'
    'A  '       'ADDED'
    'M  '       'ADDED'
    ' M '       'MODIFIED'
    'AM '       'MODIFIED'
    ' T '       'MODIFIED'
    'R  '       'RENAMED'
    ' D '       'DELETED'
    'D  '       'DELETED'
    'UU '       'UNMERGED'
    'ahead'     'AHEAD'
    'behind'    'BEHIND'
    'diverged'  'DIVERGED'
    'stashed'   'STASHED'
  )

  # Maps the internal constant to the prompt theme
  local -A constant_prompt_map=(
    'UNTRACKED' "$ZSH_THEME_GIT_PROMPT_UNTRACKED"
    'ADDED'     "$ZSH_THEME_GIT_PROMPT_ADDED"
    'MODIFIED'  "$ZSH_THEME_GIT_PROMPT_MODIFIED"
    'RENAMED'   "$ZSH_THEME_GIT_PROMPT_RENAMED"
    'DELETED'   "$ZSH_THEME_GIT_PROMPT_DELETED"
    'UNMERGED'  "$ZSH_THEME_GIT_PROMPT_UNMERGED"
    'AHEAD'     "$ZSH_THEME_GIT_PROMPT_AHEAD"
    'BEHIND'    "$ZSH_THEME_GIT_PROMPT_BEHIND"
    'DIVERGED'  "$ZSH_THEME_GIT_PROMPT_DIVERGED"
    'STASHED'   "$ZSH_THEME_GIT_PROMPT_STASHED"
  )

  # The order that the prompt displays should be added to the prompt
  local status_constants=(UNTRACKED ADDED MODIFIED RENAMED DELETED STASHED
                          UNMERGED AHEAD BEHIND DIVERGED)

  status_text=$(command git status --porcelain -b 2> /dev/null)

  # Don't continue on a catastrophic failure
  if [[ $? -eq 128 ]]; then
    return 1
  fi

  if $(command git rev-parse --verify refs/stash >/dev/null 2>&1); then
    statuses_seen['STASHED']=1
  fi

  status_lines=("${(@f)${status_text}}");

  # If the tracking line exists, get and parse it
  if [[ $status_lines[1] =~ "^## [^ ]+ \[(.*)\]" ]]; then
    local branch_statuses=("${(@s/,/)match}")
    for branch_status in $branch_statuses; do
      if [[ ! $branch_status =~ "(behind|diverged|ahead) ([0-9]+)?" ]]; then
        continue
      fi
      local last_parsed_status=$prefix_constant_map[$match[1]]
      statuses_seen[$last_parsed_status]=$match[2]
    done
    shift status_lines
  fi

  # This not only gives us a status lookup, but the count of each type
  for status_line in ${status_lines}; do
    local status_prefix=${status_line[1, 3]}
    local status_constant=${(v)prefix_constant_map[$status_prefix]}

    if [[ -z $status_constant ]]; then
      continue
    fi
    
    (( statuses_seen[$status_constant]++ ))
  done

  # At this point, the statuses_seen hash contains:
  # - Tracking      => The difference between tracked and current
  # - Modifications => The count of that type of modification
  # - Stash         => Whether or not a stash exists
  # Might be useful for someone?

  for status_constant in $status_constants; do
    if [[ ${+statuses_seen[$status_constant]} -eq 1 ]]; then
      local next_display=$constant_prompt_map[$status_constant]
      status_prompt="$next_display$status_prompt"
    fi
  done

  echo $status_prompt
}
