# --- Auto-backup zshrc on reload (+ optional GitHub sync on change) ----------
backup_dir="$HOME/Desktop/Backups"
max_backups=10
repo_dir="$HOME/Desktop/UnixEnv"
hash_file="$backup_dir/.zshrc_last_hash"

mkdir -p "$backup_dir"

# Current file hash
current_hash=$(shasum -a 256 "$HOME/.zshrc" | awk '{print $1}')

# Last saved hash (if any)
last_hash=""
[[ -f "$hash_file" ]] && last_hash=$(cat "$hash_file")

# Always make a backup on reload
ts="$(date +%Y-%m-%d_%H-%M-%S)"
cp "$HOME/.zshrc" "$backup_dir/.zshrc_backup_${ts}"

# Keep only the $max_backups newest backups
ls -t "$backup_dir"/.zshrc_backup_* 2>/dev/null | tail -n +$((max_backups+1)) | xargs -r rm --

# Only prompt for GitHub sync if file changed since last reload
if [[ "$current_hash" != "$last_hash" ]]; then
  echo "$current_hash" > "$hash_file"   # update hash immediately
  if [[ -d "$repo_dir/.git" ]]; then
    read -q "REPLY?Sync updated .zshrc to GitHub (UnixEnv)? [y/N] " && echo
    if [[ "$REPLY" == [yY] ]]; then
      cp "$HOME/.zshrc" "$repo_dir/.zshrc"
      (
        cd "$repo_dir" || exit 1
        git add .zshrc
        echo -n "Commit message: "
        IFS= read -r msg
        [[ -z "$msg" ]] && msg="Update .zshrc ($(date))"
        git commit -m "$msg" && git push origin main
      ) && echo "🚀 Synced to GitHub" || echo "⚠️ Git sync failed."
    else
      echo "Skipped GitHub sync."
    fi
  fi
fi
# ----------------------------------------------------------------------------

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
export PATH="/opt/homebrew/bin:$PATH"
# ---------------------------------------------------------------------

# --- Aliases ---------------------------------------------------------
alias cs159="cd ~/Desktop/Purdue/Freshman_Year_2025_2026/CS15900/"
alias purduerm="cd ~/Desktop/Purdue/RoboMasters/"
alias python="python3"
alias pip="pip3"
alias reload-zsh="source ~/.zshrc && echo 'zshrc reloaded'"
alias part="cd ~/Desktop/Purdue/PART"
alias matlab="/Applications/MATLAB_R2024a.app/bin/matlab"
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
alias loq="ssh akugy@akul-win-laptop"
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

# --- VIP auto-venv setup -----------------------------------------------------

# 1) Set your project root and venv path
export VIP_ROOT="$HOME/Desktop/Purdue/VIP"
export VIP_VENV="$VIP_ROOT"           # e.g. "$VIP_ROOT/venv" if you used `venv`

# 2) Command: `vip` -> cd to the folder and (optionally) activate venv
vip() {
  cd "$VIP_ROOT" || return
  if [[ "$VIRTUAL_ENV" != "$VIP_VENV" && -d "$VIP_VENV/bin" ]]; then
    read -q "REPLY?Activate VIP venv now? [y/N] " && echo
    [[ "$REPLY" == [yY] ]] && source "$VIP_VENV/bin/activate"
  fi
}

# 3) Auto-prompt on entering/leaving the project tree
autoload -Uz add-zsh-hook

_vip_in_tree() {
  [[ "$PWD" == "$VIP_ROOT" || "$PWD" == "$VIP_ROOT"/* ]]
}

_vip_auto_venv() {
  if _vip_in_tree; then
    if [[ "$VIRTUAL_ENV" != "$VIP_VENV" ]]; then
      if [[ -d "$VIP_VENV/bin" ]]; then
        read -q "REPLY?Activate VIP venv? [y/N] " && echo
        [[ "$REPLY" == [yY] ]] && source "$VIP_VENV/bin/activate"
      else
        echo "⚠️  VIP venv not found at: $VIP_VENV  (create with: python3 -m venv \"$VIP_VENV\")"
      fi
    fi
  else
    if [[ "$VIRTUAL_ENV" == "$VIP_VENV" ]]; then
      if whence -w deactivate >/dev/null 2>&1; then
        read -q "REPLY?Deactivate VIP venv? [y/N] " && echo
        [[ "$REPLY" == [yY] ]] && deactivate
      fi
    fi
  fi
}

add-zsh-hook chpwd _vip_auto_venv
_vip_auto_venv
# ---------------------------------------------------------------------------

