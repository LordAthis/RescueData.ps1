<#
.SYNOPSIS
    RescueData Merge Tool - Intelligens összefésülő és duplikációkezelő.
#>

param (
    [string]$SourceBase,
    [string]$MasterPath,
    [switch]$UpdateMD5DB
)

$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$LogicFile = Join-Path $ScriptPath "mergelogic.json"
$MD5File = Join-Path $ScriptPath "md5list.json"
$Logic = Get-Content $LogicFile | ConvertFrom-Json

if (!(Test-Path $MasterPath)) { New-Item -ItemType Directory -Path $MasterPath | Out-Null }
$MD5DB = if (Test-Path $MD5File) { Get-Content $MD5File | ConvertFrom-Json -AsHashtable } else { @{} }

function Get-FolderScore($Path) {
    $score = 0
    $parts = $Path.Split([System.IO.Path]::DirectorySeparatorChar)
    foreach ($part in $parts) {
        if ([string]::IsNullOrWhiteSpace($part)) { continue }
        $score += $Logic.Scoring.DeepPathBonus
        if ($part -match '^[0-9\s\-_]+$') { $score -= $Logic.Scoring.NumericFolderPenalty }
        else { $score += $Logic.Scoring.NamedFolderBonus }
        foreach ($trash in $Logic.Scoring.TrashWords) {
            if ($part -like "*$trash*") { $score -= $Logic.Scoring.TrashWordPenalty }
        }
    }
    return $score
}

function Process-File($SourceFile) {
    if ($SourceFile.Length -lt $Logic.FileRules.MinSizeBytes -and $Logic.FileRules.ExemptFromMinSize -notcontains $SourceFile.Extension.ToLower()) {
        return # Túl kicsi, nem érdekes
    }

    $Hash = (Get-FileHash $SourceFile.FullName -Algorithm MD5).Hash
    $RelativePath = $SourceFile.FullName.Substring($SourceBase.Length)
    $CurrentScore = Get-FolderScore $SourceFile.DirectoryName

    if ($MD5DB.ContainsKey($Hash)) {
        $ExistingEntry = $MD5DB[$Hash]
        if ($CurrentScore > $ExistingEntry.Score) {
            # Az új hely jobb! Áthelyezzük, a régit jelezzük a .mentett.txt-ben
            $OldPath = $ExistingEntry.Path
            $DestFile = Join-Path $MasterPath $RelativePath
            $DestDir = Split-Path $DestFile
            if (!(Test-Path $DestDir)) { New-Item -ItemType Directory -Path $DestDir | Out-Null }
            
            Move-Item $SourceFile.FullName $DestFile -Force
            $LogContent = "Eredeti helyszín: $OldPath`r`nÁthelyezve ide a jobb struktúra miatt: $($SourceFile.FullName)"
            $LogContent | Out-File "$DestFile.mentett.txt" -Append
            
            $MD5DB[$Hash] = @{ Path = $DestFile; Score = $CurrentScore }
        } else {
            # A meglévő hely jobb, csak naplózzuk az alternatív elérhetőséget
            $LogFile = "$($ExistingEntry.Path).mentett.txt"
            "Megtalálható volt itt is: $($SourceFile.FullName)" | Out-File $LogFile -Append
            Remove-Item $SourceFile.FullName -Force # Duplikátum törlése
        }
    } else {
        # Új fájl, sima másolás
        $DestFile = Join-Path $MasterPath $RelativePath
        $DestDir = Split-Path $DestFile
        if (!(Test-Path $DestDir)) { New-Item -ItemType Directory -Path $DestDir | Out-Null }
        Copy-Item $SourceFile.FullName $DestFile -Force
        $MD5DB[$Hash] = @{ Path = $DestFile; Score = $CurrentScore }
    }
}

# Végrehajtás
Write-Host "Összefésülés indítása..." -ForegroundColor Cyan
$AllFiles = Get-ChildItem -Path $SourceBase -File -Recurse
foreach ($File in $AllFiles) { Process-File $File }

if ($UpdateMD5DB) { $MD5DB | ConvertTo-Json | Out-File $MD5File }
Write-Host "Kész! Üres mappák takarítása..." -ForegroundColor Gray
Get-ChildItem $SourceBase -Recurse -Directory | Where-Object { (Get-ChildItem $_.FullName -Recurse) -eq $null } | Remove-Item -Force
