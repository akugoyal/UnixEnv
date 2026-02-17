# --- Prompt formatting (Bash) -----------------------------------------------

# Try to load git's prompt helper if available (Homebrew / system paths)
for f in \
  /opt/homebrew/etc/bash_completion.d/git-prompt.sh \
  /usr/local/etc/bash_completion.d/git-prompt.sh \
  /usr/share/git/completion/git-prompt.sh \
  /etc/bash_completion.d/git-prompt; do
  [ -f "$f" ] && . "$f" && break
done

# Colors
BOLD='\[\e[1m\]'
RESET='\[\e[0m\]'
GREEN='\[\e[32m\]'
CYAN81='\[\e[38;5;81m\]'
BRIGHT_MAGENTA='\[\e[95m\]'         # more solid than 35m
LAVENDER141='\[\e[38;5;141m\]'      # muted purple (256-color)
FADED_MAGENTA='\[\e[35m\]'          # standard magenta, less bright than 95m

# If __git_ps1 is available, use it; else fallback
if type __git_ps1 >/dev/null 2>&1; then
  export GIT_PS1_SHOWDIRTYSTATE=1
  GIT_SEGMENT="\$(__git_ps1 \" ${BRIGHT_MAGENTA}(%s)${RESET}\")"
else
  git_branch_fallback() {
    local b
    b=$(git symbolic-ref --short -q HEAD 2>/dev/null) || return 0
    printf " %s(%s)%s" "${BRIGHT_MAGENTA}" "$b" "${RESET}"
  }
  GIT_SEGMENT='$(git_branch_fallback)'
fi

# Final prompt
PS1="${BOLD}${GREEN}\u${RESET} ${CYAN81}\w${RESET}${GIT_SEGMENT}\$ "
