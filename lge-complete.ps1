 $rand = Get-Random -Maximum 999
$build_s = 22631
$build_i = [System.Environment]::OSVersion.Version.Build
$user_i = [System.Environment]::UserName
$orga = 'GCE Bayreuth'

$user_1 = 'Admin'
$user_2 = 'Lehrer'
$user_3 = 'Schueler'

$WindowsAccentColorMenu = @{
    Gelbgold   = '0xff00b9ff'
    Gold       = '0xff008cff'
    Hellorange = '0xff0c63f7'
    Ziegelrot  = '0xff3834d1'
    Rot        = '0xff2311e8'
    Grasgruen  = '0xff6acc00'
}

$WindowsAccentPalette = @{
    Gelbgold   = 'fb,b4,b7,00,f3,8a,91,00,eb,5c,68,00,e7,48,56,00,e3,29,38,00,a6,16,1e,00,65,0d,0f,00,ff,8c,00,00'
    Gold       = 'ff,d1,55,00,ff,b6,34,00,ff,99,10,00,ff,8c,00,00,e3,77,00,00,a1,46,00,00,65,19,00,00,00,63,b1,00'
    Hellorange = 'fe,bd,68,00,fb,9a,44,00,f8,74,1d,00,f7,63,0c,00,e0,53,07,00,a1,31,05,00,69,12,02,00,00,99,bc,00'
    Ziegelrot  = 'f7,b1,a5,00,e8,80,7a,00,d8,4b,4c,00,d1,34,38,00,be,2b,2e,00,8d,1a,1c,00,61,09,0a,00,64,7c,64,00'
    Rot        = 'fb,9d,8b,00,f4,67,62,00,ef,27,33,00,e8,11,23,00,d2,0e,1e,00,9e,09,12,00,6f,03,06,00,69,79,7e,00'
    Grasgruen  = '5f,ff,a5,00,26,ff,8e,00,00,e7,75,00,00,cc,6a,00,00,b2,5a,00,00,76,35,00,00,3f,13,00,e3,00,8c,00'
}

$WindowsStartColorMenu = @{
    Gelbgold   = '0xff009de1'
    Gold       = '0xff0077e3'
    Hellorange = '0xff0753e0'
    Ziegelrot  = '0xff2e2bbe'
    Rot        = '0xff1e0ed2'
    Grasgruen  = '0xff5ab200'
}

###############################################################################
## Set Accent Color                                                          ##
###############################################################################

function Set-AccentColor {

    param (
        $Color # e. g. 'Grasgruen'
    )

    $RegKeyPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent'

    Set-ItemProperty -Path $RegKeyPath -Name 'AccentColorMenu' -Value $WindowsAccentColorMenu.$Color -Force
    Set-ItemProperty -Path $RegKeyPath -Name 'StartColorMenu' -Value $WindowsStartColorMenu.$Color -Force
    $hex = $WindowsAccentPalette.$Color.Split(',') | ForEach-Object { '0x$_' }
    Set-ItemProperty -Path $RegKeyPath -Name 'AccentPalette' -Value ([byte[]]$hex) -Force
    Stop-Process -ProcessName explorer -Force -ErrorAction SilentlyContinue
    Write-Host '$Color set as Accent Color.' -ForegroundColor 'Cyan'
}


###############################################################################
## Set WallPaper from URL                                                    ##
###############################################################################

function Set-WallpaperFromURL {

    param (
        $URL, # e. g. 'https://example.org/cool-pic.jpg'
        $File, # e. g. 'C:\LGE\my-wallpaper.jpg'
        $Folder # e. g. 'C:\LGE\'
    )

    $RegKeyPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP'

    $LockScreenPath = 'LockScreenImagePath'
    $LockScreenStatus = 'LockScreenImageStatus'
    $LockScreenUrl = 'LockScreenImageUrl'

    $StatusValue = '1'

    If ((Test-Path -Path $Folder) -eq $false) {
        New-Item -Path $Folder -ItemType directory
    }

    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($URL, $File)

    if (!(Test-Path $RegKeyPath)) {
        Write-Host 'Creating registry path $($RegKeyPath).'
        New-Item -Path $RegKeyPath -Force | Out-Null
    }

    New-ItemProperty -Path $RegKeyPath -Name $LockScreenStatus -Value $StatusValue -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $RegKeyPath -Name $LockScreenPath -Value $File -PropertyType STRING -Force | Out-Null
    New-ItemProperty -Path $RegKeyPath -Name $LockScreenUrl -Value $File -PropertyType STRING -Force | Out-Null
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'WallPaper' -Value $File -Force | Out-Null

    RUNDLL32.EXE USER32.DLL, UpdatePerUserSystemParameters 1, True
}


###############################################################################
## Verify right Windows Build                                                ##
###############################################################################

if ( $build_i -eq $build_s ) {
    Write-Host 'Windows Build $build_s detected.' -ForegroundColor 'Cyan'
} else {
    Write-Host 'Windows Build $build_i detected, but LGE needs to run on Windows Build $build_s.' -ForegroundColor 'Red'
    break
}

# cls
Write-Host '###########################' -ForegroundColor 'Blue'
Write-Host '#                         #' -ForegroundColor 'Blue'
Write-Host '#   _      _____ ______   #' -ForegroundColor 'Blue'
Write-Host '#  | |    / ____|  ____|  #' -ForegroundColor 'Blue'
Write-Host '#  | |   | |  __| |__     #' -ForegroundColor 'Blue'
Write-Host '#  | |   | | |_ |  __|    #' -ForegroundColor 'Blue'
Write-Host '#  | |___| |__| | |____   #' -ForegroundColor 'Blue'
Write-Host '#  |______\_____|______|  #' -ForegroundColor 'Blue'
Write-Host '#                         #' -ForegroundColor 'Blue'
Write-Host '#   2023 - GCE-Bayreuth   #' -ForegroundColor 'Blue'
Write-Host '#                         #' -ForegroundColor 'Blue'
Write-Host '###########################' -ForegroundColor 'Blue'
Write-Host ''

if ( $user_i -eq $user_1 ) {
    Write-Host '$user_1 Account detected.' -ForegroundColor 'Cyan'
    Set-WallpaperFromURL -URL 'https://raw.githubusercontent.com/2ym/lge/main/wallpaper-1.jpg' -File 'C:\LGE\WallpaperAdmin.jpg' -Folder 'C:\LGE\'
    Set-AccentColor -Color 'Ziegelrot'
    # Start-Process -Verb runas -FilePath 'C:\Users\$user_1\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Windows PowerShell\Windows PowerShell.lnk' -ArgumentList 'iwr -useb https://raw.githubusercontent.com/2ym/lge/main/ac-test.ps1 | iex'
} elseif ( $user_i -eq $user_2 ) {
    Write-Host '$user_2 Account detected.' -ForegroundColor 'Cyan'
    # Start-Process -Verb runas -FilePath 'C:\Users\$user_2\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Windows PowerShell\Windows PowerShell.lnk' -ArgumentList 'iwr -useb https://raw.githubusercontent.com/2ym/lge/main/lehrer.ps1 | iex'
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent' -Name 'AccentColorMenu' -Value $WindowsAccentColorMenu.Grasgruen -Force
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent' -Name 'StartColorMenu' -Value $WindowsStartColorMenu.Grasgruen -Force
    $hex = $WindowsAccentPalette.Grasgruen.Split(',') | ForEach-Object { '0x$_' }
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent' -Name 'AccentPalette' -Value ([byte[]]$hex) -Force
    Stop-Process -ProcessName explorer -Force -ErrorAction SilentlyContinue
    Write-Host 'Colors set.' -ForegroundColor 'Cyan'
} elseif ( $user_i -eq $user_3 ) {
    Write-Host '$user_3 Account detected.' -ForegroundColor 'Cyan'
    # Start-Process -Verb runas -FilePath 'C:\Users\$user_3\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Windows PowerShell\Windows PowerShell.lnk' -ArgumentList 'iwr -useb https://raw.githubusercontent.com/2ym/lge/main/lehrer.ps1 | iex'
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent' -Name 'AccentColorMenu' -Value $WindowsAccentColorMenu.Hellorange -Force
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent' -Name 'StartColorMenu' -Value $WindowsStartColorMenu.Hellorange -Force
    $hex = $WindowsAccentPalette.Hellorange.Split(',') | ForEach-Object { '0x$_' }
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent' -Name 'AccentPalette' -Value ([byte[]]$hex) -Force
    Stop-Process -ProcessName explorer -Force -ErrorAction SilentlyContinue
    Write-Host 'Colors set.' -ForegroundColor 'Cyan'
} else {
    Write-Host 'No valid Account Name detected.' -ForegroundColor 'Red'
    break
}

Start-Transcript $ENV:TEMP\lge$rand.log -Append
(Get-WmiObject Win32_ComputerSystem).Rename('Placeholder') | Out-Null

###############################################################################
## Removing Default Windows Applications                                     ##
###############################################################################

Write-Host 'Removing Default Windows Applications...' -ForegroundColor 'Cyan'

# Uninstall 3D Builder
Get-AppxPackage 'Microsoft.3DBuilder' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'Microsoft.3DBuilder' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Adobe Creative Cloud Express
Get-AppxPackage 'AdobeSystemsIncorporated.AdobeCreativeCloudExpress' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'AdobeSystemsIncorporated.AdobeCreativeCloudExpress' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Alarms and Clock
Get-AppxPackage 'Microsoft.WindowsAlarms' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'Microsoft.WindowsAlarms' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Amazon Prime Video
Get-AppxPackage 'AmazonVideo.PrimeVideo' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'AmazonVideo.PrimeVideo' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Autodesk Sketchbook
Get-AppxPackage '*.AutodeskSketchBook' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like '*.AutodeskSketchBook' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Bing Finance
Get-AppxPackage 'Microsoft.BingFinance' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'Microsoft.BingFinance' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Bing News
Get-AppxPackage 'Microsoft.BingNews' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'Microsoft.BingNews' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Bing Sports
Get-AppxPackage 'Microsoft.BingSports' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'Microsoft.BingSports' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Bing Weather
Get-AppxPackage 'Microsoft.BingWeather' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'Microsoft.BingWeather' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Bubble Witch 3 Saga
Get-AppxPackage 'king.com.BubbleWitch3Saga' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'king.com.BubbleWitch3Saga' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Calendar and Mail
Get-AppxPackage 'Microsoft.WindowsCommunicationsApps' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'Microsoft.WindowsCommunicationsApps' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Candy Crush Soda Saga
Get-AppxPackage 'king.com.CandyCrushSodaSaga' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'king.com.CandyCrushSodaSaga' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall ClipChamp Video Editor
Get-AppxPackage 'Clipchamp.Clipchamp' -AllUsers | Remove-AppxPackage
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'Clipchamp.Clipchamp' | Remove-AppxProvisionedPackage -Online

# Uninstall Cortana
Get-AppxPackage 'Microsoft.549981C3F5F10' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'Microsoft.549981C3F5F10' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Disney+
Get-AppxPackage 'Disney.37853FC22B2CE' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'Disney.37853FC22B2CE' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Disney Magic Kingdoms
Get-AppxPackage '*.DisneyMagicKingdoms' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like '*.DisneyMagicKingdoms' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Dolby
Get-AppxPackage 'DolbyLaboratories.DolbyAccess' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'DolbyLaboratories.DolbyAccess' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Facebook
Get-AppxPackage 'Facebook.Facebook*' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'Facebook.Facebook*' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Get Office, and it's 'Get Office365' notifications
Get-AppxPackage 'Microsoft.MicrosoftOfficeHub' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'Microsoft.MicrosoftOfficeHub' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Instagram
Get-AppxPackage 'Facebook.Instagram*' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'Facebook.Instagram*' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Maps
Get-AppxPackage 'Microsoft.WindowsMaps' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'Microsoft.WindowsMaps' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall March of Empires
Get-AppxPackage '*.MarchofEmpires' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like '*.MarchofEmpires' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Messaging
Get-AppxPackage 'Microsoft.Messaging' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'Microsoft.Messaging' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Mobile Plans
Get-AppxPackage 'Microsoft.OneConnect' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'Microsoft.OneConnect' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall OneNote
Get-AppxPackage 'Microsoft.Office.OneNote' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'Microsoft.Office.OneNote' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Paint
Get-AppxPackage 'Microsoft.Paint' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'Microsoft.Paint' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall People
Get-AppxPackage 'Microsoft.People' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'Microsoft.People' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Photos
# Get-AppxPackage 'Microsoft.Windows.Photos' -AllUsers | Remove-AppxPackage -AllUsers
# Get-AppXProvisionedPackage -Online | Where DisplayName -like 'Microsoft.Windows.Photos' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Print3D
Get-AppxPackage 'Microsoft.Print3D' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'Microsoft.Print3D' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Skype
Get-AppxPackage 'Microsoft.SkypeApp' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'Microsoft.SkypeApp' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall SlingTV
Get-AppxPackage '*.SlingTV' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like '*.SlingTV' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Solitaire
Get-AppxPackage 'Microsoft.MicrosoftSolitaireCollection' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'Microsoft.MicrosoftSolitaireCollection' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Spotify
Get-AppxPackage 'SpotifyAB.SpotifyMusic' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'SpotifyAB.SpotifyMusic' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall StickyNotes
Get-AppxPackage 'Microsoft.MicrosoftStickyNotes' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'Microsoft.MicrosoftStickyNotes' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Sway
Get-AppxPackage 'Microsoft.Office.Sway' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'Microsoft.Office.Sway' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall TikTok
Get-AppxPackage '*.TikTok' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like '*.TikTok' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Microsoft ToDos
Get-AppxPackage 'Microsoft.ToDos' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'Microsoft.ToDos' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Twitter
Get-AppxPackage '*.Twitter' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like '*.Twitter' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Voice Recorder
Get-AppxPackage 'Microsoft.WindowsSoundRecorder' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'Microsoft.WindowsSoundRecorder' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall XBox
Get-AppxPackage 'Microsoft.XboxGamingOverlay' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppxPackage 'Microsoft.GamingApp' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'Microsoft.XboxGamingOverlay' | Remove-AppxProvisionedPackage -Online -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'Microsoft.GamingApp' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Your Phone
Get-AppxPackage 'Microsoft.YourPhone' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'Microsoft.YourPhone' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Zune Music (Groove)
Get-AppxPackage 'Microsoft.ZuneMusic' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'Microsoft.ZuneMusic' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Zune Video
Get-AppxPackage 'Microsoft.ZuneVideo' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'Microsoft.ZuneVideo' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Windows Media Player
Disable-WindowsOptionalFeature -Online -FeatureName 'WindowsMediaPlayer' -NoRestart -WarningAction SilentlyContinue | Out-Null

# Uninstall Microsoft Teams (Personal Edition)
Get-AppxPackage 'MicrosoftTeams' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'MicrosoftTeams' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Feedback Hub
Get-AppxPackage 'Microsoft.WindowsFeedbackHub' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'Microsoft.WindowsFeedbackHub' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Get Started / Tips
Get-AppxPackage 'Microsoft.Getstarted' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'Microsoft.Getstarted' | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Quick Assist (Remotehilfe)
Get-AppxPackage 'MicrosoftCorporationII.QuickAssist' -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like 'MicrosoftCorporationII.QuickAssist' | Remove-AppxProvisionedPackage -Online -AllUsers



###############################################################################
## Setting Custom Registry Keys                                              ##
###############################################################################

Write-Host 'Setting Custom Registry Keys...' -ForegroundColor 'Cyan'

# Registry Key Dark Mode System
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' 'SystemUsesLightTheme' 0

# Registry Key Dark Mode Apps
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' 'AppsUseLightTheme' 0

# Registry Key Disable Bing Search
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' 'BingSearchEnabled' 0

# Registry Key Task Bar Hide Search
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' 'SearchboxTaskbarMode' 0

# Registry Key Task Bar Hide Chat
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'TaskbarMn' 0

# Registry Key Task Bar Hide Task View
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowTaskViewButton' 0

# Registry Key Task Bar Hide Widgets
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'TaskbarDa' 0

# Registry Key Task Bar Left
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'TaskbarAl' 0

# Registry Key Explorer Show File Extensions
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'HideFileExt' 0

# Registry Key Control Panel Icon Size
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel' 'AllItemsIconView' 0

# Registry Control Panel View
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel' 'StartupPage' 1

Read-Host -Prompt 'Press Enter to exit'
