:: Make empty directories for rclone install and runtime

@echo off

set RCLONE_BASE_PATH=%1

echo:
echo Making empty installation dirs at RCLONE_BASE_PATH: %RCLONE_BASE_PATH%
echo:

mkdir "%RCLONE_BASE_PATH%\bin"
mkdir "%RCLONE_BASE_PATH%\conf"
mkdir "%RCLONE_BASE_PATH%\log"
mkdir "%RCLONE_BASE_PATH%\usr\script"

dir "%RCLONE_BASE_PATH%"
