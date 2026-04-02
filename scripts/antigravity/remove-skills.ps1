# Requires -Version 5.1

$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent | Split-Path -Parent | Split-Path -Parent
$SkillsDir = Join-Path -Path $ProjectRoot -ChildPath "skills"
$AntigravityGlobalDir = Join-Path -Path $env:USERPROFILE -ChildPath ".gemini\antigravity\skills"

Write-Host "Removing Superpowers skills from global Antigravity location..." -ForegroundColor Cyan

$RemovedCount = 0

if (Test-Path -Path $SkillsDir) {
    $SkillDirs = Get-ChildItem -Path $SkillsDir -Directory

    foreach ($SkillDir in $SkillDirs) {
        $SkillName = $SkillDir.Name
        $TargetDir = Join-Path -Path $AntigravityGlobalDir -ChildPath "superpowers-$SkillName"

        if (Test-Path -Path $TargetDir) {
            Write-Host "Removing link: $TargetDir"
            Remove-Item -Path $TargetDir -Force
            $RemovedCount++
        }
    }
} else {
    Write-Host "Skills directory not found at: $SkillsDir" -ForegroundColor Red
}

Write-Host ""
Write-Host "Successfully removed $RemovedCount skills from Antigravity global location." -ForegroundColor Green
