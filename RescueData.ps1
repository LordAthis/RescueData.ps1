<#
.SYNOPSIS
    RTS Data Rescue Tool - Intelligens adatmentő script régi meghajtókhoz.
    GitHub: RescueData.ps1
#>

# 1. Adminisztrátori jog ellenőrzése
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "A script futtatásához Rendszergazdai jogok szükségesek!"
    exit
}

# 2. Útvonalak és fájlok betöltése
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ConfigFile = Join-Path $ScriptPath "config.json"
$BlacklistFile = Join-Path $ScriptPath "blacklist.json"
$LogFile = Join-Path $ScriptPath "rescue_log.txt"

function Log-Message($Message) {
    $Stamp = Get-Date -Format "yyyy.MM.dd HH:mm:ss"
    $LogEntry = "[$Stamp] $Message"
    Write-Host $LogEntry -ForegroundColor Gray
    $LogEntry | Out-File -FilePath $LogFile -Append
}

# JSON beolvasás
if (Test-Path $ConfigFile) { $Config = Get-Content $ConfigFile | ConvertFrom-Json }
if (Test-Path $BlacklistFile) { $Blacklist = Get-Content $BlacklistFile | ConvertFrom-Json }

# 3. Interaktív bekérés, ha a Config üres
if ([string]::IsNullOrWhiteSpace($Config.Identifier)) {
    Write-Host "--- RTS Data Rescue Tool Interaktív Mód ---" -ForegroundColor Cyan
    $IdentityBase = Read-Host "Add meg a mentés azonosító nevét (pl. 60GB-os SSD Win10)"
    $Config.Identifier = "$IdentityBase - $(Get-Date -Format 'yyyy.MM.dd')"
    $Config.SourcePath = Read-Host "Add meg a forrás elérési utat (pl. E:\ vagy D:\Mentes_Mappa)"
    $Config.Options.CompressAfter = (Read-Host "Tömörítsük a végén? (y/n)").ToLower() -eq 'y'
    
    # Mentés a configba
    $Config | ConvertTo-Json | Out-File $ConfigFile
}

$FullDestPath = Join-Path $Config.DestinationBase $Config.Identifier
if (!(Test-Path $FullDestPath)) { New-Item -ItemType Directory -Path $FullDestPath | Out-Null }

Log-Message "Mentés megkezdése: $($Config.SourcePath) -> $FullDestPath"

# 4. Felhasználói profilok felderítése
$UsersPath = Join-Path $Config.SourcePath "Users"
if (!(Test-Path $UsersPath)) {
    Log-Message "Hiba: Nem található a Users mappa a forráson!"
    # Ha mappa alapú mentés van, megpróbáljuk magát a forrást profilként kezelni
    $Profiles = Get-Item $Config.SourcePath
} else {
    $Profiles = Get-ChildItem $UsersPath -Directory | Where-Object { $_.Name -notmatch "Public|Default|All Users" }
}

# 5. MENTÉSI LOGIKA
foreach ($Profile in $Profiles) {
    $UserName = $Profile.Name
    Log-Message "Profil feldolgozása: $UserName"
    $UserDest = Join-Path $FullDestPath $UserName

    # --- ALAP MAPPÁK ---
    $StandardFolders = @("Desktop", "Documents", "Pictures", "Videos")
    foreach ($Folder in $StandardFolders) {
        $Src = Join-Path $Profile.FullName $Folder
        if (Test-Path $Src) {
            $Dest = Join-Path $UserDest $Folder
            Log-Message "Másolás: $Folder"
            # Windows gyári témák kihagyása a képeknél
            $Exclude = $Blacklist.GlobalFolderBlacklist
            robocopy $Src $Dest /E /R:1 /W:1 /MT:8 /XF $Blacklist.ExtensionBlacklist /XD $Exclude /NP | Out-Null
        }
    }

    # --- BÖNGÉSZŐK (Full Profil + Pluginok) ---
    $BrowserPaths = @{
        "Chrome"  = "AppData\Local\Google\Chrome\User Data"
        "Edge"    = "AppData\Local\Microsoft\Edge\User Data"
        "Brave"   = "AppData\Local\BraveSoftware\Brave-Browser\User Data"
        "Opera"   = "AppData\Roaming\Opera Software\Opera Stable"
        "Firefox" = "AppData\Roaming\Mozilla\Firefox\Profiles"
        "Tor"     = "Desktop\Tor Browser\Browser\TorBrowser\Data\Browser"
    }

    foreach ($Browser in $BrowserPaths.Keys) {
        $Src = Join-Path $Profile.FullName $BrowserPaths[$Browser]
        if (Test-Path $Src) {
            Log-Message "Böngésző mentése: $Browser"
            $Dest = Join-Path $UserDest "Browsers\$Browser"
            # Cache szűrés (50KB felett marad)
            robocopy $Src $Dest /E /R:1 /W:1 /MT:8 /XD "Cache" "Code Cache" "GPUCache" /NP | Out-Null
            
            # Külön cache mentés méretkorláttal
            $CacheSrc = Join-Path $Src "*Cache*"
            Get-ChildItem -Path $CacheSrc -File -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Length -gt $Blacklist.BrowserCacheRules.MinSizeBytes } | ForEach-Object {
                $RelPath = $_.FullName.Replace($Src, "")
                $TargetFile = Join-Path $Dest $RelPath
                $TargetDir = Split-Path $TargetFile
                if (!(Test-Path $TargetDir)) { New-Item -ItemType Directory -Path $TargetDir | Out-Null }
                Copy-Item $_.FullName -Destination $TargetFile -Force
            }
        }
    }

    # --- TORRENTEK ---
    Log-Message "Torrentek keresése..."
    $TorrentDest = Join-Path $UserDest "Torrents_and_Data"
    $TorrentExtensions = @("*.torrent", "*.part", "*.!ut")
    foreach ($Ext in $TorrentExtensions) {
        Get-ChildItem -Path $Profile.FullName -Filter $Ext -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
            if (!(Test-Path $TorrentDest)) { New-Item -ItemType Directory -Path $TorrentDest | Out-Null }
            Copy-Item $_.FullName -Destination $TorrentDest -Force
        }
    }

    # --- KRIPTO TÁRCÁK ---
    Log-Message "Kripto tárcák keresése..."
    $CryptoDest = Join-Path $UserDest "Crypto_Wallets"
    $CryptoFiles = @("wallet.dat", "*.wallet", "*.key", "seed.txt")
    foreach ($CFile in $CryptoFiles) {
        Get-ChildItem -Path $Profile.FullName -Filter $CFile -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
            if (!(Test-Path $CryptoDest)) { New-Item -ItemType Directory -Path $CryptoDest | Out-Null }
            Copy-Item $_.FullName -Destination $CryptoDest -Force
        }
    }
}

# 6. TÖMÖRÍTÉS (Ha kérte)
if ($Config.Options.CompressAfter) {
    Log-Message "Tömörítés indítása..."
    $ZipPath = "$FullDestPath.zip"
    Compress-Archive -Path $FullDestPath -DestinationPath $ZipPath -Force
    Log-Message "Tömörítés kész: $ZipPath"
}

Log-Message "Művelet befejezve!"
Write-Host "A mentett fájlok itt találhatóak: $FullDestPath" -ForegroundColor Green
