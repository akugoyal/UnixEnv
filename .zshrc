# --- Auto-backup zshrc on reload (+ optional GitHub sync on change) ----------
backup_dir="$HOME/Desktop/Backups"
max_backups=10
repo_dir="$HOME/repos/UnixEnv"
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
PROMPT='%B%F{2}%n%f %F{141}%~%f ${vcs_info_msg_0_}$%b '
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
export PATH="/usr/local/bin/tailscale:$PATH"
# ---------------------------------------------------------------------

# --- Aliases ---------------------------------------------------------
alias cs159="cd ~/repos/PurdueRepos/CS15900/"
alias ece264="cd ~/repos/PurdueRepos/ECE26400/"
alias python="python3"
alias pip="pip3"
alias reload-zsh="source ~/.zshrc && echo 'zshrc reloaded'"
alias matlab="/Applications/MATLAB_R2025b.app/bin/matlab"
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
alias loq="ssh akugy@akul-win-laptop"
alias rpi="ssh akul@akuls-rpi4b"
alias ieee="cd ~/repos/PurdueRepos/IEEE"
alias alienware="ssh -X goyal186@172.30.72.197"
alias alienware_admin="ssh -X goyal186_admin@172.30.72.197"
# ---------------------------------------------------------------------

# --- ENGR13300 auto-venv setup ---------------------------------------------

# 1) Set your course root and venv path
export ENGR_ROOT="$HOME/repos/PurdueRepos/ENGR13300"
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
export VIP_PARENT="$HOME/repos/PurdueRepos/VIP"
export VIP_PROJECT_SUBFOLDER="VIP_Satellites"
export VIP_ROOT="${VIP_PARENT}/${VIP_PROJECT_SUBFOLDER}"
export VIP_ROOT="${VIP_ROOT:A}"
export VIP_VENV="${VIP_ROOT:A}"

# 2) Command: `vip` -> cd to the folder and (optionally) activate venv
vip() {
  cd "$VIP_ROOT" || return
}

# 3) Auto-prompt on entering/leaving the project tree
autoload -Uz add-zsh-hook

_vip_in_tree() {
  [[ "$PWD" == "$VIP_ROOT" || "$PWD" == "$VIP_ROOT"/* ]]
}

_vip_auto_venv() {
  if _vip_in_tree; then
    if [[ "${VIRTUAL_ENV:A}" != "${VIP_VENV:A}" ]]; then
      if [[ -d "$VIP_VENV/bin" ]]; then
        read -q "REPLY?Activate VIP venv? [y/N] " && echo
        [[ "$REPLY" == [yY] ]] && source "$VIP_VENV/bin/activate"
      else
        echo "⚠️  VIP venv not found at: $VIP_VENV  (create with: python3 -m venv \"$VIP_VENV\")"
      fi
    fi
  else
    if [[ "${VIRTUAL_ENV:A}" == "${VIP_VENV:A}" ]]; then
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

# --- ECE20875 auto-venv setup -----------------------------------------------------

# 1) Set your project root and venv path
export ECE20875_ROOT="$HOME/repos/PurdueRepos/ECE20875"
export ECE20875_VENV="$ECE20875_ROOT"           # e.g. "$ECE20875_ROOT/venv" if you used `venv`

# 2) Command: `ECE20875` -> cd to the folder and (optionally) activate venv
ece20875() {
  cd "$ECE20875_ROOT" || return
}

# 3) Auto-prompt on entering/leaving the project tree
autoload -Uz add-zsh-hook

_ECE20875_in_tree() {
  [[ "$PWD" == "$ECE20875_ROOT" || "$PWD" == "$ECE20875_ROOT"/* ]]
}

_ECE20875_auto_venv() {
  if _ECE20875_in_tree; then
    if [[ "$VIRTUAL_ENV" != "$ECE20875_VENV" ]]; then
      if [[ -d "$ECE20875_VENV/bin" ]]; then
        read -q "REPLY?Activate ECE20875 venv? [y/N] " && echo
        [[ "$REPLY" == [yY] ]] && source "$ECE20875_VENV/bin/activate"
      else
        echo "⚠️  ECE20875 venv not found at: $ECE20875_VENV  (create with: python3 -m venv \"$ECE20875_VENV\")"
      fi
    fi
  else
    if [[ "$VIRTUAL_ENV" == "$ECE20875_VENV" ]]; then
      if whence -w deactivate >/dev/null 2>&1; then
        read -q "REPLY?Deactivate ECE20875 venv? [y/N] " && echo
        [[ "$REPLY" == [yY] ]] && deactivate
      fi
    fi
  fi
}

add-zsh-hook chpwd _ECE20875_auto_venv
_ECE20875_auto_venv
# ---------------------------------------------------------------------------

# --- ECE27000 auto-venv setup ----------------------------------------------

# Course root and venv
export ECE270_ROOT="$HOME/repos/PurdueRepos/ECE27000"
export ECE270_VENV="$ECE270_ROOT/.venv"

# Command: `ece270` -> cd to the course repository
ece270() {
  cd "$ECE270_ROOT" || return
}

# Auto-prompt on entering/leaving the project tree
autoload -Uz add-zsh-hook

_ece270_in_tree() {
  [[ "$PWD" == "$ECE270_ROOT" || "$PWD" == "$ECE270_ROOT"/* ]]
}

_ece270_auto_venv() {
  if _ece270_in_tree; then
    # Inside ECE27000: offer to activate its venv
    if [[ "${VIRTUAL_ENV:A}" != "${ECE270_VENV:A}" ]]; then
      if [[ -d "$ECE270_VENV/bin" ]]; then
        read -q "REPLY?Activate ECE27000 venv? [y/N] " && echo
        [[ "$REPLY" == [yY] ]] && source "$ECE270_VENV/bin/activate"
      else
        echo "⚠️  ECE27000 venv not found at: $ECE270_VENV"
        echo "Create it with: python3 -m venv --prompt ECE27000 \"$ECE270_VENV\""
      fi
    fi
  else
    # Outside ECE27000: offer to deactivate its venv
    if [[ -n "$VIRTUAL_ENV" && "${VIRTUAL_ENV:A}" == "${ECE270_VENV:A}" ]]; then
      if whence -w deactivate >/dev/null 2>&1; then
        read -q "REPLY?Deactivate ECE27000 venv? [y/N] " && echo
        [[ "$REPLY" == [yY] ]] && deactivate
      fi
    fi
  fi
}

add-zsh-hook chpwd _ece270_auto_venv

# Handle shells opened while already inside ECE27000
_ece270_auto_venv

# ---------------------------------------------------------------------------
