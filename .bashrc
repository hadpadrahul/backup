# ~/.bashrc
# Unified, portable Bash configuration
# Safe for: personal machines, servers, SSH, tmux, TTY, containers

############################
# INTERACTIVE SHELL ONLY  #
############################
# Prevent execution in non-interactive shells (scripts, scp, etc.)
case $- in
    *i*) ;;
      *) return ;;
esac

############################
# HISTORY CONFIG          #
############################

# Append history instead of overwriting
shopt -s histappend

# Large history (safe for servers, tmux, SSH)
HISTSIZE=100000
HISTFILESIZE=200000

# Ignore duplicates and trivial commands
# (merged behavior: ignoreboth + erasedups)
HISTCONTROL=ignoreboth:erasedups
HISTIGNORE="ls:ll:l:cd:cd -:pwd:exit:clear:history"

# Sync history across multiple sessions
__history_sync() {
    history -a    # append new history lines
    history -c    # clear current session history
    history -r    # reload full history
}

# Preserve any existing PROMPT_COMMAND
PROMPT_COMMAND="__history_sync${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

########################
# WINDOW SIZE HANDLING #
########################
# Automatically update LINES and COLUMNS
shopt -s checkwinsize

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
# FZF CONFIG (NEW)    #
########################

# Load official fzf bash integration
# Sets up default keybindings:
#   Ctrl+T → file search
#   Ctrl+R → command history
#   Alt+C  → directory jump
eval "$(fzf --bash)"

# ----------------------
# fd integration (safe)
# ----------------------
# Use fd if available, otherwise fall back to fzf defaults
if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# ----------------------
# bat preview (safe)
# ----------------------
# Enable bat-based previews only if bat exists
if command -v bat >/dev/null 2>&1; then
    export FZF_DEFAULT_OPTS="--height 40% --reverse --border \
      --preview 'bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || sed -n \"1,200p\" {}' \
      --preview-window=right:60%:wrap"
else
    # Fallback: no preview, but keep layout consistent
    export FZF_DEFAULT_OPTS="--height 40% --reverse --border"
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

    tree() {
        local depth=2 args=()
        while [[ $# -gt 0 ]]; do
            case "$1" in
                -L|--level) depth="$2"; shift 2 ;;
                *) args+=("$1"); shift ;;
            esac
        done
        eza $EZA_BASE --tree --level="$depth" "${args[@]}"
    }

    lt() {
        local depth=2 args=()
        while [[ $# -gt 0 ]]; do
            case "$1" in
                -L|--level) depth="$2"; shift 2 ;;
                *) args+=("$1"); shift ;;
            esac
        done
        eza $EZA_BASE $EZA_LONG --tree --level="$depth" "${args[@]}"
    }
else
    # Classic ls aliases (from bashrc #2)
    alias ls='ls --color=auto'
    alias ll='ls -alF'
    alias la='ls -A'
    alias l='ls -CF'
fi

########################
# SAFER FILE OPS     #
########################
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

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
# SHELL SAFETY & UX   #
########################
# Fail on unmatched globs (power-user safety)
shopt -s failglob

# Preferred editor
export EDITOR=nvim
export VISUAL=nvim

# Secure default permissions
umask 022

########################
# OPTIONAL EXTRAS     #
########################
# Uncomment if you want startup system info
# if command -v fastfetch >/dev/null 2>&1; then
#     fastfetch --config ~/.config/fastfetch/config.jsonc
# fi

# Uncomment to enable recursive globbing (**)
shopt -s globstar
