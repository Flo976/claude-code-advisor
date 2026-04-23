# Claude Code Advisor — Windows Installation Script
$ErrorActionPreference = "Stop"

$InstallDir = "$env:USERPROFILE\.claude\skills\claude-code-advisor"

Write-Host ""
Write-Host "  Claude Code Advisor — Installing..." -ForegroundColor Cyan
Write-Host ""

# Prerequisites
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "  Error: git is required but not installed." -ForegroundColor Red
    exit 1
}
if (-not (Get-Command python3 -ErrorAction SilentlyContinue) -and -not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "  Error: python3 is required but not installed." -ForegroundColor Red
    exit 1
}

# Ensure skills directory exists
$SkillsDir = "$env:USERPROFILE\.claude\skills"
if (-not (Test-Path $SkillsDir)) {
    New-Item -ItemType Directory -Path $SkillsDir -Force | Out-Null
}

if (Test-Path $InstallDir) {
    Write-Host "  Updating existing installation..."
    Set-Location $InstallDir
    git pull
} else {
    Write-Host "  Cloning repository..."
    git clone https://github.com/Flo976/claude-code-advisor.git $InstallDir
    Set-Location $InstallDir
}

Write-Host "  Generating local skills catalog..."
$PythonCmd = if (Get-Command python3 -ErrorAction SilentlyContinue) { "python3" } else { "python" }
& $PythonCmd scripts/update-knowledge.py

Write-Host ""
Write-Host "  === Claude Code Advisor installed ===" -ForegroundColor Green
Write-Host ""
Write-Host "  Usage:"
Write-Host "    In Claude Code, say:"
Write-Host "      /advisor              — Get strategy recommendation"
Write-Host "      /advisor update       — Update knowledge base"
Write-Host ""
Write-Host "    Or use natural language:"
Write-Host "      'how should I approach this?'"
Write-Host "      'what's the best way to...'"
Write-Host "      'conseille-moi'"
Write-Host ""
