# CLI Tools and Terminal Productivity

## Installation Architecture (The Rule)

- **System Tools:** Use `apt` for base system packages and core utilities.
- **Official Sources:** Use official repositories for external platforms (Docker, Cloudflare, Kubernetes, Tailscale, etc.).
- **Mise Engine:** Install `mise` by registering its official repository via `apt`.
- **Developer Experience (DX) and Tooling:** Use `mise use -g <tool>` to handle global CLI binaries.

---

## Quick Reference Lists

### Core Kit (In Short)

`fastfetch` • `htop` • `fzf` • `fd` • `sd` • `rg` • `duf` • `dust` • `eza` • `jq` • `yq` • `zoxide` • `yazi` • `bat` • `xh` • `curlie` • `tldr` • `delta` • `lazygit` • `zip` • `unzip` 

### Testing / Evaluation (Check Out)

- `zellij` (The Best plug & play tmux alternative, better than tmux for some)
- `stow` / `chezmoi` (Dotfiles Management)
- `television` (Fuzzy Finder TUI)
- `sesh` / `sessionx` (Terminal Session Managers, tmux plugins)
- `viddy` (Modern watch command replacement)
- `herdr` (Terminal agent multiplexer for AI coding agents; tmux alternative built for tracking agent status like Claude Code/Codex, though tmux remains preferred)
- `vimium` (Browser keyboard navigation) `shortcat` (os level keyboard based navigation)
- `direnv` / `dotenvx` 
- `broot` (Yazi alternative)
- `jless`
- `logdy` (Lightweight streaming log viewer Web UI)
- `act` (Run GitHub Actions locally inside Docker)
- `trippy` (Modern traceroute + ping TUI for network diagnosis)
- `gdu` (lite alternative to ncdu, for Fastest Disk Analyzer)
- `age` (alternative to gpg, for Modern Encryption)

### Internal Bench (Noted / Under Review)

- **Monitoring/Trace:** `atop`, `btop`, `btm`, `ncdu`, `gdu`, `perf`, `watchexec`, `hyperfine`, `dozzle` (Real-time log viewer for Docker containers)
- **Parsers/Search:** `jaq`, `dasel`, `qq`, `plocate`
- **Utilities:** `just` (Note: mise task runner is preferred), `ouch`, `rage`, `sudo needrestart`
- **Completions:** `bash-completion`, `carapace`

---

## 1. Terminal Setup and Shell

### Terminal Emulator

Use a modern emulator like Windows Terminal or WezTerm for tabs, splits, GPU acceleration, and customization.

- **Top Picks:** `wezterm`, `ghostty`
- **Alternatives:** `Windows Terminal`, `alacritty`, `kitty`

### Window Management and Navigation

- **macOS Tiling:** `aerospace` (i3-like tiling window manager for macOS based on SRS) (better alternative of skhd)
- **Browser Navigation Extension:** `Vimium` / `Vimium C` (Vim keyboard shortcuts everywhere inside the browser)
- **OS / Desktop UI Navigation:** `shortcat` (Keyboard navigation for GUI elements across the operating system)

### Terminal Shells

`pwsh`, `bash`, `zsh`, `nushell`, `fish`

### Typography and Prompt

- **Fonts:** `Hack Nerd Font` • `JetBrains Mono Nerd Font` (Current) • `Fira Code Nerd Font`
- **Prompt Engine:** `starship` (Fast, cross-shell, context-aware, minimal but informative)

---

## 2. Navigation and Search

Modern replacements for directory traversal and file finding:

- `zoxide` — learns frequently used directories for quick jumping.
- `fd` — fast file finder, simpler and faster than find.
- `ripgrep (rg)` — blazing fast recursive search that respects `.gitignore`.
- `eza` — modern `ls` replacement with tree view and Git status support; part of your profile already.

---

## 3. Fuzzy Search and Preview

- `fzf` — general-purpose command-line fuzzy finder for files, history, processes, etc.
- `bat` — syntax highlighting file viewer used as the preview window inside `fzf` for rich context.

---

## 4. History and Command Suggestions

- `PSReadLine` + `fzf history` — fast fuzzy history search via `Ctrl+R`.
- `atuin` — (Explore later) enhanced, persistent, SQLite-powered shell history across sessions with rich metadata.
- `carapace` — (Explore later) experiment with context-aware completions engine for CLI tools.

---

## 5. Git and Source Control Helpers

- `lazygit` / `gitui` — terminal UIs for Git workflows (staging, commits, branches).
- `delta` — diff pager with syntax highlighting, great for side-by-side terminal comparisons.
- `hunk` — (Explore later) optional terminal diff viewer if tracking hunks.

---

## 6. System Monitoring and Utilities

Tools that give better insights than traditional built-ins:

- `htop` / `btop` — real-time interactive system monitors (CPU, memory, disks, network).
- `procs` — modern alternative to `ps` with human-readable output.
- `duf` — user-friendly disk usage summary (`df` replacement).
- `dust` — directory size analyzer (`du` replacement).
- `dozzle` — TUI/Web dashboard specifically for real-time streaming of Docker container logs.

---

## 7. Networking and API Tools

Useful for debugging networks and APIs:

- `xh` — human-friendly HTTP client for API testing.
- `curlie` — power of curl with the ease of use of httpie.
- `posting` — powerful Postman-like TUI API client that lives inside the terminal (run via uv/pipx).
- `doggo` — modern DNS lookup utility (`dig` replacement).
- `bandwhich` — (Optional) real-time bandwidth tracking per process.
- `tailscale` / `netbird` — Zero-config secure private overlays/mesh VPN networks for overlay links.
- `trippy` — Modern traceroute + ping TUI for network diagnosis.

---

## 8. DevOps and Cloud CLI Tools

Essential for infrastructure and automation:

- `Docker CLI` + `lazydocker` — manage containers and images from the terminal.
- `kubectl` + `k9s` — Kubernetes CLI and TUI for easier cluster navigation.
- `AWS CLI` / `Azure CLI` / `gcloud CLI` — cloud resource management from the terminal.
- `dive` — inspect Docker image layers to optimize size and performance.
- `cloudflared` — Cloudflare Tunnel daemon.
- `terraform` — Infrastructure as Code engine.
- `gh` / `dash-cli` — GitHub integration managers.
- `skopeo` — Inspect remote Docker registries/images without pulling.

---

## 9. Productivity, Environment, and Task Helpers

Utilities that streamline common or recurring tasks:

- `direnv` — shell extension that loads/unloads environment variables depending on the current directory (`.envrc`).
- `dotenvx` — modern, secure alternative for managing `.env` files with encryption support across environments.
- `sd` — intuitive find-and-replace tool (modern `sed`).
- `tldr` / `tealdeer` — concise, community-maintained help pages for CLI commands.
- `pueue` — CLI queue and daemon worker for long or parallel jobs.
- `miniserve` — quick ad-hoc HTTP file server from the CLI.
- `espanso` — cross-platform text expander.

---

## 10. Direct Installation Manifests

### System Tier (apt)

````bash
# Core System Tools
sudo apt update && sudo apt install -y \
  git curl wget tmux htop bash-completion rsync \
  zip unzip tar xz-utils \
  build-essential ca-certificates gnupg software-properties-common \
  less man-db manpages \
  dnsutils net-tools pciutils usbutils lsof strace \
  file procps iproute2 iputils-ping traceroute \
  age jq ncdu

Install Through Official Registries into apt

Follow their official installation docs to add their specific GPG keys to /etc/apt/sources.list.d/
- `docker`-ce / docker-compose-plugin (Docker Engine)
- `mise` (The tool manager itself)
- `tailscale` / netbird (Mesh VPN daemons)
- `cloudflared` (Cloudflare Tunnel daemon)
- `kubectl` (If managed system-wide for automation scripts)
- anyother similar tool

## VPN / Mesh

Tailscale or Netbird for VPN / private mesh (Netbird is a better alternative with its own pros and cons eg gui, dns routing, proxy etc).

## Mise engine (add official repo)

Commands to add the Mise APT repository and install mise:

```bash
sudo install -m 0755 -d /etc/apt/keyrings
wget -qO- https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list
sudo apt update && sudo apt install -y mise
````

## DX tier (use mise to register global CLI tools)

Register common tools globally with mise:

```bash
mise use -g \
  fzf \
  fd \
  ripgrep \
  bat \
  eza \
  zoxide \
  neovim \
  yazi \
  doggo \
  carapace \
  xh \
  sd \
  yq \
  github:dalance/procs \
  hyperfine \
  watchexec \
  github:ouch-org/ouch \
  fastfetch \
  duf \
  dust \
  usage
```

Optional

```bash
mise use -g \
  lazygit \
  btop \
  ncdu \
  gdu \
  trippy \
  tealdeer \
```

## Python TUI: posting (uv tool)

Install uv and the posting tool:

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
uv tool install --python 3.13 posting
```

## 11. Maintenance scripts

Bash history deduplication (preserve timestamps):

```bash
tac "$HISTFILE" | awk '/^#[0-9]+$/{ts=$0;next}!s[$0]++&&!/^(clear|cls|l|ls|la|ll|lh|pwd|exit|cd|cd \.\.|history|top|htop|v)$/{if(ts)print ts;print;ts=""}' | tac >"$HISTFILE.tmp" && mv "$HISTFILE.tmp" "$HISTFILE" && history -c && history -r
```

Bash history deduplication (remove timestamps):

```bash
tac "$HISTFILE" | awk '!/^#[0-9]+$/&&!s[$0]++&&!/^(clear|cls|l|ls|la|ll|lh|pwd|exit|cd|cd \.\.|history|top|htop|v)$/' | tac >"$HISTFILE.tmp" && mv "$HISTFILE.tmp" "$HISTFILE" && history -c && history -r
```

PowerShell 7 history deduplication (preserve last occurrence):

```powershell
$h=(Get-PSReadLineOption).HistorySavePath;$l=[IO.File]::ReadAllLines($h);$s=@{};$o=for($i=$l.Length-1;$i-ge0;$i--){if(!$s[$l[$i]]-and$l[$i]-notmatch'^(clear|cls|l|ls|la|ll|lh|pwd|exit|cd|history|top|htop|v)$'){$s[$l[$i]]=$true;$l[$i]}};[array]::Reverse($o);$o|Set-Content $h
```

PowerShell 7 history alphabetical sort and unique:

```powershell
(Get-Content (Get-PSReadLineOption).HistorySavePath | Sort-Object -Unique) | Set-Content (Get-PSReadLineOption).HistorySavePath
```
