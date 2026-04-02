# Requires -Version 5.1

$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent | Split-Path -Parent | Split-Path -Parent
$SkillsDir = Join-Path -Path $ProjectRoot -ChildPath "skills"
$AntigravityGlobalDir = Join-Path -Path $env:USERPROFILE -ChildPath ".gemini\antigravity\skills"

Write-Host "Installing Superpowers skills as flat global Antigravity skills..." -ForegroundColor Cyan

if (-not (Test-Path -Path $AntigravityGlobalDir)) {
    Write-Host "Creating Antigravity global skills directory: $AntigravityGlobalDir"
    New-Item -ItemType Directory -Force -Path $AntigravityGlobalDir | Out-Null
}

$InstalledCount = 0

if (Test-Path -Path $SkillsDir) {
    $SkillDirs = Get-ChildItem -Path $SkillsDir -Directory

    foreach ($SkillDir in $SkillDirs) {
        $SkillName = $SkillDir.Name
        $TargetDir = Join-Path -Path $AntigravityGlobalDir -ChildPath "superpowers-$SkillName"

        if (Test-Path -Path $TargetDir) {
            Write-Host "Removing existing link: $TargetDir" -ForegroundColor Yellow
            Remove-Item -Path $TargetDir -Force
        }

        Write-Host "Linking superpowers-$SkillName -> $($SkillDir.FullName)"
        # Using mklink /J for directory junctions which works without admin rights
        cmd /c mklink /J "`"$TargetDir`"" "`"$($SkillDir.FullName)`"" | Out-Null
        $InstalledCount++
    }
} else {
    Write-Host "Skills directory not found at: $SkillsDir" -ForegroundColor Red
    Exit 1
}

Write-Host ""
Write-Host "Successfully installed $InstalledCount skills to Antigravity global location." -ForegroundColor Green
Write-Host "Global location: $AntigravityGlobalDir" -ForegroundColor Cyan
