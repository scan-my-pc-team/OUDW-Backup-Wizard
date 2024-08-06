# Define the special folder names
$folderNames = @("Desktop", "MyDocuments", "MyPictures", "MyMusic", "MyVideos")

# Create an empty hashtable to store the folder paths
$specialFolders = @{}

# Populate the hashtable using a loop
foreach ($folderName in $folderNames) {
    $specialFolders[$folderName] = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::$folderName)
}

# Map friendly names to the folder keys
$folderFriendlyNames = @{
    "Desktop"   = "Desktop"
    "MyDocuments" = "Documents"
    "MyPictures"  = "Pictures"
    "MyMusic"     = "Music"
    "MyVideos"    = "Videos"
}

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

# Function to check if OneDrive is installed and return its path
function Get-OneDrivePath {
    $OneDrivePaths = @(
        "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe",
        "$env:PROGRAMFILES\Microsoft OneDrive\OneDrive.exe",
        "$env:PROGRAMFILES(X86)\Microsoft OneDrive\OneDrive.exe"
    )
    return $OneDrivePaths | Where-Object { Test-OneDrivePath $_ }
}

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
}

# Function to check if the user is logged into OneDrive
function Check-OneDriveUserLogin {
    $OneDriveUserFolder = [System.IO.Path]::Combine($env:USERPROFILE, "OneDrive")
    if (-Not (Test-Path $OneDriveUserFolder)) {
        Write-Host "User is not logged into OneDrive. Please log in." -ForegroundColor $ErrorColour
        Read-Host -Prompt "Press Enter to exit"
        Exit 1
    }
    Write-Host "User is logged into OneDrive." -ForegroundColor $PassColour
}

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

# Check OneDrive installation, running status, and user login
$OneDrivePath = Get-OneDrivePath
if (-Not $OneDrivePath) {
    Write-Host "OneDrive is not installed on this system." -ForegroundColor $ErrorColour
    Read-Host -Prompt "Press Enter to exit"
    Exit 1
}
Write-Host "OneDrive is installed at $OneDrivePath." -ForegroundColor $PassColour

Ensure-OneDriveRunning -OneDrivePath $OneDrivePath
Check-OneDriveUserLogin

# Output the paths with success or error messages
foreach ($folder in $specialFolders.GetEnumerator()) {
    $friendlyName = $folderFriendlyNames[$folder.Key]
    Check-FolderPath -Path $folder.Value -FolderName $friendlyName
}

# Wait for user to press Enter before closing the terminal
Read-Host -Prompt "Press Enter to exit"
