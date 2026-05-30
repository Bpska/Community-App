$ErrorActionPreference = "Stop"
$sdkPath = "$env:LOCALAPPDATA\Android\Sdk"
$cmdlineToolsPath = "$sdkPath\cmdline-tools"

Write-Host "Creating directories..."
New-Item -Path $cmdlineToolsPath -ItemType Directory -Force | Out-Null

$zipPath = "$env:TEMP\cmdline-tools.zip"
Write-Host "Downloading command line tools (latest)..."

# Fetch the latest available URL from the repository XML
$repoUrl = "https://dl.google.com/android/repository/commandlinetools-win-13114758_latest.zip"
Invoke-WebRequest -Uri $repoUrl -OutFile $zipPath -UseBasicParsing

Write-Host "Extracting..."
Expand-Archive -Path $zipPath -DestinationPath $cmdlineToolsPath -Force

Write-Host "Renaming folder to 'latest'..."
if (Test-Path "$cmdlineToolsPath\latest") {
    Remove-Item -Path "$cmdlineToolsPath\latest" -Recurse -Force
}
Rename-Item -Path "$cmdlineToolsPath\cmdline-tools" -NewName "latest"

# Add sdkmanager to PATH for this session
$sdkManagerPath = "$cmdlineToolsPath\latest\bin"
$env:PATH = "$sdkManagerPath;$env:PATH"
$env:ANDROID_HOME = $sdkPath
$env:ANDROID_SDK_ROOT = $sdkPath

Write-Host "Accepting Android SDK licenses..."
$yes = "y`n" * 20
$yes | & "$sdkManagerPath\sdkmanager.bat" --licenses

Write-Host "Installing NDK 28.2.13676358..."
& "$sdkManagerPath\sdkmanager.bat" "ndk;28.2.13676358"

Write-Host ""
Write-Host "Done! Android SDK and NDK installed successfully."
Write-Host "NDK path: $sdkPath\ndk\28.2.13676358"
