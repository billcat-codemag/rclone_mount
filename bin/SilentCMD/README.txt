:: ----------------------------- 
:: Shortcut / command line notes
:: ----------------------------- 

- Must be run from a shortcut placed in [Win+R -> shell:startup] with the following config at startup to be available at startup, or else a command line.

- Shortcut in:  Win+R -> shell:startup

- Target:       {path_to_silentcmd_exe} {path_to_rclone_mount_start_bat} /LOG+:{path_to_silentcmd_log}
-- Example:       C:\Users\wcatl\code\rclone\usr\SilentCMD\SilentCMD.exe C:\Users\wcatl\code\rclone\usr\rclone_mount_start.bat /LOG+:C:\Users\wcatl\code\rclone\log\SilentCMD.log

- Start in:     {path_to_runtime_dir}
-- Example:       C:\Users\wcatl\code\rclone\usr

- Shortcut key: None

- Run:          Normal window


:: -----------------------------
:: Other variants of start rclone mount controller
:: -----------------------------

:: call %RCLONE_WORK_PATH%\usr\rclone_mount_ctl.bat

:: C:\Users\wcatl\code\rclone\usr\SilentCMD\SilentCMD.exe %RCLONE_WORK_PATH%\usr\rclone_mount_ctl.bat /LOG+:C:\Users\wcatl\code\rclone\log\SilentCMD.log

:: start ""  %RCLONE_WORK_PATH%\usr\rclone_mount_ctl.bat

:: start "" C:\Users\wcatl\code\rclone\usr\SilentCMD\SilentCMD.exe %RCLONE_WORK_PATH%\usr\rclone_mount_ctl.bat /LOG+:C:\Users\wcatl\code\rclone\log\SilentCMD.log


:: -----------------------------
:: Other Notes
:: -----------------------------

:: - determine unmount command so that one drive letter can be a pivot - such as R: for REMOTE_PATH
