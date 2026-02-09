# --- CONFIGURATION (Change these paths) ---
$SourceFolder = Read-Host "Enter the full path of the Source folder"
$DestFolder = Read-Host "Enter the full path of the Destination folder"

$TempFolder = "Z:\TempExtract"

# Create folders if they don't exist
if (!(Test-Path $DestFolder)) { New-Item -ItemType Directory -Path $DestFolder }
if (!(Test-Path $TempFolder)) { New-Item -ItemType Directory -Path $TempFolder }

Write-Host "Step 1: Processing ZIP files..." -ForegroundColor Cyan
Get-ChildItem -Path $SourceFolder -Filter *.zip -Recurse | ForEach-Object {
    Write-Host "Extracting: $($_.Name)"
    Expand-Archive -Path $_.FullName -DestinationPath $TempFolder -Force
    Get-ChildItem -Path $TempFolder -Filter *.jpg -Recurse | Move-Item -Destination $DestFolder -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$TempFolder\*" -Recurse -Force
}

Write-Host "Step 2: Copying loose JPG files..." -ForegroundColor Cyan
Get-ChildItem -Path $SourceFolder -Filter *.jpg -Recurse | Copy-Item -Destination $DestFolder -Force

# Cleanup
Remove-Item -Path $TempFolder -Recurse -Force
Write-Host "Task Complete! All photos moved to $DestFolder" -ForegroundColor Green
Pause