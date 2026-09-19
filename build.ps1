# Keep this script ASCII-only: Windows PowerShell 5.1 otherwise reads a
# UTF-8-without-BOM script through the active ANSI code page.
$ErrorActionPreference = "Stop"

$project = Join-Path $PSScriptRoot "LcpControlOnly.csproj"
$output = Join-Path $PSScriptRoot "release\LCP-Control-Only"
$zip = Join-Path $PSScriptRoot "release\LCP-Control-Only-win-x64.zip"

if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
    throw "dotnet SDK was not found. Install .NET SDK 8 or a newer version, then try again."
}

if (Test-Path $output) {
    Remove-Item $output -Recurse -Force
}
if (Test-Path $zip) {
    Remove-Item $zip -Force
}

dotnet publish $project --configuration Release --output $output
if ($LASTEXITCODE -ne 0) {
    throw "dotnet publish failed with exit code $LASTEXITCODE."
}

Compress-Archive -Path (Join-Path $output "*") -DestinationPath $zip -Force

Write-Host "Build output: $output"
Write-Host "Distribution ZIP: $zip"
