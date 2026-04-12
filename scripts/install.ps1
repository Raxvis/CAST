#Requires -Version 5.1
<#
.SYNOPSIS
    Install the multi-agent workflow template into a target project.

.DESCRIPTION
    PowerShell twin of scripts/install.sh. Copies all template files into a
    target project directory and optionally substitutes placeholder tokens
    from interactive prompts or a values file.

    Same behavior as install.sh:

    - Copies root/CLAUDE.md, agents/*.md, commands/*.md, docs/, artifacts/,
      and scripts/check-placeholders.sh into the target.
    - Prompts interactively for the essential placeholders by default, or
      for all supported placeholders with -Full, or reads a key=value file
      with -Values.
    - Substitutes placeholders across every copied Markdown file.
    - Writes template.values with the chosen answers and the template
      version stamp.
    - Runs an inline placeholder check and reports remaining tokens.

    This PowerShell implementation is intended for Windows users without
    WSL. For macOS, Linux, or WSL, prefer install.sh.

.PARAMETER Target
    Absolute or relative path to the target project directory. The
    directory must already exist.

.PARAMETER Full
    Prompt for every supported placeholder, not just essentials.

.PARAMETER Values
    Path to a key=value file with placeholder answers. When supplied, the
    script runs non-interactively.

.PARAMETER Force
    Overwrite an already-populated target. Without this flag, the script
    refuses to install over an existing .claude\agents\ directory.

.PARAMETER Help
    Print usage and exit.

.EXAMPLE
    .\scripts\install.ps1 C:\path\to\your-project

    Interactive install with the essential prompts only.

.EXAMPLE
    .\scripts\install.ps1 C:\path\to\your-project -Full

    Interactive install with every supported prompt.

.EXAMPLE
    .\scripts\install.ps1 C:\path\to\your-project -Values template.values

    Non-interactive install from a values file.

.EXAMPLE
    .\scripts\install.ps1 C:\path\to\your-project -Force

    Overwrite an already-populated target.
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0, Mandatory = $false)]
    [string]$Target,

    [switch]$Full,

    [string]$Values,

    [switch]$Force,

    [Alias('h')]
    [switch]$Help
)

$ErrorActionPreference = 'Stop'

# ---------- Template version ----------
# Bumped alongside CHANGELOG.md at the template repo root.
# Keep in sync with the TEMPLATE_VERSION constant in scripts/install.sh.
$TemplateVersion = '0.8.1'

if ($Help -or -not $Target) {
    if (-not $Target -and -not $Help) {
        Write-Host "Error: target directory required" -ForegroundColor Red
        Write-Host ''
    }
    Get-Help $PSCommandPath -Detailed
    if (-not $Target) { exit 1 } else { exit 0 }
}

# ---------- Resolve paths ----------

if (-not (Test-Path -LiteralPath $Target -PathType Container)) {
    Write-Host "Error: target directory $Target does not exist" -ForegroundColor Red
    exit 1
}

$Target = (Resolve-Path -LiteralPath $Target).Path
$ScriptDir = Split-Path -Parent $PSCommandPath
$TemplateRoot = Split-Path -Parent $ScriptDir

# ---------- Safety check ----------

$AgentsDir = Join-Path $Target '.claude\agents'
if ((-not $Force) -and (Test-Path -LiteralPath $AgentsDir)) {
    $existing = Get-ChildItem -LiteralPath $AgentsDir -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host "Error: $AgentsDir is already populated." -ForegroundColor Red
        Write-Host "Pass -Force to overwrite, or choose a different target." -ForegroundColor Red
        exit 1
    }
}

# ---------- Placeholder definitions ----------
# Mirror of the ESSENTIALS and FULL_EXTRAS arrays in scripts/install.sh.
# Keep the two in sync on any bump.

$Essentials = @(
    [PSCustomObject]@{ Key = 'PROJECT_NAME';       Description = 'Human-readable project name';                                 Example = 'Acme Dashboard' }
    [PSCustomObject]@{ Key = 'PROJECT_TYPE';       Description = 'Category of software (web service, mobile app, CLI tool)';    Example = 'web service' }
    [PSCustomObject]@{ Key = 'ONE_SENTENCE_PITCH'; Description = 'Single sentence describing the product';                      Example = 'A budgeting tool for freelancers' }
    [PSCustomObject]@{ Key = 'LANGUAGE';           Description = 'Primary programming language';                                Example = 'TypeScript' }
    [PSCustomObject]@{ Key = 'FRAMEWORK';          Description = 'Primary application framework';                               Example = 'Next.js' }
    [PSCustomObject]@{ Key = 'TEST_CMD';           Description = 'Command to run the full test suite';                          Example = 'npm test' }
    [PSCustomObject]@{ Key = 'DEV_SERVER_CMD';     Description = 'Command to start the local dev server';                       Example = 'npm run dev' }
    [PSCustomObject]@{ Key = 'BUILD_CMD';          Description = 'Command to produce a production build';                       Example = 'npm run build' }
)

$FullExtras = @(
    [PSCustomObject]@{ Key = 'FRAMEWORK_VERSION';      Description = 'Framework version';                            Example = '14.2' }
    [PSCustomObject]@{ Key = 'STATE_LIBRARY';          Description = 'State management library';                     Example = 'Zustand' }
    [PSCustomObject]@{ Key = 'STATE_LIBRARY_VERSION';  Description = 'State library version';                        Example = '4.5' }
    [PSCustomObject]@{ Key = 'PERSISTENCE_LAYER';      Description = 'Primary persistence mechanism';                Example = 'PostgreSQL' }
    [PSCustomObject]@{ Key = 'NAVIGATION_LIBRARY';     Description = 'Routing or navigation solution';               Example = 'Next.js App Router' }
    [PSCustomObject]@{ Key = 'TEST_RUNNER';            Description = 'Test runner tool';                             Example = 'Vitest' }
    [PSCustomObject]@{ Key = 'PKG_MANAGER';            Description = 'Package manager';                              Example = 'pnpm' }
    [PSCustomObject]@{ Key = 'PKG_ADD_CMD';            Description = 'Command to add a dependency';                  Example = 'pnpm add' }
    [PSCustomObject]@{ Key = 'PKG_MANIFEST';           Description = 'Dependency manifest filename';                 Example = 'package.json' }
    [PSCustomObject]@{ Key = 'FRAMEWORK_CONFIG';       Description = 'Framework config filename';                    Example = 'next.config.js' }
    [PSCustomObject]@{ Key = 'TYPE_CONFIG';            Description = 'Type checker config filename';                 Example = 'tsconfig.json' }
    [PSCustomObject]@{ Key = 'BUNDLER_CONFIG';         Description = 'Bundler config filename';                      Example = 'next.config.js' }
    [PSCustomObject]@{ Key = 'EXT';                    Description = 'Source file extension';                        Example = 'tsx' }
    [PSCustomObject]@{ Key = 'TYPE_CHECK_CMD';         Description = 'Command to run static type check';             Example = 'tsc --noEmit' }
    [PSCustomObject]@{ Key = 'DOMAIN_ENTITY';          Description = 'Primary domain object';                        Example = 'order' }
    [PSCustomObject]@{ Key = 'RESOURCE_TYPE';          Description = 'Secondary resource type';                      Example = 'line item' }
    [PSCustomObject]@{ Key = 'CORE_MECHANIC';          Description = 'Central user action';                          Example = 'placing an order' }
    [PSCustomObject]@{ Key = 'PROGRESSION_UNIT';       Description = 'Measure of user progress';                     Example = 'completed orders' }
    [PSCustomObject]@{ Key = 'SCREEN_DIR';             Description = 'Directory for screen/page files';              Example = 'app/' }
    [PSCustomObject]@{ Key = 'LOGIC_DIR';              Description = 'Directory for business logic';                 Example = 'src/lib/' }
    [PSCustomObject]@{ Key = 'STORE_DIR';              Description = 'Directory for state management';               Example = 'src/store/' }
    [PSCustomObject]@{ Key = 'COMPONENTS_DIR';         Description = 'Directory for UI components';                  Example = 'src/components/' }
    [PSCustomObject]@{ Key = 'HOOKS_DIR';              Description = 'Directory for hooks/providers';                Example = 'src/hooks/' }
    [PSCustomObject]@{ Key = 'CONSTANTS_DIR';          Description = 'Directory for constants';                      Example = 'src/constants/' }
    [PSCustomObject]@{ Key = 'ASSETS_DIR';             Description = 'Directory for static assets';                  Example = 'public/' }
    [PSCustomObject]@{ Key = 'MAIN_SCREEN';            Description = 'Core feature screen name';                     Example = 'dashboard' }
    [PSCustomObject]@{ Key = 'LOWER_CASE_CONVENTION';  Description = 'Lower-case naming convention';                 Example = 'camelCase' }
    [PSCustomObject]@{ Key = 'PASCAL_CASE_CONVENTION'; Description = 'Type/component naming convention';             Example = 'PascalCase' }
    [PSCustomObject]@{ Key = 'UPPER_SNAKE_CONVENTION'; Description = 'Constant naming convention';                   Example = 'UPPER_SNAKE_CASE' }
    [PSCustomObject]@{ Key = 'SAVE_KEY';               Description = 'Storage key for persisted data';               Example = 'acme_app_data_v1' }
    [PSCustomObject]@{ Key = 'SAVE_VERSION';           Description = 'Current save format version';                  Example = '1' }
    [PSCustomObject]@{ Key = 'TARGET_PLATFORMS';       Description = 'Comma-separated deployment targets';           Example = 'web, desktop' }
    [PSCustomObject]@{ Key = 'PLATFORM_1';             Description = 'Primary target platform';                      Example = 'web' }
    [PSCustomObject]@{ Key = 'PLATFORM_2';             Description = 'Secondary target platform';                    Example = 'desktop' }
    [PSCustomObject]@{ Key = 'COVERAGE_TARGET';        Description = 'Minimum code coverage';                        Example = '80%' }
    [PSCustomObject]@{ Key = 'BRANCH_TARGET';          Description = 'Minimum branch coverage';                      Example = '80%' }
    [PSCustomObject]@{ Key = 'STARTUP_METRIC';         Description = 'Max acceptable startup time';                  Example = '2s' }
    [PSCustomObject]@{ Key = 'TICK_METRIC';            Description = 'Max acceptable update-loop duration';          Example = '16ms' }
    [PSCustomObject]@{ Key = 'RENDER_METRIC';          Description = 'Max acceptable render time';                   Example = '16ms' }
    [PSCustomObject]@{ Key = 'MEMORY_METRIC';          Description = 'Max acceptable memory usage';                  Example = '200MB' }
    [PSCustomObject]@{ Key = 'MAX_AGE_DAYS';           Description = 'Max days before a task is stale';              Example = '14' }
    [PSCustomObject]@{ Key = 'MAX_BLOCKED_DAYS';       Description = 'Max days a task can be blocked';               Example = '7' }
    [PSCustomObject]@{ Key = 'CRITICAL_BLOCKED_DAYS';  Description = 'Max days a critical task can be blocked';     Example = '3' }
)

# ---------- Collect values ----------
# Use an ordered hashtable to preserve answer order in template.values.

$ValuesMap = [ordered]@{}

if ($Values) {
    if (-not (Test-Path -LiteralPath $Values -PathType Leaf)) {
        Write-Host "Error: values file $Values not found" -ForegroundColor Red
        exit 1
    }
    $lines = Get-Content -LiteralPath $Values
    foreach ($line in $lines) {
        $trimmed = $line.Trim()
        if (-not $trimmed) { continue }
        if ($trimmed.StartsWith('#')) { continue }
        $idx = $trimmed.IndexOf('=')
        if ($idx -lt 0) { continue }
        $key = $trimmed.Substring(0, $idx).Trim()
        $val = $trimmed.Substring($idx + 1).Trim()
        # Strip optional surrounding quotes.
        if ($val.Length -ge 2) {
            if (($val.StartsWith('"') -and $val.EndsWith('"')) -or
                ($val.StartsWith("'") -and $val.EndsWith("'"))) {
                $val = $val.Substring(1, $val.Length - 2)
            }
        }
        $ValuesMap[$key] = $val
    }
    Write-Host "Loaded $($ValuesMap.Count) values from $Values"
}
else {
    $prompts = if ($Full) { $Essentials + $FullExtras } else { $Essentials }

    Write-Host ''
    Write-Host "Template install (version $TemplateVersion) - answer each prompt or press Enter to skip."
    Write-Host "You can always re-run with -Values template.values to refine."
    Write-Host ''

    foreach ($p in $prompts) {
        Write-Host "[$($p.Key)]"
        Write-Host "  $($p.Description)"
        Write-Host "  Example: $($p.Example)"
        $answer = Read-Host '  Value'
        if ($answer) {
            $ValuesMap[$p.Key] = $answer
        }
        Write-Host ''
    }
}

# ---------- Copy files ----------

Write-Host "Copying template files to $Target ..."

Copy-Item -LiteralPath (Join-Path $TemplateRoot 'root\CLAUDE.md') -Destination (Join-Path $Target 'CLAUDE.md') -Force

$dotClaudeAgents = Join-Path $Target '.claude\agents'
$dotClaudeCommands = Join-Path $Target '.claude\commands'
New-Item -ItemType Directory -Force -Path $dotClaudeAgents | Out-Null
New-Item -ItemType Directory -Force -Path $dotClaudeCommands | Out-Null

# Ship the settings.json.example so users have a starting point for Claude Code
# project settings. We never overwrite an existing .claude/settings.json.
$settingsExample = Join-Path $TemplateRoot 'root\.claude\settings.json.example'
if (Test-Path -LiteralPath $settingsExample) {
    Copy-Item -LiteralPath $settingsExample -Destination (Join-Path $Target '.claude\settings.json.example') -Force
}

Get-ChildItem -LiteralPath (Join-Path $TemplateRoot 'agents') -Filter '*.md' -File | ForEach-Object {
    # Skip agents/README.md — it is the master overview for human reference,
    # not a subagent definition.
    if ($_.Name -eq 'README.md') { return }
    Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $dotClaudeAgents $_.Name) -Force
}
Get-ChildItem -LiteralPath (Join-Path $TemplateRoot 'commands') -Filter '*.md' -File | ForEach-Object {
    # Skip commands/README.md — Claude Code would register it as /README.
    if ($_.Name -eq 'README.md') { return }
    Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $dotClaudeCommands $_.Name) -Force
}

# Recursive copy of docs/ and artifacts/. Clear first to mimic install.sh's rsync --delete-excluded.
$targetDocs = Join-Path $Target 'docs'
$targetArtifacts = Join-Path $Target 'artifacts'
if (Test-Path -LiteralPath $targetDocs) { Remove-Item -LiteralPath $targetDocs -Recurse -Force }
if (Test-Path -LiteralPath $targetArtifacts) { Remove-Item -LiteralPath $targetArtifacts -Recurse -Force }
Copy-Item -LiteralPath (Join-Path $TemplateRoot 'docs') -Destination $targetDocs -Recurse -Force
Copy-Item -LiteralPath (Join-Path $TemplateRoot 'artifacts') -Destination $targetArtifacts -Recurse -Force

$targetScripts = Join-Path $Target 'scripts'
New-Item -ItemType Directory -Force -Path $targetScripts | Out-Null
Copy-Item -LiteralPath (Join-Path $TemplateRoot 'scripts\check-placeholders.sh') -Destination (Join-Path $targetScripts 'check-placeholders.sh') -Force
Copy-Item -LiteralPath (Join-Path $TemplateRoot 'scripts\smoke-test.sh') -Destination (Join-Path $targetScripts 'smoke-test.sh') -Force

Write-Host 'Files copied.'

# ---------- Substitute placeholders ----------

if ($ValuesMap.Count -gt 0) {
    Write-Host "Substituting $($ValuesMap.Count) placeholders ..."

    $targetFiles = New-Object System.Collections.Generic.List[System.IO.FileInfo]

    $claudeMd = Join-Path $Target 'CLAUDE.md'
    if (Test-Path -LiteralPath $claudeMd) {
        $targetFiles.Add((Get-Item -LiteralPath $claudeMd))
    }

    $dotClaudeDir = Join-Path $Target '.claude'
    if (Test-Path -LiteralPath $dotClaudeDir) {
        Get-ChildItem -LiteralPath $dotClaudeDir -Recurse -Filter '*.md' -File | ForEach-Object {
            $targetFiles.Add($_)
        }
    }
    if (Test-Path -LiteralPath $targetDocs) {
        Get-ChildItem -LiteralPath $targetDocs -Recurse -Filter '*.md' -File | ForEach-Object {
            $targetFiles.Add($_)
        }
    }
    if (Test-Path -LiteralPath $targetArtifacts) {
        Get-ChildItem -LiteralPath $targetArtifacts -Recurse -Filter '*.md' -File | ForEach-Object {
            $targetFiles.Add($_)
        }
    }

    foreach ($file in $targetFiles) {
        $content = Get-Content -Raw -LiteralPath $file.FullName
        foreach ($key in $ValuesMap.Keys) {
            $val = [string]$ValuesMap[$key]
            # Escape $ in replacement string so -replace doesn't interpret it as a backref.
            $replacement = $val.Replace('$', '$$')
            $pattern = '\[' + [regex]::Escape($key) + '\]'
            $content = $content -replace $pattern, $replacement
        }
        Set-Content -LiteralPath $file.FullName -Value $content -NoNewline
    }

    Write-Host 'Substitution complete.'
}

# ---------- Write template.values record ----------

$valuesOut = Join-Path $Target 'template.values'
$stamp = "# Generated by install.ps1 on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"
$stamp += "# Template version: $TemplateVersion`n"
$stamp += "# Re-run with: scripts\install.ps1 <target> -Values template.values`n"
$stamp += "`n"
$stamp += "TEMPLATE_VERSION=$TemplateVersion`n"
foreach ($key in $ValuesMap.Keys) {
    $stamp += "$key=$($ValuesMap[$key])`n"
}
Set-Content -LiteralPath $valuesOut -Value $stamp -NoNewline
Write-Host "Saved answers and template version to $valuesOut"

# ---------- Placeholder check (inline) ----------
# Ported from scripts/check-placeholders.sh so Windows users without WSL
# still get a final report.

function Invoke-PlaceholderCheck {
    param([string]$Path)

    $pattern = '\[[A-Z][A-Z0-9_]+\]'
    $skipFiles = @('README.md', 'CHANGELOG.md', 'TROUBLESHOOTING.md')

    $allFiles = Get-ChildItem -LiteralPath $Path -Recurse -Filter '*.md' -File -ErrorAction SilentlyContinue |
        Where-Object {
            -not ($skipFiles -contains $_.Name) -and
            ($_.FullName -notmatch '[\\/]\.git[\\/]') -and
            ($_.FullName -notmatch '[\\/]node_modules[\\/]')
        }

    $matchLineCount = 0
    $fileCount = 0
    $firstEmit = $true

    foreach ($file in $allFiles) {
        $rawLines = Get-Content -LiteralPath $file.FullName
        $fileEmitted = $false
        for ($i = 0; $i -lt $rawLines.Count; $i++) {
            $line = $rawLines[$i]
            # Note: avoid the name $matches here — it is a PowerShell automatic
            # variable and gets clobbered by any -match or -replace in scope.
            $regexHits = [regex]::Matches($line, $pattern)
            if ($regexHits.Count -gt 0) {
                if (-not $fileEmitted) {
                    if (-not $firstEmit) { Write-Host '' }
                    Write-Host $file.FullName
                    $fileEmitted = $true
                    $firstEmit = $false
                    $fileCount++
                }
                $tokens = ($regexHits | ForEach-Object { $_.Value } | Sort-Object -Unique) -join ' '
                Write-Host "  line $($i + 1): $tokens"
                $matchLineCount++
            }
        }
    }

    if ($matchLineCount -eq 0) {
        Write-Host 'PASS: no unreplaced placeholders found.'
        return $true
    }
    else {
        Write-Host ''
        Write-Host "Total: $matchLineCount lines across $fileCount files."
        return $false
    }
}

Write-Host ''
Write-Host "Scanning $Target for remaining placeholders ..."
Write-Host ''
[void](Invoke-PlaceholderCheck -Path $Target)

# ---------- Next steps ----------

Write-Host ''
Write-Host "Install complete (template version $TemplateVersion)."
Write-Host ''
Write-Host 'Next steps:'
Write-Host "  1. Review $(Join-Path $Target 'template.values') and adjust if needed."
Write-Host '  2. Fill in any placeholders still flagged above by hand.'
Write-Host "  3. Run static verification:  bash $Target\scripts\smoke-test.sh $Target"
Write-Host "  4. Open $Target in Claude Code and walk through docs/FIRST_RUN.md"
Write-Host '     for the interactive verification steps.'
Write-Host '  5. Commit the populated template as the first commit of your project.'
