# ----------------------------------------
# PowerShell Profile
# ----------------------------------------

# ----------------------------------------
# Prompt setup (Starship)
# ----------------------------------------

# Oh My Posh (kept for reference / rollback)
# oh-my-posh.exe init pwsh --config "$HOME\AppData\Local\Programs\oh-my-posh\themes\custom.omp.json" | Invoke-Expression

# Ensure Starship binary is in PATH (avoid duplicates)
# if (-not ($env:Path -split ';' | Where-Object { $_ -eq 'C:\Program Files\starship\bin\' })) {
#     $env:Path += ';C:\Program Files\starship\bin\'
# }

if (Get-Command starship -ErrorAction SilentlyContinue) {
    $env:STARSHIP_CONFIG = "$HOME\.config\starship.toml"
    
    function Invoke-Starship-TransientFunction {
        & starship module character
    }

    # Initialize Starship (defines the functions)
    Invoke-Expression (& starship init powershell)
}

# ----------------------------------------
# Command line editing (PSReadLine)
# ----------------------------------------

if (-not (Get-Module PSReadLine)) {
    Import-Module PSReadLine
}

# PSReadLine options
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle InlineView
Set-PSReadLineOption -HistorySaveStyle SaveIncrementally
Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadLineOption -HistorySearchCursorMovesToEnd

# ${UserConfigDir}/powershell/Microsoft.PowerShell_profile.ps1
$env:CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense' # optional
Set-PSReadLineOption -Colors @{ "Selection" = "`e[7m" }
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
carapace _carapace | Out-String | Invoke-Expression

# Set-PSReadLineOption -EditMode Windows
# Set-PSReadLineOption -ShowToolTips (Carapace doesnt work if this is enabled)
# Set-PSReadLineOption -EditMode Vi
# Set-PSReadLineKeyHandler -Chord 'j','k' -Function ViCommandMode
# Set-PSReadLineOption -ViModeIndicator Cursor

Set-PSReadLineOption -MaximumHistoryCount 10000
Set-PSReadLineOption -CompletionQueryItems 200

$Global:HistoryIgnorePatterns = @(
    'ls', 'l', 'la', 'll', 'lt', 'tree',
    'clear', 'cls',
    'cd', 'pwd',
    'exit'
)

# Better history handler (skip blank/space-start commands)
Set-PSReadLineOption -AddToHistoryHandler {
    param([string]$command)

    $cmd = $command.Trim()

    if ([string]::IsNullOrWhiteSpace($cmd)) {
        return $false
    }

    if ($command.StartsWith(' ')) {
        return $false
    }

    if ($Global:HistoryIgnorePatterns -contains $cmd) {
        return $false
    }

    return $true
}


# Keybindings
Set-PSReadLineKeyHandler -Key UpArrow         -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow       -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key RightArrow      -Function AcceptSuggestion

Set-PSReadLineKeyHandler -Key Ctrl+a          -Function SelectAll
Set-PSReadLineKeyHandler -Key Ctrl+Backspace  -Function BackwardKillWord
Set-PSReadLineKeyHandler -Key Ctrl+Delete     -Function KillWord
Set-PSReadLineKeyHandler -Key Ctrl+LeftArrow  -Function BackwardWord
Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function ForwardWord

Set-PSReadLineKeyHandler -Key LeftArrow       -Function BackwardChar
Set-PSReadLineKeyHandler -Key RightArrow      -Function ForwardChar

Set-PSReadLineKeyHandler -Key Ctrl+l          -Function ClearScreen
Set-PSReadLineKeyHandler -Key Alt+.           -Function YankLastArg

# ----------------------------------------
# History & Navigation Enhancements (fzf)
# ----------------------------------------

# Base fzf UI defaults (safe everywhere)
$env:FZF_DEFAULT_OPTS = '--height=40% --reverse --border --cycle'

# ----------------------
# fd integration (safe)
# ----------------------
# Use fd for files + directories if available, otherwise fall back to PowerShell
if (Get-Command fd -ErrorAction SilentlyContinue) {
    $env:FZF_DEFAULT_COMMAND = 'fd --hidden --follow --exclude .git'
} else {
    $env:FZF_DEFAULT_COMMAND = 'Get-ChildItem -Recurse -Force | Select-Object -ExpandProperty FullName'
}

# ----------------------
# Ctrl+R → Fuzzy history
# ----------------------
function Invoke-FuzzyHistory {
    $history = [Microsoft.PowerShell.PSConsoleReadLine]::GetHistoryItems() |
        Sort-Object Id -Descending |
        ForEach-Object CommandLine |
        Select-Object -Unique

    $cmd = $history |
        fzf --prompt 'History > ' --ansi

    if ($cmd) {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($cmd)
    }
}
Set-PSReadLineKeyHandler -Key Ctrl+r -ScriptBlock { Invoke-FuzzyHistory }

# ----------------------
# Ctrl+T → Fuzzy files & dirs
# ----------------------
function fzf-file {
    # Determine file list source
    if (Get-Command fd -ErrorAction SilentlyContinue) {
        $listSource = { fd . }
    } else {
        # PowerShell fallback: recurse directories
        $listSource = { Get-ChildItem -Recurse -File -Force -ErrorAction SilentlyContinue |
                        ForEach-Object { $_.FullName } }
    }
    # Determine preview command
    if (Get-Command bat -ErrorAction SilentlyContinue) {
        # bat is available
        $preview = 'bat --style=numbers --color=always --line-range :500 {} 2>$null'
    } else {
        # Fallback to Get-Content if bat isn't installed
        $preview = 'Get-Content {} -TotalCount 200 2>$null'
    }
    # Run fzf with ANSI so bat will show colors
    $result = & $listSource |
        fzf --ansi `
            --height=40% --border --prompt 'Files > ' `
            --preview $preview
    if ($result) {
        # Resolve and insert path
        $path = (Resolve-Path $result).Path
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert((Convert-Path $path))
    }
}
Set-PSReadLineKeyHandler -Key Ctrl+t -ScriptBlock { fzf-file }

# ----------------------------------------
# Lazy-loading modules (performance-friendly)
# ----------------------------------------

$null = Register-EngineEvent -SourceIdentifier 'PowerShell.OnIdle' -MaxTriggerCount 1 -Action {
    $env:POSH_GIT_ENABLED = $false
    Import-Module posh-git -ErrorAction SilentlyContinue
    Import-Module Microsoft.WinGet.CommandNotFound -ErrorAction SilentlyContinue
}

# ----------------------------------------
# Useful aliases
# ----------------------------------------

# cat alias for bat if available
# if (Get-Command bat -ErrorAction SilentlyContinue) {
#     Set-Alias cat bat
# } else {
#     Set-Alias cat Get-Content
# }

Set-Alias notepad 'C:\Windows\System32\notepad.exe'

# Create directory and enter it
function mkcd {
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Path
    )

    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Location $Path
}

# ----------------------------------------
# zoxide (smart directory jumping)
# ----------------------------------------

$env:_ZO_ECHO            = '1'
$env:_ZO_MAXAGE          = '10000'
$env:_ZO_RESOLVE_SYMLINKS = '1'

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    (& zoxide init powershell) -join "`n" | Invoke-Expression
}

# ----------------------------------------
# eza (enhanced listing) aliases
# ----------------------------------------

if (Get-Command eza -ErrorAction SilentlyContinue) {

    # Base flags for appearance
    $EZA_BASE = @(
        '--icons=always'
        '--color=always'
        '--group-directories-first'
    )

    # Long-view flags for metadata
    $EZA_LONG = @(
        '--long'
        '--header'
        '--sort=name'
        '--total-size'
        '--smart-group'
        '--time=modified'
        '--time-style=long-iso'
        '--git'
    )

    # Basic ls replacement (no hidden files, no metadata)
    Remove-Alias -Name ls -ErrorAction SilentlyContinue
    function ls {
        eza @EZA_BASE @args
    }

    # Basic list (no hidden files, metadata)
    function l {
        eza @EZA_BASE @EZA_LONG @args
    }

    # All files (including hidden) with full metadata
    function la {
        eza @EZA_BASE @EZA_LONG '--all' @args
    }

    # All files, sorted by modified time (long view)
    function ll {
        eza @EZA_BASE @EZA_LONG '--sort=modified' '--reverse' @args
    }

    # Tree view (default depth = 1)
    function tree {
        param([int]$Depth = 1)
        eza @EZA_BASE '--tree' "--level=$Depth" @args
    }

    # Tree + metadata (long + tree, depth = 1)
    function lt {
        param([int]$Depth = 1)
        eza @EZA_BASE @EZA_LONG '--tree' "--level=$Depth" @args
    }
}

# Enable it last to override any conflicting PSReadLine handlers
if (Get-Command Enable-TransientPrompt -ErrorAction SilentlyContinue) {
    Enable-TransientPrompt
}

# ----------------------------------------
# End of Profile
# ----------------------------------------
