# --- Prompt formatting (Bash) -----------------------------------------------

# Try to load git's prompt helper if available (Homebrew / system paths)
for f in \
  /opt/homebrew/etc/bash_completion.d/git-prompt.sh \
  /usr/local/etc/bash_completion.d/git-prompt.sh \
  /usr/share/git/completion/git-prompt.sh \
  /etc/bash_completion.d/git-prompt; do
  [ -f "$f" ] && . "$f" && break
done

# Colors (with proper \[ \] for non-printing sequences)
BOLD='\[\e[1m\]'
RESET='\[\e[0m\]'
GREEN='\[\e[32m\]'
GREY55='\[\e[38;5;55m\]'
MAGENTA5='\[\e[38;5;5m\]'

# If __git_ps1 is available, use it; else provide a tiny fallback
if type __git_ps1 >/dev/null 2>&1; then
  # (Optional) show dirty state like zsh's vcs_info could
  export GIT_PS1_SHOWDIRTYSTATE=1
  GIT_SEGMENT='\$(__git_ps1 " '"$MAGENTA5"'(%s)'"$RESET"'")'
else
  git_branch_fallback() {
    local b
    b=$(git symbolic-ref --short -q HEAD 2>/dev/null) || return 0
    printf " %b(%s)%b" "$MAGENTA5" "$b" "$RESET"
  }
  GIT_SEGMENT='$(git_branch_fallback)'
fi

# \u = username, \w = cwd with ~, final $ matches your zsh PROMPT ending
PS1='\[\e[1m\]\[\e[32m\]\u\[\e[0m\] \[\e[38;5;81m\]\w\[\e[0m\]$(__git_ps1 " \[\e[38;5;199m\](%s)\[\e[0m\]")\$ '

# ---------------------------------------------------------------------------
