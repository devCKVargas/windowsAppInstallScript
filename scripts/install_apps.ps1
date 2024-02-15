function Request-Admin {
    param (
        [scriptblock]$ScriptBlock
    )

    $params = @{
        FilePath = 'pwsh.exe'
        Verb = 'RunAs'
        Wait = $true
    }

    if ($ScriptBlock) {
        $params['ArgumentList'] = "-ExecutionPolicy Bypass -Command & {$ScriptBlock}"
    }

    try {
        Start-Process @params -ErrorAction Stop
    }
    catch {
        if ($_.Exception.Message -match 'The operation was canceled by the user') {
            Write-Host -ForegroundColor Yellow "Admin request denied. Exiting gracefully."
        }
        else {
            throw $_  # Re-throw the exception if it's not a user cancellation
        }
    }
	}
	

#  # Winget (Slow download fix)
#  # open settings using $ winget settings
$confWinget = '.\conf\winget\*'
Write-Host "
█░█░█ █ █▄░█ █▀▀ █▀▀ ▀█▀   █▀▀ █ ▀▄▀
▀▄▀▄▀ █ █░▀█ █▄█ ██▄ ░█░   █▀░ █ █░█
Set wininet as network downloader "
Copy-Item -Recurse -Force -Path $confWinget ~\Appdata\Local\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\

# ===============================================================
$hasOverride = Read-Host -Prompt "Enable Installer Hash Override? (Y/n)"
if (-not $hasOverride) { $hasOverride = 'Y' }

if ($hasOverride -eq 'Y' -or $hasOverride -eq 'y') {
	Request-Admin -ScriptBlock {
	winget settings --enable InstallerHashOverride
	Write-Host -ForegroundColor Green "Hash Override Enabled!"
	}
} else {
    Write-Host -ForegroundColor Yellow "Denied."
}

Write-Host "
█▀▀ █░█ █▀█ █▀▀ █▀█ █░░ ▄▀█ ▀█▀ █▀▀ █▄█
█▄▄ █▀█ █▄█ █▄▄ █▄█ █▄▄ █▀█ ░█░ ██▄ ░█░
Installing chocolatey "

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# ===============================================================
$updateChoco = Read-Host -Prompt "Update installed apps? (Y/n)"
if (-not $updateChoco) { $updateChoco = 'Y' }

if ($updateChoco -eq 'Y' -or $updateChoco -eq 'y') {
	Request-Admin -ScriptBlock {
	Write-Host "
	+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+
	|U|p|d|a|t|i|n|g| |c|h|o|c|o|l|a|t|e|y| |a|p|p|s|
	+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+ "
		choco upgrade all -y
	}
} else {
	Write-Host -ForegroundColor Yellow "Skipping updates."
}
	
# ===============================================================
$installChoco = Read-Host -Prompt "Install choco apps? (Y/n)"
if (-not $installChoco) { $installChoco = 'Y' }

if ($installChoco -eq 'Y' -or $installChoco -eq 'y') {
	# Run Chocolatey as admin
	Request-Admin -ScriptBlock {
	Write-Host "
	+-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+
	|I|n|s|t|a|l|l|i|n|g| |c|h|o|c|o|l|a|t|e|y| |a|p|p|s|
	+-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+ "
		
	choco install -y "winget" "traffic-monitor" "nerd-fonts-jetbrainsMono" "nerd-fonts-arimo" "nerd-fonts-meslo" "winfetch" "openal" "nilesoft-shell" "amd-ryzen-chipset" "imagemagick" "realtek-hd-audio-driver" "spicetify-marketplace"
		
	Write-Host -Foreground Green "
	+-+-+-+-+-+
	|D|o|n|e|!|
	+-+-+-+-+-+ "
	}
} else {
	Write-Host -ForegroundColor Yellow "Skipping apps."
}
	
# ===============================================================
$clearChocoCache = Read-Host -Prompt "Clear cache? (Y/n)"
if (-not $clearChocoCache) { $clearChocoCache = 'Y' }

if ($clearChocoCache -eq 'Y' -or $clearChocoCache -eq 'y') {
	Request-Admin -ScriptBlock {
	choco cache remove -y
	Write-Host -Foreground Green "
	+-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+ +-+-+-+-+-+-+-+
	|C|h|o|c|o|l|a|t|e|y| |c|a|c|h|e| |c|l|e|a|r|e|d|
	+-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+ +-+-+-+-+-+-+-+ "
	}
} else {
	Write-Host -Foreground Yellow "Cache not cleared."
}

Write-Host "
█░█░█ █ █▄░█ █▀▀ █▀▀ ▀█▀
▀▄▀▄▀ █ █░▀█ █▄█ ██▄ ░█░"

$updateWinget = Read-Host -Prompt "Update installed apps? (Y/n)"
if (-not $updateWinget) { $updateWinget = 'Y' }

if ($updateWinget -eq 'Y' -or $updateWinget -eq 'y') {
	Write-Host "
	+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+
	|U|p|d|a|t|i|n|g| |w|i|n|g|e|t| |a|p|p|s|
	+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+ "
	winget update --all --accept-source-agreements --accept-package-agreements -h --disable-interactivity ## --silent | -h

} else {
	Write-Host -ForegroundColor Yellow "Skipping updates."
}

# █▀▄ █▀▀ █░█ # --source -s 
# █▄▀ ██▄ ▀▄▀ # (winget,msstore)
$installWingetAppsDev = Read-Host -Prompt "Install Dev apps? (Y/n)"
if (-not $installWingetAppsDev) { $installWingetAppsDev = 'Y' }

if ($installWingetAppsDev -eq 'Y' -or $installWingetAppsDev -eq 'y') {
	Write-Host "
	+-+-+-+-+-+-+-+-+-+-+ +-+-+-+ +-+-+-+-+
	|I|n|s|t|a|l|l|i|n|g| |d|e|v| |a|p|p|s|
	+-+-+-+-+-+-+-+-+-+-+ +-+-+-+ +-+-+-+-+ "
	
	winget install "Git.Git" "GitHub.cli" "GitHub.GitHubDesktop" "JesseDuffield.lazygit" "OpenJS.NodeJS" "Microsoft.WindowsTerminal" "Microsoft.PowerShell" "Microsoft.VisualStudioCode" "Figma.Figma" "ResponsivelyApp.ResponsivelyApp" "BurntSushi.ripgrep.MSVC" "JanDeDobbeleer.OhMyPosh" "AdrienAllard.FileConverter" "Google.PlatformTools" "ajeetdsouza.zoxide" "junegunn.fzf" -s winget --accept-package-agreements --accept-source-agreements -h
	
	Write-Host -Foreground Green "
	+-+-+-+-+-+
	|D|o|n|e|!|
	+-+-+-+-+-+ "

} else {
	Write-Host -ForegroundColor Yellow "Skipping Dev apps."
}

# ▄▀█ █▀█ █▀█ █▀ # Winget
# █▀█ █▀▀ █▀▀ ▄█ # Source: Winget 
$installWingetApps = Read-Host -Prompt "Install apps? (Y/n)"
if (-not $installWingetApps) { $updateChoco = 'Y' }

if ($installWingetApps -eq 'Y' -or $installWingetApps -eq 'y') {
	Write-Host "
	+-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+
	|I|n|s|t|a|l|l|i|n|g| |w|i|n|g|e|t| |a|p|p|s|
	+-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+ +-+-+-+-+ "

	winget install "nvcleanstall" "powertoys" "AltSnap" "caprine" "discord" "telegram" "megasync" "fdm" "canva" "ahk" "k-lite mega codec pack" "obs studio" "VLC media player" "winrar" "anydesk" "gpu-z" "f.lux" "afterburner" "superf4" "wingetUI" "oracle.JDK.18" "7-zip" "Microsoft XNA Framework Redistributable Refresh" "CPUID CPU-Z" "sharex" "ookla.speedtest.CLI" "spotify.spotify" "spicetify.spicetify" "Appest.TickTick" "NextDNS.NextDNS.Desktop" "capcut" "qbittorrent.qbittorrent" "th-ch.YouTubeMusic" "IObit.IObitUnlocker" "Microsoft.DotNet.DesktopRuntime.3_1" "Microsoft.DotNet.DesktopRuntime.5" "Microsoft.DotNet.DesktopRuntime.6" "Microsoft.DotNet.DesktopRuntime.7" "Microsoft.DotNet.DesktopRuntime.8" "abbodi1406.vcredist" "univrsal.tuna" -s winget --accept-package-agreements --accept-source-agreements -h

	Write-Host -Foreground Green "
	+-+-+-+-+-+
	|D|o|n|e|!|
	+-+-+-+-+-+ "

} else {
	Write-Host -ForegroundColor Yellow "Skipping apps."
}

# █░█ █░█░█ █▀█   ▄▀█ █▀█ █▀█ █▀ # Winget
# █▄█ ▀▄▀▄▀ █▀▀   █▀█ █▀▀ █▀▀ ▄█ # source: msstore
$installWingetAppsUWP = Read-Host -Prompt "Install MS apps? (Y/n)"
if (-not $installWingetAppsUWP) { $installWingetAppsUWP = 'Y' }

if ($installWingetAppsUWP -eq 'Y' -or $installWingetAppsUWP -eq 'y') {
	Write-Host "
	+-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+ +-+-+-+-+
	|I|n|s|t|a|l|l|i|n|g| |M|S|S|t|o|r|e| |a|p|p|s|
	+-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+ +-+-+-+-+ "

	winget install "eartrumpet" "Microsoft To Do" "KDE Connect" "Messenger" -s msstore --accept-package-agreements --accept-source-agreements -h

	Write-Host -Foreground Green "
	+-+-+-+-+-+
	|D|o|n|e|!|
	+-+-+-+-+-+ "

} else {
	Write-Host -ForegroundColor Yellow "Skipping Microsoft apps."
}


Write-Host "
█▀█ █▀▀ █▀ ▀█▀ █▀█ █▀█ █▀▀   █▀▀ █▀█ █▄░█ █▀▀
█▀▄ ██▄ ▄█ ░█░ █▄█ █▀▄ ██▄   █▄▄ █▄█ █░▀█ █▀░"
$restoreConf = Read-Host -Prompt "Finishing setup. Would you like to restore available configurations? (Y/n)"
if (-not $restoreConf) { $restoreConf = 'Y' }

if ($restoreConf -eq 'Y' -or $restoreConf -eq 'y') {
	Write-Host -ForegroundColor Blue " 🔧 Restoring configs..."
	..\windows\scripts\restore_conf.ps1

	Write-Host -ForegroundColor Green "Setup done!"
} else {
	Write-Host -ForegroundColor Yellow "Skipping configs."
	Write-Host -ForegroundColor Green "Setup done!"
}

