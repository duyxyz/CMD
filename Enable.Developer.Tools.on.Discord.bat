@echo off
setlocal enabledelayedexpansion
title Discord DevTools Enabler

set "SETTINGS_DIR=%APPDATA%\discord"
set "SETTINGS_FILE=%SETTINGS_DIR%\settings.json"
set "BACKUP_FILE=%SETTINGS_DIR%\settings.json.bak"

echo ============================================
echo   Discord DevTools Enabler
echo ============================================
echo.

REM --- Check if Discord is running ---
tasklist /FI "IMAGENAME eq Discord.exe" 2>NUL | find /I "Discord.exe" >NUL
if "%ERRORLEVEL%"=="0" (
    echo [WARNING] Discord is currently running.
    echo Please close Discord completely ^(including system tray^) before continuing.
    echo.
    choice /M "Continue anyway"
    if errorlevel 2 (
        echo Aborted.
        pause
        exit /b 1
    )
)

REM --- Ensure settings folder exists ---
if not exist "%SETTINGS_DIR%" (
    echo [ERROR] Discord settings folder not found at:
    echo   %SETTINGS_DIR%
    echo Make sure Discord has been installed and run at least once.
    pause
    exit /b 1
)

REM --- Backup existing settings.json if present ---
if exist "%SETTINGS_FILE%" (
    copy /Y "%SETTINGS_FILE%" "%BACKUP_FILE%" >NUL
    echo [OK] Backed up existing settings.json to settings.json.bak
) else (
    echo [INFO] No existing settings.json found, a new one will be created.
)

REM --- Merge/update the DevTools flag using PowerShell (preserves other keys) ---
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$path = '%SETTINGS_FILE%';" ^
    "$obj = if (Test-Path $path) { Get-Content $path -Raw | ConvertFrom-Json } else { New-Object PSObject };" ^
    "$obj | Add-Member -NotePropertyName 'DANGEROUS_ENABLE_DEVTOOLS_ONLY_ENABLE_IF_YOU_KNOW_WHAT_YOURE_DOING' -NotePropertyValue $true -Force;" ^
    "$obj | ConvertTo-Json -Depth 10 | Set-Content -Path $path -Encoding UTF8;"

if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to update settings.json.
    pause
    exit /b 1
)

echo.
echo [SUCCESS] DevTools flag enabled in:
echo   %SETTINGS_FILE%
echo.
echo A backup of your previous settings was saved as settings.json.bak
echo Restart Discord for the change to take effect.
echo.
pause
