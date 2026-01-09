@echo off

:: This is the controller file to config variables and call mount script.

:: ----------------------------- 
:: Log start session
:: -----------------------------

echo: >> "%CTL_LOG_FILE%"
echo %DATE% %TIME% >> "%CTL_LOG_FILE%"
echo Starting rclone_mount_ctl.bat >> "%CTL_LOG_FILE%"
echo
echo: >> "%CTL_LOG_FILE%" 

:: ----------------------------- 
:: Start session
:: -----------------------------

call :main
exit /b 0

:: ----------------------------- 
:: rclone_mount_dir.bat functions
:: ----------------------------- 

:mountDir

	echo CTL_LOG_FILE: "%CTL_LOG_FILE%"
	echo RCLONE_EXE_PATH: %RCLONE_EXE_PATH% >> "%CTL_LOG_FILE%"
	echo RCLONE_BASE_PATH: %RCLONE_BASE_PATH% >> "%CTL_LOG_FILE%"
	echo RCLONE_PROFILE: "%RCLONE_PROFILE%" >> "%CTL_LOG_FILE%"
	echo RCLONE_PROFILE_PATH: %RCLONE_PROFILE_PATH% >> "%CTL_LOG_FILE%"
	echo REMOTE_HOST_PATH: "%REMOTE_HOST_PATH%" >> "%CTL_LOG_FILE%"
	echo LOCAL_VOLUME_LETTER: "%LOCAL_VOLUME_LETTER%" >> "%CTL_LOG_FILE%"
	echo LOCAL_VOLUME_NAME: "%LOCAL_VOLUME_NAME%" >> "%CTL_LOG_FILE%"
	echo Mounting to the target drive letter: "%LOCAL_VOLUME_LETTER%" >> "%CTL_LOG_FILE%"
    for /F "tokens=2" %%i in ('whoami /user /fo table /nh') do set USER_SID=%%i
    echo USER_SID: %USER_SID% >> "%CTL_LOG_FILE%"

    :: --vfs-cache-mode full - Needed if applications edit files locally and expect changes to be uploaded correctly.
    :: --dir-cache-time 1s - Disables directory caching entirely when set to 0.
    :: --attr-timeout 1s - Controls how long file attributes (stat() results) stay cached. Makes external edits (mtime/size changes) show up instantly.
    :: --poll-interval 0 - Disables backend polling entirely. Default for sftp since it has no change notification support.

	"%RCLONE_EXE_PATH%" mount "%RCLONE_PROFILE%":"%REMOTE_HOST_PATH%" "%LOCAL_VOLUME_LETTER%": ^
      --config "%RCLONE_CONF_PATH%" ^
      --log-file "%RCLONE_PROFILE_PATH%\log\rclone.log" ^
      --log-level NOTICE ^
      --network-mode ^
      --volname "%LOCAL_VOLUME_NAME%" ^
      --vfs-cache-mode full ^
      --dir-cache-time 1s ^
      --attr-timeout 1s ^
      --poll-interval 0 ^
      --cache-dir "%RCLONE_PROFILE_PATH%\cache" ^
      -o FileSecurity="D:P(A;;FA;;;%USER_SID%)"

    exit /b 0 :: Exit the section

:main
    echo About to enter rclone mountDir section... >> "%CTL_LOG_FILE%"
    call :mountDIR
    echo ...returned from rclone mountDir section. >> "%CTL_LOG_FILE%"
    exit /b 0 :: Exit the main script
