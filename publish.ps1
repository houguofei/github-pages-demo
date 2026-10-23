# One-click publisher for the github-pages-demo showcase repo.
# Usage:
#   .\publish.ps1 -Source <file-or-folder> -Name <ascii-dir-name> [-Message <commit msg>]
param(
    [Parameter(Mandatory = $true)][string]$Source,
    [Parameter(Mandatory = $false)][string]$Name,
    [Parameter(Mandatory = $false)][string]$Message
)

$ErrorActionPreference = 'Stop'
$repoRoot = $PSScriptRoot

# --- resolve source ---
$srcPath = Resolve-Path -LiteralPath $Source -ErrorAction SilentlyContinue
if (-not $srcPath) { Write-Error "Source not found: $Source" }
$srcItem = Get-Item -LiteralPath $srcPath.Path

if (-not $Name) { $Name = $srcItem.Name }
if ($Name -match '[^\x00-\x7F]') {
    Write-Warning "Name '$Name' contains non-ASCII characters; the URL will be percent-encoded. Consider an ASCII name."
}
if ($Name -notmatch '^[A-Za-z0-9._-]+$') {
    Write-Error "Name '$Name' contains characters that are unsafe for URLs. Use letters, digits, dot, dash, underscore."
}

# --- copy into shows/ ---
$destDir = Join-Path $repoRoot "shows\$Name"
New-Item -ItemType Directory -Force -Path $destDir | Out-Null
if ($srcItem.PSIsContainer) {
    # -Path (not -LiteralPath) so the trailing wildcard * is expanded
    Copy-Item -Path (Join-Path $srcItem.FullName '*') -Destination $destDir -Recurse -Force -ErrorAction Stop
} else {
    Copy-Item -LiteralPath $srcItem.FullName -Destination $destDir -Force
}
if (-not (Test-Path -LiteralPath (Join-Path $destDir 'index.html'))) {
    Write-Warning "No index.html in the published folder - the portal card will 404 until you add one."
}
# refuse to commit an empty/missing destination
if (-not (Get-ChildItem -LiteralPath $destDir -Force | Select-Object -First 1)) {
    Write-Error "Nothing was copied to shows/$Name - aborting."
}

# --- commit & push ---
git -C $repoRoot add "shows/$Name"
$staged = git -C $repoRoot status --porcelain
if (-not $staged) {
    Write-Host "No changes to publish (shows/$Name is already up to date)."
    exit 0
}
if (-not $Message) { $Message = "Add show: $Name" }
git -C $repoRoot commit -m $Message | Out-Null
git -C $repoRoot push | Out-Null

Write-Host ""
Write-Host "Published: https://houguofei.github.io/github-pages-demo/shows/$Name/"
Write-Host "Portal:    https://houguofei.github.io/github-pages-demo/  (auto-updates in ~1 min)"
