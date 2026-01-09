#rclone-mount-tuning (gemini-3-pro)

## Me
## why does the rclone mount command in the rclone_mount_ctl.bat file have very slow throughput for a simple file copy operation?

## AI Assistant

Based on the content of rclone_mount_ctl.bat, the slow throughput is primarily caused by the extremely aggressive timeout settings used for directory and attribute caching.
In your script, you have these flags:``` batch
// ... existing code ...
      --volname "%LOCAL_VOLUME_NAME%" ^
      --vfs-cache-mode full ^
      --dir-cache-time .1s ^
      --attr-timeout .1s ^
      --poll-interval 0 ^
// ... existing code ...
```

The Problem
You have set --dir-cache-time and --attr-timeout to 0.1 seconds.
--dir-cache-time .1s: This forces rclone to refresh the directory listing from the remote server essentially every time you access a folder.
--attr-timeout .1s: This forces rclone to re-check file properties (size, date, permissions) from the server for almost every operation.
Why this kills throughput: Windows Explorer (and the OS in general) is very "chatty." A simple file copy involves dozens of operations: checking if the destination folder exists, checking if the file name exists, reading attributes, locking the file, etc. With a 0.1s timeout, each one of these tiny checks triggers a network request to the remote server. Instead of spending time transferring data, rclone is spending all its time waiting for the server to say "Yes, that file exists" or "Here is the file size."
The Solution
Unless you absolutely need to see changes made by other people/machines instantly (within 0.1s), you should increase these values significantly.
Recommended changes for better performance:
Increase --dir-cache-time to at least 30s or 1m (default is usually 5m).
Increase --attr-timeout to at least 30s or 1m (default is usually 1s).
If you change the lines in rclone_mount_ctl.bat to the following, you should see a massive improvement in speed:``` batch
      --dir-cache-time 60s ^
      --attr-timeout 60s ^
```


## Me
## yes, but with those changes, remote file changes won't be detected for 60s seconds, correct?

## AI Assistant

Yes, that is correct.
If you increase --dir-cache-time and --attr-timeout to 60 seconds, your local machine will rely on its cached view of the file system for up to one minute.
If a file is added, deleted, or modified on the remote server by a different user (or a different process) during that minute:
You won't see it immediately: Windows Explorer won't show the new file or the updated timestamp until the cache expires.
Conflicts might occur: If you try to write to a file that has changed remotely but your cache is stale, you might overwrite their changes (though --vfs-cache-mode full helps mitigate corruption, it doesn't solve the "stale view" problem).
Is there a middle ground?
If you need near-real-time updates and good performance, you are in a difficult spot with standard mounting, especially on SFTP (which your script comments suggest you might be using, given --poll-interval 0).
SFTP limitation: SFTP servers usually do not support "polling" or notifications. Rclone cannot ask the server "tell me when something changes." It must ask "what is the state now?" repeatedly.
Google Drive / Dropbox / OneDrive: These backends support --poll-interval. Rclone can poll every 60s (or faster) for a changelog, and if nothing changed, it keeps the cache. If something changed, it invalidates the cache intelligently. This allows for high cache times and fast updates.
Suggestion for SFTP / Generic Backends
If you are indeed using SFTP or a backend without polling support:
Performance vs. Freshness Trade-off: You have to choose. 0.1s is too fast for the OS overhead.
Try 1s to 5s: Even increasing it to --dir-cache-time 5s and --attr-timeout 5s will be drastically faster than 0.1s because it allows a burst of filesystem operations (like a copy) to complete using the cache, while only delaying remote updates by 5 seconds.

## Me
## if .1s is bad, does that mean 0 is worse?

## AI Assistant

Actually, in the specific context of rclone flags, setting them to 0 usually means "disable caching completely," which is functionally very similar to .1s (0.1 seconds), but often slightly worse or identical in performance impact.
--dir-cache-time 0: This means "don't cache directory listings at all." Every time you list a directory (ls, opening a folder in Explorer), rclone MUST go to the network.
--attr-timeout 0: This means "don't cache file attributes at all." Every time the OS asks "how big is this file?" or "when was it modified?", rclone MUST go to the network.
Why 0 or 0.1s is terrible for "Simple File Copy": When you copy a file in Windows, the OS performs a sequence of operations like this in rapid succession:
GetFileAttributes (Is it there?) -> Network Call
Open (Open it) -> Network Call
GetFileInformation (Size?) -> Network Call
Read (Data)
GetFileAttributes (Did it change?) -> Network Call
Close
With caching enabled (even for 1-5 seconds), steps 1, 3, and 5 can be answered instantly from memory. With 0 or .1s, the OS has to wait for network latency (e.g., 50ms ping) for every single one of those metadata steps.
In summary: Yes, 0 is essentially the "worst case" for performance because it forces a network round-trip for absolutely every metadata operation, serialization, and check that the file system performs. .1s is effectively the same as 0 for any operation that takes longer than 100ms.
