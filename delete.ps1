<#
.SYNOPSIS
    RTS Data Cleaning & Learning Tool - Interaktív karbantartó modul.
#>

$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$BlacklistFile = Join-Path $ScriptPath "blacklist.json"

if (!(Test-Path $BlacklistFile)) {
    Write-Error "Hiba: A blacklist.json nem található a script mellett!"
    exit
}

function Save-Blacklist($Obj) {
    $Obj | ConvertTo-Json -Depth 32 | Out-File $BlacklistFile -Encoding utf8
}

$Blacklist = Get-Content $BlacklistFile | ConvertFrom-Json

param (
    [string]$TargetFolder, # A mappa, amit takarítani akarunk
    [string]$LearnFolder   # A mappa, aminek a tartalmát "szemétnek" kell minősíteni
)

# --- 1. TÖMEGES TANULÁS MAPPÁBÓL ---
if ($LearnFolder -and (Test-Path $LearnFolder)) {
    Write-Host "--- Tömeges tanulás: $LearnFolder ---" -ForegroundColor Magenta
    $Items = Get-ChildItem -Path $LearnFolder -Recurse
    foreach ($Item in $Items) {
        if ($Item.PSIsContainer) {
            if ($Blacklist.GlobalFolderBlacklist -notcontains $Item.Name) {
                $Blacklist.GlobalFolderBlacklist += $Item.Name
            }
        } else {
            $Ext = $Item.Extension.ToLower()
            if ($Ext -and $Blacklist.ExtensionBlacklist -notcontains $Ext) {
                $Blacklist.ExtensionBlacklist += $Ext
            }
        }
    }
    Save-Blacklist $Blacklist
    Write-Host "Tömeges tanulás kész." -ForegroundColor Green
}

# --- 2. TAKARÍTÁS (Törlés a blacklist alapján) ---
if ($TargetFolder -and (Test-Path $TargetFolder)) {
    Write-Host "--- Takarítás indítása: $TargetFolder ---" -ForegroundColor Yellow
    $DeletedCount = 0

    # Mappák törlése
    foreach ($Folder in $Blacklist.GlobalFolderBlacklist) {
        Get-ChildItem -Path $TargetFolder -Filter $Folder -Recurse -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            Write-Host "Törlés (mappa): $($_.FullName)" -ForegroundColor Red
            Remove-Item $_.FullName -Recurse -Force
            $DeletedCount++
        }
    }

    # Fájlok törlése
    $AllExcludes = $Blacklist.ExtensionBlacklist + $Blacklist.InstallerExtensions
    foreach ($Pattern in $AllExcludes) {
        Get-ChildItem -Path $TargetFolder -Filter "$Pattern" -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
            Write-Host "Törlés (fájl): $($_.FullName)" -ForegroundColor Red
            Remove-Item $_.FullName -Force
            $DeletedCount++
        }
    }
    Write-Host "Takarítás kész! $DeletedCount elem eltávolítva." -ForegroundColor Green
}

# --- 3. INTERAKTÍV TANULÁS (Mindig lefut a végén) ---
Write-Host "`n--- Interaktív Tanulási Mód ---" -ForegroundColor Cyan
$Response = Read-Host "Szeretnél új elemet hozzáadni a tiltólistához? (y/n)"

while ($Response -eq 'y') {
    $Type = Read-Host "Mit szeretnél tiltani? [M]appa / [F]ájl-kiterjesztés"
    $NewItem = Read-Host "Add meg a pontos nevet (pl. 'Temp' vagy '.log')"
    
    if ($Type.ToUpper() -eq 'M') {
        if ($Blacklist.GlobalFolderBlacklist -notcontains $NewItem) {
            $Blacklist.GlobalFolderBlacklist += $NewItem
            Write-Host "Mappa ('$NewItem') hozzáadva." -ForegroundColor Green
        }
    } elseif ($Type.ToUpper() -eq 'F') {
        # Pont korrekció, ha lemaradt volna
        if (!$NewItem.StartsWith(".") -and !$NewItem.Contains("*")) { $NewItem = ".$NewItem" }
        if ($Blacklist.ExtensionBlacklist -notcontains $NewItem) {
            $Blacklist.ExtensionBlacklist += $NewItem
            Write-Host "Kiterjesztés ('$NewItem') hozzáadva." -ForegroundColor Green
        }
    }

    Save-Blacklist $Blacklist
    $Response = Read-Host "Akarsz még valamit megadni? (y/n)"
}

Write-Host "Karbantartás befejezve." -ForegroundColor Gray
