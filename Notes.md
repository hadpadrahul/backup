# CLI Tools & Terminal Productivity

## In short
Fastfetch, Htop, Fzf, Fd, sd, Rg, Duf, dust, Eza, Jq, yq, Zoxide, yazi, Bat, xh, tldr, delta, lazygit, direnv, yazi or broot, jless, zip, unzip

## Check out
- Stow / chezmoi

## Noted
- atop
- btop
- btm
- ncdu
- perf
- just / mise
- plocate
- bash-completion
- carapace
- ouch
- jaq
- hyperfine
- watchexec
- rage
- dasel
- qq

---

## 1. Terminal Setup & Shell

### Terminal Emulator
Use a modern emulator like Windows Terminal or WezTerm for tabs, splits, GPU acceleration, and customization.  
(wezterm and ghostty best)  
(alacritty, kitty optional)

### Terminal Shells
Pwsh, zsh, nushell, fish

### Fonts
- Hack Nerd Font (current)
- JetBrains Mono Nerd Font (recommended)
- Fira Code Nerd Font

Recommended for readability, ligatures, and prompt icons.

### Prompt
Starship prompt — fast, context-aware, minimal but informative.

---

## 2. Navigation & Search

Modern replacements for directory traversal and file finding:

- zoxide — learns frequently used directories for quick jumping
- fd — fast file finder, simpler and faster than find
- ripgrep (rg) — blazing fast recursive search that respects `.gitignore`
- eza — modern `ls` replacement with tree view and Git status support; part of your profile already

---

## 3. Fuzzy Search & Preview

- fzf — fuzzy finder for files, history, processes, etc.
- Use bat as a previewer inside fzf for rich syntax highlighting and context

---

## 4. History & Command Suggestions

- PSReadLine + fzf history — fast fuzzy history search (Ctrl+R)
- (Explore later) Atuin — enhanced, persistent, searchable history across sessions (timestamps, context)
- (Explore later) Carapace — experiment with context-aware completions for CLI tools

---

## 5. Git & Source Control Helpers

- lazygit or gitui — terminal UIs for Git workflows (staging, commits, branches)
- delta — diff pager with syntax highlighting, great for Git diffs

---

## 6. System Monitoring & Utilities

Tools that give better insights than traditional built-ins:

- btop — real-time system monitor (CPU, memory, disks, network)
- procs — modern alternative to ps
- duf — user-friendly disk usage summary
- dust — disk usage analyzer

---

## 7. Networking & API Tools

Useful for debugging networks and APIs:

- xh — human-friendly HTTP clients for API testing (optional: httpie)
- (Optional) bandwhich — real-time bandwidth per process (network insight)

---

## 8. DevOps & Cloud CLI Tools

Essential for infrastructure and automation:

- Docker CLI + lazydocker — manage containers and images from terminal
- kubectl + k9s — Kubernetes CLI and TUI for easier cluster navigation
- AWS CLI / Azure CLI / gcloud CLI — cloud resource management from terminal
- Dive — inspect Docker image layers to optimize size and performance

---

## 9. Productivity & Task Helpers

Utilities that streamline common or recurring tasks:

- sd — intuitive find-and-replace tool (modern sed)
- tldr — concise, community-maintained help pages for CLI commands
- just — simple project task runner
- pueue — CLI queue for long or parallel jobs
- miniserve — quick HTTP file server from CLI

---

## 10. Optional Tools Worth Exploring

Not core to the current workflow but useful to investigate:

- Atuin — enhanced persistent shell history with metadata
- Carapace — context-aware fuzzy CLI completion engine
- broot — interactive directory tree navigator
- fselect — SQL-like file finder
- ncdu — disk usage utility with interactive UI
- Gemini CLI / AI coding CLIs — future CLI tools integrating AI assistance
- .stow — for handling dotfiles
