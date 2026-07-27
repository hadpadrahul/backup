# ~/.bashrc
# Unified, portable Bash configuration
# Safe for: personal machines, VPS, servers, SSH, tmux, TTY, containers
#
# Provisioning assumption (for context, not enforced here):
#   - apt installs base/system tools (git, curl, tmux, htop, jq, yq, docker, etc.)
#   - mise installs fast-moving CLI tools (nvim, rg, fd, eza, doggo, etc.)
#   mise MUST activate before any `command -v` check for mise-managed tools,
#   which is why it's the very first thing in this file.
#   ~/.local/bin may already come from .profile at top. for (echo "$PATH" | tr ':' '\n')

########################
# MISE (must run first)
########################
has() {
    command -v "$1" >/dev/null 2>&1
}

if has mise; then
    if [[ $- != *i* ]]; then
        # Non-interactive session (IDEs, scripts): lightweight shims
        eval "$(mise activate bash --shims)"
    else
        # Interactive session (your actual terminal): full activate
        eval "$(mise activate bash)"
    fi
fi


########################
# XDG BASE DIRECTORIES
########################
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"


########################
# USER TOOL PATHS      #
########################
# User-installed CLI tools:
# ~/.local/bin       -> uv tools, pipx, pip --user, standalone installers
# ~/.cargo/bin       -> Rust cargo installs
# ~/.local/share/bin -> XDG-style installers
# ~/bin              -> personal scripts
for dir in \
    "$HOME/bin" \
    "$HOME/.local/bin" \
    "$HOME/.cargo/bin" \
    "$HOME/.local/share/bin" \
    "$XDG_CONFIG_HOME/carapace/bin"
do
    if [ -d "$dir" ]; then
        export PATH="$PATH:$dir"
    fi
done


############################
# INTERACTIVE SHELL ONLY  #
############################
# Stop here for non-interactive shells (scripts, scp, rsync, etc.)
case $- in
    *i*) ;;
      *) return ;;
esac

# Force a steady block cursor (only if stdout is an actual terminal --
# avoids emitting a raw escape sequence into non-tty output)
if [[ "$TERM" != "linux" && -t 1 ]]; then
    echo -ne '\e[2 q'
fi


########################
# SHELL MODE DETECTION #
########################
# Detect if running over SSH (used later for a prompt badge)
if [ -n "$SSH_CONNECTION" ]; then
    export IS_SSH=1
fi

# Detect if inside tmux
if [ -n "$TMUX" ]; then
    export IS_TMUX=1
fi


########################
# CORE SHELL BEHAVIOR #
########################
shopt -s histappend      # append history instead of overwriting
shopt -s checkwinsize    # keep LINES/COLUMNS in sync with terminal size
shopt -s cmdhist         # save multiline commands as one history entry
shopt -s lithist         # preserve literal newlines in multiline history
shopt -s checkhash       # recheck hashed commands if the executable disappears
shopt -s histverify      # don't execute history expansion immediately, let's view/edit it first
shopt -s cdspell         # autocorrect minor typos in `cd` commands
shopt -s no_empty_cmd_completion   # don't try to complete on an empty prompt line

# shopt -s nullglob      # uncomment: unmatched globs expand to nothing
# shopt -s globstar      # uncomment: enable recursive ** globbing
# shopt -s autocd        # deliberately left off: typing a bare dir name would cd into it

# set -o vi
set -o pipefail          # a pipeline fails if any stage fails, not just the last
umask 022                # secure default file permissions


############################
# HISTORY CONFIG          #
############################
HISTFILE=~/.bash_history
HISTSIZE=100000
HISTFILESIZE=200000
HISTTIMEFORMAT="%F %T "

# Ignore duplicates/trivial commands (ignoreboth + erasedups merged)
HISTCONTROL=ignoreboth:erasedups
HISTIGNORE="ls:ll:l:la:lh:cd:cd -:pwd:exit:clear:cleawr:cls:pwd:top:htop:v:vi:history:&:[ ]*"

# Sync history across multiple simultaneous sessions
__history_sync() {
    history -a    # append new lines from this session to HISTFILE
    history -n    # read in new lines other sessions have appended
}
# Preserve any PROMPT_COMMAND set elsewhere (e.g. by mise/tools) instead of clobbering it
if [[ -n "${PROMPT_COMMAND:-}" ]]; then
    PROMPT_COMMAND="__history_sync; $PROMPT_COMMAND"
else
    PROMPT_COMMAND="__history_sync"
fi

# Belt-and-suspenders: also flush history on shell exit/kill
trap 'history -a' EXIT


########################
# LESS (PAGER) CONFIG #
########################
# -F quit if output fits one screen, -R allow raw ANSI colors, -X don't clear on exit
export LESS="-FRX"

# Smart previews for less (archives, PDFs, etc.) if lesspipe is installed
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"


######################
# NVIM CONFIG        #
######################
if has nvim; then
    export EDITOR=nvim
    export VISUAL=nvim
    export SUDO_EDITOR="$(command -v nvim)"
fi


########################
# DEBIAN CHROOT INFO  #
########################
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi


########################
# PROMPT CONFIG       #
########################
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes ;;
esac

# Optional manual override
# force_color_prompt=yes

if [ -n "${force_color_prompt:-}" ]; then
    if has tput && tput setaf 1 >/dev/null 2>&1; then
        color_prompt=yes
    else
        color_prompt=
    fi
fi

# --- SSH badge: handy when you're bouncing between several VPS and need a
#     quick visual reminder that this shell is remote, not local.
ps1_ssh_tag=""
if [ -n "$IS_SSH" ]; then
    ps1_ssh_tag='\[\033[01;33m\][SSH]\[\033[00m\] '
fi

# --- Root color warning: on a VPS you're far more likely to actually be
#     root than on a personal machine, so make it visually loud (red vs green).
if [ "$(id -u)" -eq 0 ]; then
    ps1_userhost_color='\[\033[01;31m\]'   # red
else
    ps1_userhost_color='\[\033[01;32m\]'   # green
fi

if [ "$color_prompt" = yes ]; then
    PS1="${ps1_ssh_tag}"'${debian_chroot:+($debian_chroot)}\
'"${ps1_userhost_color}"'\u@\h\
\[\033[00m\]:\
\[\033[01;34m\]\w\
\[\033[00m\]\$ '
else
    PS1="${ps1_ssh_tag}"'${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt ps1_ssh_tag ps1_userhost_color

# Set terminal title for xterm-like terminals
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
esac


########################
# CORE COLOR ALIASES  #
########################
if has dircolors; then
    test -r ~/.dircolors \
        && eval "$(dircolors -b ~/.dircolors)" \
        || eval "$(dircolors -b)"

    alias grep='grep --color=auto'
    alias egrep='grep -E --color=auto'
    alias fgrep='grep -F --color=auto'
fi


########################
# USER ALIASES        #
########################
[ -f ~/.bash_aliases ] && . ~/.bash_aliases


########################
# TOOL ALIASES        #
########################
# bat -> batcat compatibility (Ubuntu/Debian package name)
# Colorized man pages via batcat.
# Checked directly because MANPAGER runs in a non-interactive `sh -c`,
# where aliases from this file aren't visible.
# If it doesn't exist, `man` silently falls back to its normal pager (less).
if has batcat; then
    alias bat='batcat'
    export MANPAGER="sh -c 'col -bx | batcat -l man -p'"
fi

# nvim -> vim compatibility (mise installs nvim, not apt)
if has nvim; then
    alias v='nvim'
fi

# tldr -> tealdeer compatibility (mise installs tealdeer, not apt)
if has tealdeer; then
    alias tldr='tealdeer'
fi

# Prefer eza if available, otherwise fall back to classic ls aliases
if has eza; then
    if [[ "$TERM" != "linux" ]]; then
        EZA_BASE="--icons=always --color=always --group-directories-first"
    else
        EZA_BASE="--color=always --group-directories-first"
    fi

    EZA_LONG="--long --header --sort=name --total-size \
              --smart-group --time=modified \
              --time-style=long-iso --git"

    alias ls="eza $EZA_BASE"
    alias l="eza $EZA_BASE $EZA_LONG"
    alias la="eza $EZA_BASE $EZA_LONG --all"
    alias ll="eza $EZA_BASE $EZA_LONG --sort=modified --reverse"

    # Enhanced tree view, fully compatible with eza flags
    tree() {
        local depth=1
        local level_set=0

        # Positional numeric depth support (eg `tree 3`)
        if [[ "$1" =~ ^[0-9]+$ ]]; then
            depth="$1"
            shift
            level_set=1
        fi

        # Respect an explicit -L/--level flag if the user passed one
        for arg in "$@"; do
            case "$arg" in
                -L|--level|--level=*)
                    level_set=1
                    break
                    ;;
            esac
        done

        if [ "$level_set" -eq 1 ]; then
            eza $EZA_BASE --tree --all --ignore-glob=".git" "$@"
        else
            eza $EZA_BASE --tree --level="$depth" --all --ignore-glob=".git" "$@"
        fi
    }

    # Enhanced long tree view, same depth-handling as tree()
    lt() {
        local depth=1
        local level_set=0

        if [[ "$1" =~ ^[0-9]+$ ]]; then
            depth="$1"
            shift
            level_set=1
        fi

        for arg in "$@"; do
            case "$arg" in
                -L|--level|--level=*)
                    level_set=1
                    break
                    ;;
            esac
        done

        if [ "$level_set" -eq 1 ]; then
            eza $EZA_BASE $EZA_LONG --tree "$@"
        else
            eza $EZA_BASE $EZA_LONG --tree --level="$depth" "$@"
        fi
    }

    # Unified change-directory-and-list function
    cx() {
        local target="${1:-$HOME}"
        if [ "$#" -gt 0 ]; then shift; fi

        cd -- "$target" &&
            eza $EZA_BASE $EZA_LONG --tree --level=1 "$@"
    }
else
    alias ls='ls --color=auto'
    alias ll='ls -alF'
    alias la='ls -A'
    alias l='ls -CF'
fi


########################
# HELPER FUNCTIONS     #
########################
# Create directory and enter it safely
mkcd() {
    [ -n "$1" ] || { echo "Usage: mkcd <directory>" >&2; return 1; }
    mkdir -p -- "$1" && cd -- "$1"
}


########################
# SAFER FILE OPS      #
########################
alias rm='rm -Iv'
alias cp='cp -i'
alias mv='mv -i'


########################
# FZF CONFIG          #
########################
if has fzf; then

    # --- 1. Try modern embedded mode (fastest path). Captured once instead
    #        of running `fzf --bash` twice (once to test, once to eval). ---
    __fzf_init="$(fzf --bash 2>/dev/null)"
    if [ -n "$__fzf_init" ]; then
        eval "$__fzf_init"

    # --- 2. Single structured fallback (no repeated if chains) ---
    else
        FZF_BASE=""

        # Prefer modern distro layout
        if [ -d /usr/share/fzf ]; then
            FZF_BASE="/usr/share/fzf"

        # Legacy Debian layout
        elif [ -d /usr/share/doc/fzf/examples ]; then
            FZF_BASE="/usr/share/doc/fzf/examples"
        fi

        if [ -n "$FZF_BASE" ]; then
            [ -f "$FZF_BASE/key-bindings.bash" ] && \
                source "$FZF_BASE/key-bindings.bash"

            [ -f "$FZF_BASE/completion.bash" ] && \
                source "$FZF_BASE/completion.bash"
        fi
        unset FZF_BASE
    fi
    unset __fzf_init

    # --- UI config (unchanged, intentional) ---
    export FZF_DEFAULT_OPTS="--height 60% --layout=reverse --border --info=inline"
    export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window=up:3:wrap"

    # --- fd integration (your original logic preserved) ---
    if has fd; then
        export FZF_CTRL_T_COMMAND='fd --hidden --strip-cwd-prefix --exclude .git'
        export FZF_CTRL_T_OPTS="--preview 'if [ -d {} ]; then eza --color=always {} 2>/dev/null || ls -F {}; else bat --color=always --line-range :200 {} 2>/dev/null || head -n 100 {}; fi'"
    fi

fi


########################
# ZOXIDE CONFIG       #
########################
export _ZO_ECHO=1
export _ZO_MAXAGE=10000
export _ZO_RESOLVE_SYMLINKS=1
export _ZO_FZF_OPTS="--height=40% --reverse --border"

if has zoxide; then
    eval "$(zoxide init bash)"
fi


########################
# BASH COMPLETION     #
########################
# Also covers completions for anything installed via its official apt repo
# with its own completion script (docker, etc.) — nothing extra needed there.
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi


########################
# LOCAL MACHINE OVERRIDES
########################
# Optional per-machine config (not tracked in dotfiles)
[ -f ~/.bashrc_local ] && . ~/.bashrc_local


########################
# CARAPACE            #
########################
# Multi-shell completion framework (bridges completions from zsh/fish/etc.)
if has carapace; then
    export CARAPACE_BRIDGES="zsh,fish,bash,inshellisense"
    source <(carapace _carapace bash)
fi


########################
# READLINE TWEAKS     #
########################
# (No need to re-check $- here -- the script already returns at the top
# for any non-interactive shell, so we're always interactive by this point.)
bind 'set completion-ignore-case on'
bind 'set show-all-if-ambiguous on'

# Optional: type a prefix, then Up/Down cycles history entries matching it,
# instead of just the last/next command overall. Off by default -- uncomment
# to try it.
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'


########################
# PATH DEDUPLICATION  #
########################
# Runs after .bashrc_local so any PATH entries it adds get deduped too.
# Two-pass: fast awk dedup first (no fork per PATH entry), then a cheap
# bash loop over the now-short deduped list to drop directories that no
# longer exist. Gets both the speed and the cleanup.
path_dedupe() {
    local deduped
    deduped="$(awk -v RS=: -v ORS=: 'length && !seen[$0]++' <<< "$PATH")"
    deduped="${deduped%:}"

    local IFS=:
    local new_path=""
    for dir in $deduped; do
        [[ -d "$dir" ]] || continue
        new_path="${new_path:+$new_path:}$dir"
    done
    PATH="$new_path"
}

[ -n "$PATH" ] && path_dedupe
export PATH


########################
# OPTIONAL EXTRAS     #
########################
# Uncomment if you want startup system info
# if has fastfetch; then
#     fastfetch --config ~/.config/fastfetch/config.jsonc
# fi
