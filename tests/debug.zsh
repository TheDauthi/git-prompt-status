#!/usr/bin/env zsh
# Debug script for git-status
source ./helpers.zsh
local ZSH_THEME_GIT_PROMPT_UNTRACKED='U'
local ZSH_THEME_GIT_PROMPT_ADDED='A'
local ZSH_THEME_GIT_PROMPT_MODIFIED='M'
local ZSH_THEME_GIT_PROMPT_RENAMED='R'
local ZSH_THEME_GIT_PROMPT_DELETED='D'
local ZSH_THEME_GIT_PROMPT_UNMERGED='F'
local ZSH_THEME_GIT_PROMPT_AHEAD='>'
local ZSH_THEME_GIT_PROMPT_BEHIND='<'
local ZSH_THEME_GIT_PROMPT_DIVERGED='V'

export ZSH_FIXTURE_FILENAME="fixtures/ahead-behind-with-data.test"

_load_external_function '../git-prompt-status.zsh' 'git_prompt_status' 'show_prompt_status'
_add_shim 'git'

show_prompt_status
