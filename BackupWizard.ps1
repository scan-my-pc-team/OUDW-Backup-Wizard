# ASCII art and GitHub information
$asciiArt = @"

==========================================================================================================
=      ==================  =============================  ====  ====  =================================  =
=  ===  =================  =============================  ====  ====  =================================  =
=  ====  ================  =============================  ====  ====  =================================  =
=  ===  ====   ====   ===  =  ==  =  ==    =============  ====  ====  ==  ==      ===   ===  =   ======  =
=      ====  =  ==  =  ==    ===  =  ==  =  ==        ==   ==    ==  ===========  ==  =  ==    =  ===    =
=  ===  ======  ==  =====   ====  =  ==  =  =============  ==    ==  ===  =====  ======  ==  =======  =  =
=  ====  ===    ==  =====    ===  =  ==    ==============  ==    ==  ===  ====  =====    ==  =======  =  =
=  ===  ===  =  ==  =  ==  =  ==  =  ==  =================    ==    ====  ===  =====  =  ==  =======  =  =
=      =====    ===   ===  =  ===    ==  ==================  ====  =====  ==      ===    ==  ========    =
==========================================================================================================
"@

$githubText = @"

    GitHub: DeadDove13
    GitHub: ArtemKech
"@

# Define the global variable for error message color
$ErrorColour = "Red"
$PassColour = "Green"
$ExitMessage = "Press Enter to exit"

# Display ASCII art and GitHub information
Write-Host $asciiArt -ForegroundColor Blue
Write-Host $githubText -ForegroundColor White

# Description of the script
$description = @"

This script performs the following tasks:
1. Checks if OneDrive is installed and running.
2. Verifies if the user is logged into OneDrive.
3. Displays the paths to important user folders (Desktop, Documents, Pictures, Music, and Videos).
Please follow the prompts to execute the desired actions.

"@

Write-Host $description -ForegroundColor Yellow

# Define the Main function
function Main {
    Write-Host "Starting Main function..."

    # Define the special folder names
    $folderNames = @("Desktop", "MyDocuments", "MyPictures", "MyMusic", "MyVideos")

    Write-Host "Folder names defined."

    # Create an empty hashtable to store the folder paths
    $specialFolders = @{}

    Write-Host "Hashtable initialized."

    # Populate the hashtable using a loop
    foreach ($folderName in $folderNames) {
        $specialFolders[$folderName] = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::$folderName)
    }

    Write-Host "Hashtable populated."

    # Map friendly names to the folder keys
    $folderFriendlyNames = @{
        "Desktop"   = "Desktop"
        "MyDocuments" = "Documents"
        "MyPictures"  = "Pictures"
        "MyMusic"     = "Music"
        "MyVideos"    = "Videos"
    }

    Write-Host "Friendly names mapped."

    # Function to check if a file exists and return its path
    function Test-OneDrivePath {
        param (
            [string]$Path
        )
        return (Test-Path $Path)
    }

    Write-Host "Test-OneDrivePath function defined."

    # Function to check if OneDrive is installed and return its path
    function Get-OneDrivePath {
        $OneDrivePaths = @(
            "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe",
            "$env:PROGRAMFILES\Microsoft OneDrive\OneDrive.exe",
            "$env:PROGRAMFILES(X86)\Microsoft OneDrive\OneDrive.exe"
        )
        return $OneDrivePaths | Where-Object { Test-OneDrivePath $_ }
    }

    Write-Host "Get-OneDrivePath function defined."

    # Function to ensure OneDrive is running
    function Ensure-OneDriveRunning {
        param (
            [string]$OneDrivePath
        )
        $OneDriveProcess = Get-Process -Name OneDrive -ErrorAction SilentlyContinue
        if (-Not $OneDriveProcess) {
            Write-Host "OneDrive is not running. Starting OneDrive..." -ForegroundColor $ErrorColour
            try {
                Start-Process $OneDrivePath
                Start-Sleep -Seconds 10
            }
            catch {
                Write-Host "Failed to start OneDrive: $_" -ForegroundColor $ErrorColour
                Read-Host -Prompt $ExitMessage
                Exit 1
            }

            $OneDriveProcess = Get-Process -Name OneDrive -ErrorAction SilentlyContinue
            if (-Not $OneDriveProcess) {
                Write-Host "Failed to start OneDrive." -ForegroundColor $ErrorColour
                Read-Host -Prompt $ExitMessage
                Exit 1
            }
        }
        Write-Host "OneDrive is running." -ForegroundColor $PassColour
    }

    Write-Host "Ensure-OneDriveRunning function defined."

    # Function to check if the user is logged into OneDrive
    function Check-OneDriveUserLogin {
        $OneDriveUserFolder = [System.IO.Path]::Combine($env:USERPROFILE, "OneDrive")
        if (-Not (Test-Path $OneDriveUserFolder)) {
            Write-Host "User is not logged into OneDrive. Please log in." -ForegroundColor $ErrorColour
            Read-Host -Prompt $ExitMessage
            Exit 1
        }
        Write-Host "User is logged into OneDrive." -ForegroundColor $PassColour
    }

    Write-Host "Check-OneDriveUserLogin function defined."

    # Function to check and print the status of a folder path
    function Check-FolderPath {
        param (
            [string]$Path,
            [string]$FolderName
        )
        if (-not [string]::IsNullOrEmpty($Path) -and (Test-Path $Path)) {
            Write-Host "$FolderName Path: $Path" -ForegroundColor $PassColour
        }
        else {
            Write-Host "$FolderName Path not found or invalid: $Path" -ForegroundColor $ErrorColour
        }
    }

    Write-Host "Check-FolderPath function defined."

    # Function to create the PCScan folder on the Desktop
    function Create-PCScanFolder {
        param (
            [hashtable]$specialFolders
        )
        $desktopPath = $specialFolders["Desktop"]
        $pcScanFolderPath = $desktopPath + "\PCScan"
        if (-not (Test-Path $pcScanFolderPath)) {
            $null = New-Item -ItemType Directory -Path $pcScanFolderPath -Force
        }
        return $pcScanFolderPath
    }

    Write-Host "Create-PCScanFolder function defined."

    # Function to export Chrome or Edge user profile
    function Export-BrowserProfile {
        param (
            [string]$browserType, # Type of browser (Chrome or Edge)
            [string]$browserName,
            [string]$pcScanFolderPath
        )

        $profilePath = "$env:LOCALAPPDATA\$browserType\User Data\Default"
        $outputProfilePath = $pcScanFolderPath + "\" + $browserName + "_Profile"

        Write-Output "`nChecking for $browserType profile at path: $profilePath"

        # Check if the profile directory exists and copy it to the PCScan folder
        if (Test-Path $profilePath) {
            try {
                Copy-Item -Path $profilePath -Destination $outputProfilePath -Recurse -ErrorAction Stop
                Write-Host "`n$browserName profile has been copied to the PCScan folder" -ForegroundColor $PassColour
            }
            catch {
                Write-Host "`nError copying $browserName profile: $_" -ForegroundColor $ErrorColour
            }
        }
        else {
            Write-Host "`n$browserName profile not found at path: $profilePath" -ForegroundColor $ErrorColour
        }
    }

    Write-Host "Export-BrowserProfile function defined."

    # Function to export Firefox profile
    function Export-FirefoxProfile {
        param (
            [string]$pcScanFolderPath
        )

        $firefoxProfilesPath = "$env:APPDATA\Mozilla\Firefox\Profiles"
        Write-Output "`nChecking for Firefox profiles at path: $firefoxProfilesPath"

        $profiles = Get-ChildItem -Path $firefoxProfilesPath -Directory

        if ($profiles.Count -eq 0) {
            Write-Host "`nNo Firefox profiles found." -ForegroundColor $ErrorColour
            return
        }

        foreach ($profile in $profiles) {
            $profilePath = $profile.FullName
            Write-Output "`nChecking profile at path: $profilePath"
            if (Test-Path "$profilePath\places.sqlite") {
                $outputFirefoxProfile = "$pcScanFolderPath\Firefox_Profile"
                try {
                    Write-Output "`nCopying Firefox profile from path: $profilePath"
                    Copy-Item -Path $profilePath -Destination $outputFirefoxProfile -Recurse -ErrorAction Stop
                    Write-Host "`nFirefox profile has been copied to the PCScan folder at $outputFirefoxProfile" -ForegroundColor $PassColour
                    return
                }
                catch {
                    Write-Host "`nError copying Firefox profile: $_" -ForegroundColor $ErrorColour
                }
            }
        }

        Write-Host "`nNo valid Firefox profile found with places.sqlite`n" -ForegroundColor $ErrorColour
    }

    Write-Host "Export-FirefoxProfile function defined."

    # Function to display folder paths
    function Display-FolderPaths {
        param (
            [hashtable]$specialFolders,
            [hashtable]$folderFriendlyNames
        )

        foreach ($folderName in $specialFolders.Keys) {
            Check-FolderPath -Path $specialFolders[$folderName] -FolderName $folderFriendlyNames[$folderName]
        }
    }

    Write-Host "Display-FolderPaths function defined."

    # Function to prompt user for export choice
    function Prompt-UserExportChoice {
    do {
        Write-Host "`nDo you want to export your browser profiles?"
        $userChoice = Read-Host "Press 1 to export profiles or 0 to close"

        if ($userChoice -eq "1" -or $userChoice -eq "0") {
            return $userChoice
        }
        else {
            Write-Host "B R U H!!! Invalid input. Please try again." -ForegroundColor $ErrorColour
        }
    } while ($true)
}

    Write-Host "Prompt-UserExportChoice function defined."

    # Check if OneDrive is installed
    $OneDrivePath = Get-OneDrivePath
    if (-not $OneDrivePath) {
        Write-Host "OneDrive is not installed." -ForegroundColor $ErrorColour
        Read-Host -Prompt $ExitMessage
        Exit 1
    }
    Write-Host "OneDrive is installed at: $OneDrivePath" -ForegroundColor $PassColour

    # Ensure OneDrive is running
    Ensure-OneDriveRunning -OneDrivePath $OneDrivePath

    # Check if the user is logged into OneDrive
    Check-OneDriveUserLogin

    # Display the paths to important user folders
    Display-FolderPaths -specialFolders $specialFolders -folderFriendlyNames $folderFriendlyNames

    # Prompt the user to select whether to export all profiles
    $userChoice = Prompt-UserExportChoice

    # Perform the export based on user choice
    if ($userChoice -eq "1") {
        $pcScanFolderPath = Create-PCScanFolder -specialFolders $specialFolders
        Export-BrowserProfile -browserType 'Google\Chrome' -browserName 'Chrome' -pcScanFolderPath $pcScanFolderPath
        Export-BrowserProfile -browserType 'Microsoft\Edge' -browserName 'Edge' -pcScanFolderPath $pcScanFolderPath
        Export-FirefoxProfile -pcScanFolderPath $pcScanFolderPath
    }
    elseif ($userChoice -eq "0") {
        Write-Output "`nNo browser profiles will be exported."
    }
    else {
        Write-Host "`nInvalid choice. Please run the script again and select a valid option." -ForegroundColor $ErrorColour
    }

    # Wait for user to press Enter before closing the terminal
    Read-Host -Prompt $ExitMessage
}

# Prompt the user to press 1 to run the script or 0 to close
do {
    $choice = Read-Host "Press 1 to run the script or 0 to close"

    # Execute based on user's choice
    if ($choice -eq "1") {
        Main
        break
    } elseif ($choice -eq "0") {
        Write-Host "Exiting the script." -ForegroundColor White
        Exit
    } else {
        Write-Host "B R U H!!! Invalid input. Please try again." -ForegroundColor $ErrorColour
    }
} while ($true)
