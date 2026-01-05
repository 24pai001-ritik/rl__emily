@echo off
REM setup_cron.bat - Setup scheduled tasks for RL Emily post scheduler (Windows)

echo Setting up scheduled tasks for RL Emily post scheduler...

REM Get the absolute path to the project directory
set "PROJECT_DIR=%~dp0"
set "SCRIPT_PATH=%PROJECT_DIR%post_scheduler.py"

REM Remove trailing backslash if present
if "%PROJECT_DIR:~-1%"=="\" set "PROJECT_DIR=%PROJECT_DIR:~0,-1%"

echo Project directory: %PROJECT_DIR%
echo Script path: %SCRIPT_PATH%

REM Check if Python is available
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    pause
    exit /b 1
)

REM Check if the script exists
if not exist "%SCRIPT_PATH%" (
    echo ERROR: post_scheduler.py not found at %SCRIPT_PATH%
    pause
    exit /b 1
)

REM Create logs directory
if not exist "%PROJECT_DIR%\logs" mkdir "%PROJECT_DIR%\logs"

echo.
echo Setting up Windows Task Scheduler jobs...
echo.

REM Set up the scheduling task (runs at 5 AM IST daily)
REM Note: Windows Task Scheduler uses local time, so 5:00 AM IST
echo Creating scheduling task (runs at 5:00 AM daily)...
schtasks /create /tn "RL Emily Post Scheduler" /tr "python \"%SCRIPT_PATH%\" schedule >> \"%PROJECT_DIR%\logs\scheduler.log\" 2>&1" /sc daily /st 05:00 /f

if errorlevel 1 (
    echo ERROR: Failed to create scheduling task
) else (
    echo SUCCESS: Scheduling task created
)

REM Set up the publishing task (runs every 15 minutes)
echo Creating publishing task (runs every 15 minutes)...
schtasks /create /tn "RL Emily Post Publisher" /tr "python \"%SCRIPT_PATH%\" post >> \"%PROJECT_DIR%\logs\publisher.log\" 2>&1" /sc minute /mo 15 /f

if errorlevel 1 (
    echo ERROR: Failed to create publishing task
) else (
    echo SUCCESS: Publishing task created
)

echo.
echo Setup complete!
echo.
echo Scheduled tasks configured:
echo 1. Scheduling task: Runs at 5:00 AM daily
echo    - Finds posts with status 'generated'
echo    - Changes status to 'scheduled'
echo.
echo 2. Publishing task: Runs every 15 minutes
echo    - Finds scheduled posts ready to publish
echo    - Posts to social media platforms
echo    - Updates status to 'posted' with media_id
echo.
echo Logs are stored in: %PROJECT_DIR%\logs\
echo   - scheduler.log: Scheduling job logs
echo   - publisher.log: Publishing job logs
echo.
echo To view scheduled tasks:
echo   Task Scheduler ^> Task Scheduler Library
echo.
echo To remove scheduled tasks:
echo   schtasks /delete /tn "RL Emily Post Scheduler"
echo   schtasks /delete /tn "RL Emily Post Publisher"
echo.
pause
