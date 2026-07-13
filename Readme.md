# CLI Tools & Terminal Productivity

> Single-file reference for modern CLI tooling, terminal workflow design, installation rules, and maintenance scripts.

---

## Table of Contents

- [System Principles](#system-principles-non-negotiable-rules)
- [Core CLI Kit](#1-core-cli-kit-daily-use)
- [Experimental Tools](#2-experimental--evaluation-tools)
- [Terminal & Shell Ecosystem](#3-terminal--shell-ecosystem)
- [Navigation & File Discovery](#4-navigation--file-discovery)
- [Fuzzy Finding & Preview](#5-fuzzy-finding--preview-system)
- [History & Completion](#6-history--completion-system)
- [Git & Version Control](#7-git--version-control-tooling)
- [System Monitoring](#8-system-monitoring--analysis)
- [Networking & API](#9-networking--api-tools)
- [DevOps & Cloud](#10-devops--cloud-tooling)
- [Productivity & Automation](#11-productivity--automation)
- [Installation Guide](#12-installation-manifests)
- [Maintenance Scripts](#13-maintenance-scripts)

---

## System Principles (NON-NEGOTIABLE RULES)

## Installation Architecture

- System tools → `apt` (base OS utilities, stable packages)
- Official sources → Docker, Cloudflare, Kubernetes, Tailscale, etc. (vendor-managed repos)
- `mise` → development tool runtime manager (installed via official APT repo)
- Developer CLI tools → installed via `mise use -g <tool>`

# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

---

# 1. CORE CLI KIT (DAILY USE)

fastfetch  
htop  
fzf  (television is also must checkout with some config or default)
fd  
sd  
ripgrep (rg)  
duf  
dust
ncdu
age
eza  
jq  
yq  
zoxide  
yazi  
bat  
xh  
curlie  (optional, `curl` & `xh` works)
tldr  
delta (optional, `hunk` alternative if needed)
lazygit
lazydocker (if needed)
zip  (`ouch` a single alternative for all types)
unzip

---

# 2. EXPERIMENTAL / EVALUATION TOOLS

## Still to Review
chezmoi (dotfile manager with templating)
viddy (modern `watch` replacement)  
broot (interactive tree navigation alternative)  
jless (JSON viewer)  
logdy (log streaming UI)  
act (run GitHub Actions locally)  
trippy (traceroute + ping TUI)

sshs (tui for ssh configs)
atac (posting rust alternative for api testing)

## Done Reviewing
zellij (tmux alternative, modern terminal multiplexer)  
stow (dotfile symlinks)
television (fuzzy finder TUI alternative to fzf in some workflows)  
gdu (fast disk usage analyzer)  
age (modern encryption tool replacing gpg use cases in simple flows)
herdr (agent/AI terminal multiplexer concept tool)  
vimium (browser keyboard navigation extension)  
shortcat (OS-level keyboard navigation tool)  
direnv (auto-load env per directory)  
dotenvx (secure env file management with encryption)
sesh (session manager for terminals)  
sessionx (session management tooling) 

---

# 3. TERMINAL & SHELL ECOSYSTEM

## Terminal Emulators

wezterm (GPU-accelerated, highly configurable)  
ghostty (modern fast terminal emulator)  
Windows Terminal (Microsoft multiplexer terminal UI)  
alacritty (minimal GPU terminal)  
kitty (feature-rich GPU terminal)

## Shells

bash (default POSIX-compatible shell)  
zsh (feature-rich interactive shell)  
fish (user-friendly shell with autosuggestions)  
nushell (structured data shell)  
pwsh (PowerShell cross-platform shell)

## Fonts

JetBrains Mono Nerd Font (current primary choice)  
Hack Nerd Font  
Fira Code Nerd Font  

## Prompt Engine

starship (cross-shell prompt with git + context awareness)

---

# 4. NAVIGATION & FILE DISCOVERY

zoxide (smart directory jumping, learns usage patterns)  
fd (fast file search, simpler than find, respects .gitignore)  
ripgrep / rg (fast recursive search engine, grep replacement)  
eza (modern ls replacement with icons, git status, tree view)

---

# 5. FUZZY FINDING & PREVIEW SYSTEM

fzf (universal fuzzy finder for files, history, git, processes)  
bat (syntax highlighted file viewer, used for previews in fzf)

Key concept: pipe-anything → interactive selection → return result to shell

---

# 6. HISTORY & COMPLETION SYSTEM

PSReadLine (PowerShell history + Ctrl+R search)  
fzf history search (interactive shell history filtering)  
atuin (optional: persistent distributed shell history database)  
carapace (unified completion engine across CLI tools)

---

# 7. GIT & VERSION CONTROL TOOLING

lazygit (interactive git UI for staging, commits, branches)  
gitui (alternative git TUI)  
delta (syntax-highlighted diff viewer replacing plain diff)  
hunk (experimental diff viewer / patch explorer)

---

# 8. SYSTEM MONITORING & ANALYSIS

htop (classic process viewer)  
btop (modern enhanced system monitor)  
procs (modern ps replacement with readable output)  
duf (modern df replacement for disks)  
dust (modern du replacement for directory sizes)  
dozzle (real-time Docker log viewer UI)

---

# 9. NETWORKING & API TOOLS

xh (HTTP client, curl alternative with better UX)  
curlie (curl with HTTPie-style usability)  
posting (Postman-like terminal API client)  
doggo (DNS lookup tool)  
bandwhich (per-process network bandwidth monitor)  
tailscale (mesh VPN overlay network)  
netbird (alternative mesh VPN with routing + UI features)  
trippy (network diagnostics: traceroute + ping combined TUI)

---

# 10. DEVOPS & CLOUD TOOLING

docker + lazydocker (container management + UI)  
kubectl + k9s (Kubernetes CLI + terminal dashboard)  
aws CLI / azure CLI / gcloud CLI (cloud resource management)  
terraform (infrastructure as code)  
cloudflared (Cloudflare tunnel agent)  
dive (inspect docker image layers)  
gh (GitHub CLI)  
skopeo (container image inspection without pulling)

---

# 11. PRODUCTIVITY & AUTOMATION

direnv (auto environment loading per directory)  
dotenvx (secure env file encryption + management)  
sd (modern sed replacement for find/replace)  
tldr / tealdeer (simplified command help pages)  
pueue (background task queue system)  
miniserve (quick HTTP file server)  
espanso (text expansion system across OS)

---

# 12. INSTALLATION MANIFESTS

## System Tools (APT baseline)

```bash
sudo apt update && sudo apt install -y \
git curl wget tmux htop bash-completion rsync \
zip unzip tar xz-utils \
build-essential ca-certificates gnupg \
less man-db manpages \
dnsutils lsof strace \
file procps iproute2 iputils-ping \
ncdu
```

## optional tools

```bash
sudo apt update && sudo apt install -y \
mtr-tiny \
pciutils usbutils \
software-properties-common
```

## Official Repository Tools

Docker  
mise  
Tailscale / Netbird  
Cloudflared  
Kubernetes (kubectl)  

## mise global tools

```bash
mise use -g \
fzf fd ripgrep bat eza zoxide neovim yazi \
doggo carapace xh sd yq \
github:dalance/procs hyperfine watchexec \
github:ouch-org/ouch fastfetch duf dust usage jq
```

Install jq through apt if needed in scripts or anywhere else instead of mise

## optional tools

```bash
mise use -g age lazygit btop gdu trippy tealdeer
```

## python tooling

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
uv tool install --python 3.13 posting
```

---

# 13. MAINTENANCE SCRIPTS

## Bash history dedupe (preserve timestamps, remove only `cd` and `cd ..`)

```bash
tac "$HISTFILE" | awk '/^#[0-9]+$/{ts=$0;next}!s[$0]++&&!/^(cleawr|cls|l|ls|la|ll|lh|pwd|exit|cd|cd \.\.|history|top|htop|v)$/{if(ts)print ts;print;ts=""}' | tac >"$HISTFILE.tmp" && mv "$HISTFILE.tmp" "$HISTFILE" && history -c && history -r
```

## Bash history dedupe (remove timestamps, remove only `cd` and `cd ..`)

```bash
tac "$HISTFILE" | awk '!/^#[0-9]+$/&&!s[$0]++&&!/^(cleawr|cls|l|ls|la|ll|lh|pwd|exit|cd|cd \.\.|history|top|htop|v)$/' | tac >"$HISTFILE.tmp" && mv "$HISTFILE.tmp" "$HISTFILE" && history -c && history -r
```
## Bash history dedupe (remove timestamps, remove all `cd` variants)

```bash
tac "$HISTFILE" | awk '!/^#[0-9]+$/&&!s[$0]++&&!/^(cleawr|cls|l|ls|la|ll|lh|pwd|exit|history|top|htop|v)$/&&!/^cd($| )/' | tac >"$HISTFILE.tmp" && mv "$HISTFILE.tmp" "$HISTFILE" && history -c && history -r
```

## PowerShell dedupe (remove only `cd` and `cd ..`)

```powershell
$h=(Get-PSReadLineOption).HistorySavePath;$l=[IO.File]::ReadAllLines($h);$s=@{};$o=for($i=$l.Length-1;$i -ge 0;$i--){if(!$s[$l[$i]] -and $l[$i] -notmatch '^(cleawr|cls|l|ls|la|ll|lh|pwd|exit|cd|cd \.\.|history|top|htop|v)$'){$s[$l[$i]]=$true;$l[$i]}};[array]::Reverse($o);$o|Set-Content $h
```

## PowerShell dedupe (remove all `cd` variants)

```powershell
$h=(Get-PSReadLineOption).HistorySavePath;$l=[IO.File]::ReadAllLines($h);$s=@{};$o=for($i=$l.Length-1;$i -ge 0;$i--){if(!$s[$l[$i]] -and $l[$i] -notmatch '^(cleawr|cls|l|ls|la|ll|lh|pwd|exit|history|top|htop|v)$' -and $l[$i] -notmatch '^cd($| )'){$s[$l[$i]]=$true;$l[$i]}};[array]::Reverse($o);$o|Set-Content $h
```

## PowerShell sort unique

```powershell
$h=(Get-PSReadLineOption).HistorySavePath
(Get-Content $h | Sort-Object -Unique) | Set-Content $h
```