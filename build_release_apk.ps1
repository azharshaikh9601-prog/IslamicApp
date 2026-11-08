# PowerShell Local Android Release Build Script for IslamicApp
# Bypasses Windows non-ASCII OneDrive path limitations using virtual drive X:

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Building IslamicApp Release APK Locally" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 1. Setup Java Home
$jdkPath = "C:\Program Files\Android\Android Studio\jbr"
if (Test-Path $jdkPath) {
    $env:JAVA_HOME = $jdkPath
    $env:PATH = "$env:JAVA_HOME\bin;$env:PATH"
    Write-Host "✓ JDK configured: $jdkPath" -ForegroundColor Green
} else {
    Write-Host "⚠️ Android Studio JBR not found at default path. Using system Java." -ForegroundColor Yellow
}

# 2. Map virtual drive X: to project root to avoid non-ASCII OneDrive path corruption
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
subst X: /d 2>$null
subst X: "$projectRoot"
Write-Host "✓ Project mapped to virtual drive X:\ (bypassing Windows Unicode path issues)" -ForegroundColor Green

# 3. Build APKs
Set-Location "X:\flutter_app"
Write-Host "🚀 Compiling Release APKs (Universal & 64-bit ARM)..." -ForegroundColor Cyan
flutter build apk --release --split-per-abi --no-tree-shake-icons

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n==========================================" -ForegroundColor Green
    Write-Host "  BUILD SUCCESSFUL!" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host "Your generated APKs are ready at:" -ForegroundColor White
    Get-ChildItem "$projectRoot\flutter_app\build\app\outputs\flutter-apk\*.apk" | ForEach-Object {
        $sizeMB = [math]::Round($_.Length / 1MB, 2)
        Write-Host "  - $($_.Name) ($sizeMB MB)" -ForegroundColor Yellow
    }
} else {
    Write-Host "`n❌ Build failed with exit code $LASTEXITCODE" -ForegroundColor Red
}
