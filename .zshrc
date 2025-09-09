# --- Auto-backup zshrc on reload -------------------------------------
backup_dir="$HOME/Desktop/Backups"
max_backups=10   # <-- change this number to keep more or fewer backups
mkdir -p "$backup_dir"

# Create a timestamped backup
cp "$HOME/.zshrc" "$backup_dir/.zshrc_backup_$(date +%Y-%m-%d_%H-%M-%S)"

# Keep only the $max_backups newest backups, delete older ones
ls -t "$backup_dir"/.zshrc_backup_* 2>/dev/null | tail -n +$((max_backups+1)) | xargs -r rm --
# ---------------------------------------------------------------------

# --- Set up prompt formatting ----------------------------------------
setopt prompt_subst
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats '%F{5}(%b)%f'
precmd() { vcs_info }
PROMPT='%B%F{2}%n%f %F{55}%~%f ${vcs_info_msg_0_}$%b '
# ---------------------------------------------------------------------

# --- Configure git completions ---------------------------------------
autoload -Uz compinit
compinit

# Git completions: only complete branches/tags, not filenames
zstyle ':completion:*:*:git-checkout:*' tag-order 'heads' 'tags'
# ---------------------------------------------------------------------

# --- PATH ------------------------------------------------------------
export PATH="/usr/local/bin:$PATH"
# ---------------------------------------------------------------------

# --- Aliases ---------------------------------------------------------
alias cs159="cd ~/Desktop/Purdue/Freshman_Year_2025_2026/CS15900/"
alias purduerm="cd ~/Desktop/Purdue/RoboMasters/"
alias python="python3"
alias pip="pip3"
alias reload-zsh="source ~/.zshrc && echo 'zshrc reloaded'"
# ---------------------------------------------------------------------

# --- ENGR13300 auto-venv setup ---------------------------------------------

# 1) Set your course root and venv path
export ENGR_ROOT="$HOME/Desktop/Purdue/Freshman_Year_2025_2026/ENGR13300"
export ENGR_VENV="$ENGR_ROOT"           # e.g. "$ENGR_ROOT/venv" if you used `venv`

# 2) Command: `engr133` -> cd to the folder and (optionally) activate venv
engr133() {
  cd "$ENGR_ROOT" || return
  if [[ "$VIRTUAL_ENV" != "$ENGR_VENV" && -d "$ENGR_VENV/bin" ]]; then
    read -q "REPLY?Activate ENGR13300 venv now? [y/N] " && echo
    [[ "$REPLY" == [yY] ]] && source "$ENGR_VENV/bin/activate"
  fi
}

# 3) Auto-prompt on entering/leaving the project tree
autoload -Uz add-zsh-hook

_engr_in_tree() {
  # true if $PWD is ENGR_ROOT or any subdir
  [[ "$PWD" == "$ENGR_ROOT" || "$PWD" == "$ENGR_ROOT"/* ]]
}

_engr_auto_venv() {
  if _engr_in_tree; then
    # In ENGR tree: if not already in the course venv, offer to activate
    if [[ "$VIRTUAL_ENV" != "$ENGR_VENV" ]]; then
      if [[ -d "$ENGR_VENV/bin" ]]; then
        read -q "REPLY?Activate ENGR13300 venv? [y/N] " && echo
        [[ "$REPLY" == [yY] ]] && source "$ENGR_VENV/bin/activate"
      else
        echo "⚠️  ENGR venv not found at: $ENGR_VENV  (create with: python3 -m venv \"$ENGR_VENV\")"
      fi
    fi
  else
    # Outside ENGR tree: if course venv is still active, offer to deactivate
    if [[ "$VIRTUAL_ENV" == "$ENGR_VENV" ]]; then
      if whence -w deactivate >/dev/null 2>&1; then
        read -q "REPLY?Deactivate ENGR13300 venv? [y/N] " && echo
        [[ "$REPLY" == [yY] ]] && deactivate
      fi
    fi
  fi
}

add-zsh-hook chpwd _engr_auto_venv
# Also run once on shell start so a session opened inside ENGR_ROOT behaves
_engr_auto_venv
# ---------------------------------------------------------------------------

