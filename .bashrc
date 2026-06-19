# ~/.bashrc
# Unified, portable Bash configuration
# Safe for: personal machines, servers, SSH, tmux, TTY, containers

# Mise shell environment manager
if command -v mise >/dev/null 2>&1; then
    if [[ $- != *i* ]]; then
        # 1. Non-interactive session (IDEs, scripts): Load Shims
        eval "$(mise activate bash --shims)"
    else
        # 2. Interactive session (Your actual terminal): Load Activate
        eval "$(mise activate bash)"
    fi
fi

############################
# INTERACTIVE SHELL ONLY  #
############################
# Prevent execution in non-interactive shells (scripts, scp, etc.)
case $- in
    *i*) ;;
      *) return ;;
esac

########################
# SHELL MODE DETECTION #
########################
# Detect if running over SSH
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
# Append history instead of overwriting
shopt -s histappend

# Automatically update LINES and COLUMNS
shopt -s checkwinsize

# Nothing on unmatched globs
# shopt -s nullglob

# Uncomment to enable recursive globbing (**)
# shopt -s globstar

# Safer pipelines
set -o pipefail

# Secure default permissions
umask 022

############################
# HISTORY CONFIG          #
############################

# Large history (safe for servers, tmux, SSH)
HISTFILE=~/.bash_history
HISTSIZE=100000
HISTFILESIZE=200000

# Store timestamps in history
HISTTIMEFORMAT="%F %T "

# Ignore duplicates and trivial commands
# (merged behavior: ignoreboth + erasedups)
HISTCONTROL=ignoreboth:erasedups
HISTIGNORE="ls:ll:l:la:cd:cd -:pwd:exit:clear:cleawr:history:&:[ ]*"

# Sync history across multiple sessions
__history_sync() {
    history -a    # append new history lines
    history -n    # Reads new lines from history
}

# Preserve any existing PROMPT_COMMAND
PROMPT_COMMAND="__history_sync${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

########################
# LESS (PAGER) CONFIG #
########################
# -R : allow raw ANSI colors
# -F : quit if output fits on one screen
# -X : do not clear screen after exit
export LESS="-RFX"

########################
# LESSPIPE            #
########################
# Enable smart previews (archives, PDFs, etc.)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

########################
# ENVIRONMENT VARS    #
########################
# Preferred editor
export EDITOR=nvim
export VISUAL=nvim

########################
# DEBIAN CHROOT INFO  #
########################
# Display chroot name in prompt if present
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

########################
# PROMPT CONFIG       #
########################
# Enable colors for capable terminals
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes ;;
esac

# Optional manual override (from classic bashrc)
# force_color_prompt=yes

if [ -n "${force_color_prompt:-}" ]; then
    if command -v tput >/dev/null 2>&1 && tput setaf 1 >/dev/null 2>&1; then
        color_prompt=yes
    else
        color_prompt=
    fi
fi

# Main prompt
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\
\[\033[01;32m\]\u@\h\
\[\033[00m\]:\
\[\033[01;34m\]\w\
\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# Set terminal title for xterm-like terminals
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
esac

########################
# CORE COLOR ALIASES  #
########################
# Classic Debian behavior, guarded
if command -v dircolors >/dev/null 2>&1; then
    test -r ~/.dircolors \
        && eval "$(dircolors -b ~/.dircolors)" \
        || eval "$(dircolors -b)"

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

########################
# USER ALIASES        #
########################
[ -f ~/.bash_aliases ] && . ~/.bash_aliases

########################
# TOOL ALIASES (EZA)  #
########################
# bat → batcat compatibility (Ubuntu/Debian)
if command -v batcat >/dev/null 2>&1; then
    alias bat='batcat'
fi

if command -v nvim >/dev/null 2>&1; then
    alias v='nvim'
fi


# Prefer eza if available, otherwise fall back to classic ls aliases
if command -v eza >/dev/null 2>&1; then
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

    # Enhanced tree view
    # Fully compatible with eza flags
    tree() {
        local depth=1
        local level_set=0
        local args=()

        # Positional numeric depth support (eg tree 3)
        if [[ "$1" =~ ^[0-9]+$ ]]; then
            depth="$1"
            shift
            level_set=1
        fi

        # Check if user provided their own level flag
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

    # Enhanced long tree view
    # Fully compatible with eza flags
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
            eza $EZA_BASE $EZA_LONG --tree --ignore-glob=".git" "$@"
        else
            eza $EZA_BASE $EZA_LONG --tree --level="$depth" --ignore-glob=".git" "$@"
        fi
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
    [ -n "$1" ] || { echo "Usage: mkcd <directory>"; return 1; }
    mkdir -p -- "$1" && cd -- "$1"
}


########################
# SAFER FILE OPS      #
########################
alias rm='rm -Iv'
alias cp='cp -i'
alias mv='mv -i'

########################
# RAW FZF CONFIG       #
########################
# Load distro-provided fzf keybindings & completion
# if [ -f /usr/share/doc/fzf/examples/key-bindings.bash ]; then
#     source /usr/share/doc/fzf/examples/key-bindings.bash
# fi
# if [ -f /usr/share/doc/fzf/examples/completion.bash ]; then
#     source /usr/share/doc/fzf/examples/completion.bash
# fi

# Ctrl+r → fuzzy history search (overrides default if fzf exists)
# if command -v fzf >/dev/null 2>&1; then
# __fzf_history__() {
#     local selected
#     selected=$(history | sed 's/^[ ]*[0-9]\+[ ]*//' | tac |
#         fzf --height=40% --reverse --border --prompt="History > ")
#     if [ -n "$selected" ]; then
#         READLINE_LINE="$selected"
#         READLINE_POINT=${#READLINE_LINE}
#     fi
# }
# bind -x '"\C-r": __fzf_history__'
# fi

# # Ctrl+t → fuzzy file picker (fd + bat optional)
# if command -v fzf >/dev/null 2>&1 && command -v fd >/dev/null 2>&1; then
# __fzf_file__() {
#     local selected
#     selected=$(fd --hidden --follow --exclude .git 2>/dev/null |
#         fzf --height=40% --reverse --border \
#             --preview 'command -v bat >/dev/null 2>&1 && bat --style=numbers --color=always --line-range :500 {}')
#     if [ -n "$selected" ]; then
#         READLINE_LINE+="$selected"
#         READLINE_POINT=${#READLINE_LINE}
#     fi
# }
# bind -x '"\C-t": __fzf_file__'
# fi

########################
# FZF CONFIG (UPDATED)#
########################
if command -v fzf >/dev/null 2>&1; then
    eval "$(fzf --bash)"

    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --info=inline"

    export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window=up:3:wrap"

    if command -v fd >/dev/null 2>&1; then
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

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
fi

########################
# BASH COMPLETION     #
########################
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

########################
# PATH DEDUPLICATION  #
########################
# Deduplicate PATH entries while preserving order
path_dedupe() {
    local IFS=:
    local new_path=""
    for dir in $PATH; do
        [[ ":$new_path:" != *":$dir:"* ]] && new_path="${new_path:+$new_path:}$dir"
    done
    PATH="$new_path"
}

[ -n "$PATH" ] && path_dedupe
export PATH

########################
# LOCAL MACHINE OVERRIDES
########################
# Optional per-machine config (not tracked in dotfiles)
[ -f ~/.bashrc_local ] && . ~/.bashrc_local

########################
# HISTORY SAFETY TRAP #
########################
# Ensure history is written even on shell exit or kill
trap 'history -a' EXIT

# Fix for some SSH/TTY issues: Ensure the completion character is handled
bind 'set completion-ignore-case on'
bind 'set show-all-if-ambiguous on'

########################
# OPTIONAL EXTRAS     #
########################
# Uncomment if you want startup system info
if command -v fastfetch >/dev/null 2>&1; then
    fastfetch --config ~/.config/fastfetch/config.jsonc
fi

# Carapace shell completion framework
if command -v carapace >/dev/null 2>&1; then
    export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
    export PATH="$HOME/.config/carapace/bin:$PATH"
    source <(carapace _carapace bash)
fi