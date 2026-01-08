@echo off

:: This is the startup / launch file to launch multiple rclone processes with no windows and using custom rclone profiles

:: -----------------------------
:: Profile list - ADD NEW PROFILE NAMES HERE
:: -----------------------------

:: First add new profile name to the following list so the :main code will call it
:: For consistency, these names should match the section names in rclone.conf file

:: set "RCLONE_PROFILE_LIST=hostinger mypy3 pydock"
set "RCLONE_PROFILE_LIST=hostinger mypy3 pydock"

:: Set the rclone install directory; this script expects this to be the name of the directory
:: that contains the rclone.exe file, and be in the /bin directory below the installation basepath
set "RCLONE_INSTALL_DIR=rclone-v1.69.2-windows-amd64"

call :main
exit /b 0 :: Exit the batch script

:: -----------------------------
:: Profile settings - CONFIG NEW PROFILES HERE
:: -----------------------------

:: Define each profile section below. Each label should match the names in RCLONE_PROFILE_LIST above.

:: -----------------------------
:: Hostinger Domains (H:) (hostinger)
:: -----------------------------

:hostinger
    setlocal

    set "RCLONE_PROFILE=hostinger" :: Same as section name in rclone.conf file
    :: set "REMOTE_HOST_PATH=domains" :: Relative path from remote mounted path to use as base path
    set "REMOTE_HOST_PATH=domains" :: Relative path from remote login path to use as mount path
    set "LOCAL_VOLUME_LETTER=H"
    set "LOCAL_VOLUME_NAME=%RCLONE_PROFILE%-domains"

    echo About to start rclone mount for %RCLONE_PROFILE% profile... >> "%GLOBAL_LOG_FILE%"
    call :start_profile_mount

    endlocal
    exit /b :: exit the section

:: -----------------------------
:: Python instance (P:) (mypy3)
:: -----------------------------

:mypy3
    setlocal

    set "RCLONE_PROFILE=mypy3" :: Same as section name in rclone.conf file
    set "REMOTE_HOST_PATH=projects" :: Relative path from remote login path to use as mount path
    set "LOCAL_VOLUME_LETTER=P"
    set "LOCAL_VOLUME_NAME=mypy3-projects"

    echo About to start rclone mount for %RCLONE_PROFILE% profile... >> "%GLOBAL_LOG_FILE%"
    call :start_profile_mount

    endlocal
    exit /b

:: -----------------------------
:: Python Docker container (D:) (pydock)
:: -----------------------------

:pydock
    setlocal

    set "RCLONE_PROFILE=pydock" :: Same as section name in rclone.conf file
    set "REMOTE_HOST_PATH=runtimes" :: Relative path from remote login path to use as mount path
    set "LOCAL_VOLUME_LETTER=D"
    set "LOCAL_VOLUME_NAME=pydock-runtimes"

    echo About to start rclone mount for %RCLONE_PROFILE% profile... >> "%GLOBAL_LOG_FILE%"
    call :start_profile_mount

    endlocal
    exit /b

:: -----------------------------
:: Hostinger domains (O:) (hostinger_orig)
:: -----------------------------

:hostinger_orig
    setlocal

    set "RCLONE_PROFILE=hostinger_orig" :: Same as section name in rclone.conf file
    set "REMOTE_HOST_PATH=domains" :: Relative path from remote login path to use as mount path
    set "LOCAL_VOLUME_LETTER=O"
    set "LOCAL_VOLUME_NAME=%RCLONE_PROFILE%-domains"

    echo About to start rclone mount for %RCLONE_PROFILE% profile... >> "%GLOBAL_LOG_FILE%"
    call :start_profile_mount

    endlocal
    exit /b


:: /////////////////////////////////////////////////////////////////////////////////////////////////

:: -----------------------------
:: Shared config sections - DO NOT EDIT
:: -----------------------------

:start_profile_mount
    echo Beginning start_profile_mount... >> "%GLOBAL_LOG_FILE%"

    :: Set fixed profile variables

    set "RCLONE_PROFILE_PATH=%RCLONE_BASE_PATH%\usr\profile\%RCLONE_PROFILE%"
    set "CTL_LOG_FILE=%RCLONE_PROFILE_PATH%\log\rclone_mount_ctl.log"

    :: Make new dirs; mkdir is idempotent and non-destructive, but we check if target exists for efficiency

    @if not exist "%RCLONE_PROFILE_PATH%\log" mkdir "%RCLONE_PROFILE_PATH%\log"
    @if not exist "%RCLONE_PROFILE_PATH%\cache" mkdir "%RCLONE_PROFILE_PATH%\cache"

    :: Note: 'start ""' required because rclone exe never returns and blocks the console
    start "" "%RCLONE_BASE_PATH%\bin\SilentCMD\SilentCMD.exe" "%RCLONE_BASE_PATH%\usr\script\rclone_mount_ctl.bat" "/LOG+:%RCLONE_PROFILE_PATH%\log\SilentCMD.log"

    echo Finished start_profile_mount section. >> "%GLOBAL_LOG_FILE%"
    exit /b

:main
    setlocal

    :: -----------------------------
    :: Shared variables - shared across profiles
    :: -----------------------------

    set "SCRIPT_DIR=%~dp0"  :: set the script dir variable to the location of this batch file
    for %%A in ("%SCRIPT_DIR%\..\..") do set "RCLONE_BASE_PATH=%%~fA" :: set rclone basepath to the parent of the parent dir of script dir
    set "RCLONE_EXE_PATH=%RCLONE_BASE_PATH%\bin\%RCLONE_INSTALL_DIR%\rclone.exe"
    set "RCLONE_CONF_PATH=%RCLONE_BASE_PATH%\conf\rclone.conf"
    set "GLOBAL_LOG_FILE=%RCLONE_BASE_PATH%\log\rclone_mount_global.log"

    echo: >> "%GLOBAL_LOG_FILE%"
    echo Beginning :main secion at %DATE% %TIME% >> "%GLOBAL_LOG_FILE%"
    echo Starting rclone_mount_start.bat >> "%GLOBAL_LOG_FILE%"
    echo: >> "%GLOBAL_LOG_FILE%" 

    :: -----------------------------
    :: Call each profile section and mount each remote
    :: -----------------------------

    echo "RCLONE_PROFILE_LIST: %RCLONE_PROFILE_LIST%" >> "%GLOBAL_LOG_FILE%"
    echo "About to loop through profiles." >> "%GLOBAL_LOG_FILE%"

    for %%p in (%RCLONE_PROFILE_LIST%) do (
        call :%%p
        timeout /t 2 /nobreak >nul
    )

    echo Finished :main section at %DATE% %TIME% >> "%GLOBAL_LOG_FILE%"
    endlocal
    exit /b :: Exit the section
