# Define paths to main "special" user folders
$desktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)
$documentsPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::MyDocuments)
$picturesPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::MyPictures)
$musicPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::MyMusic)
$videosPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::MyVideos)

# Define the global variable for error message color
$ErrorColour = "Red"
$PassColour = "Green"

# Function to check if a file exists and return its path
function Test-OneDrivePath {
    param (
        [string]$Path
    )
    return (Test-Path $Path)
}

# Common OneDrive installation paths
$OneDrivePaths = @(
    "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe",
    "$env:PROGRAMFILES\Microsoft OneDrive\OneDrive.exe",
    "$env:PROGRAMFILES(X86)\Microsoft OneDrive\OneDrive.exe"
)

# Check if OneDrive is installed
$OneDrivePath = $null
foreach ($path in $OneDrivePaths) {
    if (Test-OneDrivePath $path) {
        $OneDrivePath = $path
        break
    }
}

if (-Not $OneDrivePath) {
    Write-Host "OneDrive is not installed on this system." -ForegroundColor $ErrorColour
    Read-Host -Prompt "Press Enter to exit"
    Exit 1
}

Write-Host "OneDrive is installed at $OneDrivePath." -ForegroundColor $PassColour

# Ensure OneDrive is running
$OneDriveProcess = Get-Process -Name OneDrive -ErrorAction SilentlyContinue
if (-Not $OneDriveProcess) {
    Write-Host "OneDrive is not running. Starting OneDrive..." -ForegroundColor $ErrorColour
    try {
        Start-Process $OneDrivePath
        Start-Sleep -Seconds 10
    }
    catch {
        Write-Host "Failed to start OneDrive: $_" -ForegroundColor $ErrorColour
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }

    $OneDriveProcess = Get-Process -Name OneDrive -ErrorAction SilentlyContinue
    if (-Not $OneDriveProcess) {
        Write-Host "Failed to start OneDrive." -ForegroundColor $ErrorColour
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
}

Write-Host "OneDrive is running." -ForegroundColor $PassColour

# Check if user is logged into OneDrive
$OneDriveUserFolder = [System.IO.Path]::Combine($env:USERPROFILE, "OneDrive")
if (-Not (Test-Path $OneDriveUserFolder)) {
    Write-Host "User is not logged into OneDrive. Please log in." -ForegroundColor $ErrorColour
    Read-Host -Prompt "Press Enter to exit"
    Exit 1
}

Write-Host "User is logged into OneDrive." -ForegroundColor $PassColour

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

# Output the paths with success or error messages
Check-FolderPath -Path $desktopPath -FolderName "Desktop"
Check-FolderPath -Path $documentsPath -FolderName "Documents"
Check-FolderPath -Path $picturesPath -FolderName "Pictures"
Check-FolderPath -Path $musicPath -FolderName "Music"
Check-FolderPath -Path $videosPath -FolderName "Videos"

# Wait for user to press Enter before closing the terminal
Read-Host -Prompt "Press Enter to exit"
