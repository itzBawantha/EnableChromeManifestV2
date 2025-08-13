@echo off
setlocal enabledelayedexpansion

:: Chrome ManifestV2 Policy Manager
:: This script manages the ExtensionManifestV2Availability policy in Chrome
:: Author: AI Assistant
:: Version: 1.0 (No Colors)

title Chrome ManifestV2 Policy Manager

:: Registry paths
set "CHROME_POLICY_PATH=HKLM\SOFTWARE\Policies\Google\Chrome"
set "CHROMIUM_POLICY_PATH=HKLM\SOFTWARE\Policies\Chromium"
set "POLICY_NAME=ExtensionManifestV2Availability"

echo ================================================================================
echo                        Chrome ManifestV2 Policy Manager
echo ================================================================================
echo.
echo This script manages Chrome's ExtensionManifestV2Availability policy.
echo This policy controls whether Manifest V2 extensions can be used in Chrome.
echo.
echo WARNING: This script requires Administrator privileges to modify system registry.
echo.

:: Check for administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: This script must be run as Administrator!
    echo Right-click on the batch file and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

echo Administrator privileges confirmed.
echo.

:MAIN_MENU
cls
echo ================================================================================
echo                        Chrome ManifestV2 Policy Manager
echo ================================================================================
echo.

:: Check current policy status
call :CHECK_CURRENT_STATUS

echo.
echo Options:
echo 1. Set policy to Default (Follow Chrome's timeline)
echo 2. Set policy to Disable (Block all MV2 extensions)
echo 3. Set policy to Enable (Allow all MV2 extensions)
echo 4. Set policy to EnableForForcedExtensions (Only force-installed MV2)
echo 5. Remove policy (Delete from registry)
echo 6. Show detailed policy information
echo 7. Check Chrome installation status
echo 8. Exit
echo.
set /p "choice=Enter your choice (1-8): "

if "%choice%"=="1" goto SET_DEFAULT
if "%choice%"=="2" goto SET_DISABLE
if "%choice%"=="3" goto SET_ENABLE
if "%choice%"=="4" goto SET_FORCED_ONLY
if "%choice%"=="5" goto REMOVE_POLICY
if "%choice%"=="6" goto SHOW_INFO
if "%choice%"=="7" goto CHECK_CHROME
if "%choice%"=="8" goto EXIT
echo Invalid choice. Please enter 1-8.
timeout /t 2 >nul
goto MAIN_MENU

:CHECK_CURRENT_STATUS
echo Current Policy Status:
echo ----------------------------------------

:: Check for Chrome policy
reg query "%CHROME_POLICY_PATH%" /v "%POLICY_NAME%" >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=3" %%a in ('reg query "%CHROME_POLICY_PATH%" /v "%POLICY_NAME%" 2^>nul') do set "chrome_value=%%a"
    echo Chrome Policy Found: !chrome_value!
    call :INTERPRET_VALUE !chrome_value! "Chrome"
) else (
    echo Chrome Policy: Not set (using default behavior)
)

:: Check for Chromium policy
reg query "%CHROMIUM_POLICY_PATH%" /v "%POLICY_NAME%" >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=3" %%a in ('reg query "%CHROMIUM_POLICY_PATH%" /v "%POLICY_NAME%" 2^>nul') do set "chromium_value=%%a"
    echo Chromium Policy Found: !chromium_value!
    call :INTERPRET_VALUE !chromium_value! "Chromium"
) else (
    echo Chromium Policy: Not set (using default behavior)
)

:: Check if policies folder exists
reg query "%CHROME_POLICY_PATH%" >nul 2>&1
if %errorlevel% neq 0 (
    echo Note: Chrome Policies folder does not exist in registry.
)

goto :eof

:INTERPRET_VALUE
set "value=%1"
set "browser=%2"
set "value=%value:"=%"

if "%value%"=="0x0" set "description=Default - Follow Chrome's MV2 deprecation timeline"
if "%value%"=="0x1" set "description=Disabled - Block all Manifest V2 extensions"
if "%value%"=="0x2" set "description=Enabled - Allow all Manifest V2 extensions"
if "%value%"=="0x3" set "description=EnableForForcedExtensions - Only force-installed MV2 extensions"

if not defined description set "description=Unknown value"

echo   - %description%
goto :eof

:SET_DEFAULT
echo.
echo Setting policy to Default (0)...
call :SET_POLICY_VALUE 0
goto MAIN_MENU

:SET_DISABLE
echo.
echo Setting policy to Disable (1)...
call :SET_POLICY_VALUE 1
goto MAIN_MENU

:SET_ENABLE
echo.
echo Setting policy to Enable (2)...
call :SET_POLICY_VALUE 2
goto MAIN_MENU

:SET_FORCED_ONLY
echo.
echo Setting policy to EnableForForcedExtensions (3)...
call :SET_POLICY_VALUE 3
goto MAIN_MENU

:SET_POLICY_VALUE
set "policy_value=%1"

:: Create Chrome policy if it doesn't exist
reg query "%CHROME_POLICY_PATH%" >nul 2>&1
if %errorlevel% neq 0 (
    echo Creating Chrome Policies registry key...
    reg add "%CHROME_POLICY_PATH%" /f >nul 2>&1
)

:: Set Chrome policy
echo Setting Chrome policy to %policy_value%...
reg add "%CHROME_POLICY_PATH%" /v "%POLICY_NAME%" /t REG_DWORD /d %policy_value% /f >nul 2>&1
if %errorlevel% equ 0 (
    echo [SUCCESS] Chrome policy set successfully
) else (
    echo [ERROR] Failed to set Chrome policy
)

:: Ask about Chromium
echo.
set /p "set_chromium=Also set policy for Chromium? (y/n): "
if /i "%set_chromium%"=="y" (
    reg query "%CHROMIUM_POLICY_PATH%" >nul 2>&1
    if %errorlevel% neq 0 (
        echo Creating Chromium Policies registry key...
        reg add "%CHROMIUM_POLICY_PATH%" /f >nul 2>&1
    )
    
    echo Setting Chromium policy to %policy_value%...
    reg add "%CHROMIUM_POLICY_PATH%" /v "%POLICY_NAME%" /t REG_DWORD /d %policy_value% /f >nul 2>&1
    if %errorlevel% equ 0 (
        echo [SUCCESS] Chromium policy set successfully
    ) else (
        echo [ERROR] Failed to set Chromium policy
    )
)

echo.
echo NOTE: Chrome needs to be restarted for policy changes to take effect.
echo.
pause
goto :eof

:REMOVE_POLICY
echo.
echo Removing ManifestV2 policy from registry...
echo.

:: Remove Chrome policy
reg delete "%CHROME_POLICY_PATH%" /v "%POLICY_NAME%" /f >nul 2>&1
if %errorlevel% equ 0 (
    echo [SUCCESS] Chrome policy removed successfully
) else (
    echo [INFO] Chrome policy was not set or could not be removed
)

:: Remove Chromium policy
reg delete "%CHROMIUM_POLICY_PATH%" /v "%POLICY_NAME%" /f >nul 2>&1
if %errorlevel% equ 0 (
    echo [SUCCESS] Chromium policy removed successfully
) else (
    echo [INFO] Chromium policy was not set or could not be removed
)

echo.
echo NOTE: Chrome needs to be restarted for changes to take effect.
echo After restart, Chrome will no longer show "Managed by your organization"
echo if no other policies are set.
echo.
pause
goto MAIN_MENU

:SHOW_INFO
cls
echo ================================================================================
echo                    ExtensionManifestV2Availability Policy Information
echo ================================================================================
echo.
echo What this policy does:
echo This policy controls whether Manifest V2 extensions can be used in Chrome.
echo Google is deprecating Manifest V2 in favor of Manifest V3 for security reasons.
echo.
echo Policy Values:
echo 0 (Default):
echo   - Follows Chrome's official MV2 deprecation timeline
echo   - MV2 extensions will be disabled according to Google's schedule
echo   - This is the normal behavior for consumer Chrome
echo.
echo 1 (Disable):
echo   - Immediately blocks ALL Manifest V2 extensions
echo   - More restrictive than the default timeline
echo   - Users cannot install or run any MV2 extensions
echo.
echo 2 (Enable):
echo   - Allows ALL Manifest V2 extensions to continue working
echo   - Bypasses Google's deprecation timeline
echo   - This is what IDM and similar software use
echo.
echo 3 (EnableForForcedExtensions):
echo   - Only allows force-installed MV2 extensions
echo   - Blocks user-installed MV2 extensions
echo   - Intended for enterprise managed extensions
echo.
echo Side Effects:
echo - Setting any value will make Chrome show "Managed by your organization"
echo - This indicates enterprise policies are active
echo - The message appears even if not actually managed by an organization
echo.
echo Registry Locations:
echo Chrome:   %CHROME_POLICY_PATH%
echo Chromium: %CHROMIUM_POLICY_PATH%
echo.
echo Security Note:
echo This policy was designed for enterprises needing migration time.
echo Using it to bypass consumer restrictions may have security implications.
echo.
pause
goto MAIN_MENU

:CHECK_CHROME
cls
echo ================================================================================
echo                         Chrome Installation Status
echo ================================================================================
echo.

:: Check if Chrome is installed
echo Checking Chrome installation...
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Google Chrome" >nul 2>&1
if %errorlevel% equ 0 (
    echo [FOUND] Chrome is installed (system-wide)
) else (
    reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Google Chrome" >nul 2>&1
    if %errorlevel% equ 0 (
        echo [FOUND] Chrome is installed (user-only)
    ) else (
        echo [NOT FOUND] Chrome installation not detected
    )
)

:: Check if Chromium is installed
echo Checking Chromium installation...
where chromium >nul 2>&1
if %errorlevel% equ 0 (
    echo [FOUND] Chromium found in PATH
) else (
    echo [NOT FOUND] Chromium not found in PATH
)

:: Check for running Chrome processes
echo.
echo Checking running Chrome processes...
tasklist /FI "IMAGENAME eq chrome.exe" 2>nul | find /I "chrome.exe" >nul
if %errorlevel% equ 0 (
    echo [WARNING] Chrome is currently running
    echo   Restart Chrome after making policy changes
) else (
    echo [OK] Chrome is not currently running
)

:: Check current Chrome policies status
echo.
echo Chrome policy status:
echo To check current policies, open Chrome and go to: chrome://policy
echo.
pause
goto MAIN_MENU

:EXIT
echo.
echo Thank you for using Chrome ManifestV2 Policy Manager!
echo.
echo Remember:
echo - Restart Chrome for policy changes to take effect
echo - Visit chrome://policy to verify current policies
echo - Remove policies when no longer needed
echo.
pause
exit /b 0 