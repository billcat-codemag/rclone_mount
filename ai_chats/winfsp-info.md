# winfsp-info (gemini-3-default)

## why does winfsp force all files to give Everyone read permissions?
December 29, 2025

WinFsp does not strictly "force" these permissions; rather, the "Everyone: Read" behavior is a result of how the WinFsp-FUSE layer translates POSIX (Linux-style) file permissions into Windows security descriptors (ACLs). 
The following factors contribute to this behavior:
1. POSIX-to-Windows Translation
The Mapping Model: WinFsp's FUSE layer must map a UNIX bitmask (e.g., 0755 or 0644) to a Windows Access Control List. By default, if the underlying file system (like a remote SSH server) reports a mode where "others" have read access, WinFsp maps this to the Windows "Everyone" group with Read and Execute rights.
Default Umask: Many FUSE implementations use a default getattr value that reports files as having 0666 or 0777 permissions if not specified otherwise. This translates to broad access for "Everyone" on the Windows side. 
2. Compatibility and Interoperability
Preventing Access Denied Errors: To ensure that common Windows applications (like Windows Explorer) can navigate and list files, WinFsp often defaults to a more permissive state for the "Everyone" group. Without these permissions, users might encounter ERROR_ACCESS_DENIED because the Windows security check cannot find a matching SID for the current user in the reported POSIX metadata.
User Identity Mismatch: If the file system does not have a precise mapping between a Linux UID/GID and a Windows SID, WinFsp uses the "Everyone" group as a catch-all to ensure the file system remains usable. 
3. How to Change This Behavior
You can override these default permissions using specific mount options at the command line: 
Restricting to Current User: Use -ouid=-1,gid=-1. This tells WinFsp to present all files as if they are owned by the specific user who launched the file system, rather than broad groups.
Modifying the Mask: Use -oumask=007 (or similar) to strip permissions from "others" (the Windows "Everyone" group) before they are presented to Windows.
Full Control for Everyone: Conversely, if you want full access for all users, you can use -ouid=65792,gid=65792,umask=0, which translates to "Everyone" having Full Control. 
Write access denied (fuse compat layer) · Issue #40 - GitHub
The "access denied" error likely comes from the GetSecurityByName file system operation. This is implemented for you in WinFsp-FUS...

GitHub

Cryptomator vault mounted with WinFsp on Windows read ...
More precisely, using the default configuration (that is with “Custom Mount Flags” option unticked), all access rights are granted...

Cryptomator Community

required operations for fuse rename to work? #79 - GitHub
billziss-gh commented ... @SamKelly This is definitely a permissions issue. The easiest way to fix it for now is to pass the param...

GitHub

virtio-fs with a win10 QEMU guest and WinFsp - Google Groups
When working with file systems the following problem often arises: a file that is stored on a computer that follows the UNIX secur...

Google Groups
Frequently Asked Questions - WinFsp
Most importantly: inability to guarantee that the mount point will cease to exist if the file system crashes. WinFsp attempts to g...

WinFsp





What impact does this have on performance and security?

Explain the purpose of the -ouid=-1 and -ogid=11 options

Give me some examples of different umask values

undefined
undefined
undefined
11 sites
virtio-fs with a win10 QEMU guest and WinFsp - Google Groups
When working with file systems the following problem often arises: a file that is stored on a computer that follows the UNIX secur...

Google Groups
Frequently Asked Questions - WinFsp
Most importantly: inability to guarantee that the mount point will cease to exist if the file system crashes. WinFsp attempts to g...

WinFsp

required operations for fuse rename to work? #79 - GitHub
billziss-gh commented ... @SamKelly This is definitely a permissions issue. The easiest way to fix it for now is to pass the param...

GitHub

Show all
## explain the purpose of the -ouid=-1 and -ogid=11 options
December 29, 2025

In WinFsp (Windows File System Proxy), these mount options are used within the FUSE compatibility layer to bridge the gap between POSIX-style file ownership (UID/GID) and Windows security identifiers (SIDs).
Purpose of -ouid=-1
The -ouid=-1 option is a convenience setting that solves ownership mismatches between the host file system and Windows.
Dynamic Mapping: Instead of mapping files to a specific numerical ID, it instructs WinFsp to present every file and directory as if it is owned by the current user who launched the file system process.
Access Resolution: This is primarily used to fix "Access Denied" errors. In Windows, many applications expect the current user to have explicit ownership or specific rights to a file to perform certain operations. By reporting the current user as the owner, WinFsp ensures the user has the necessary administrative control over the mounted files. 
Purpose of -ogid=11
The -ogid=11 option maps the file system's group ownership to a specific Windows well-known group.
Authenticated Users: In the WinFsp-FUSE layer, the numerical ID 11 is internally mapped to the Windows "Authenticated Users" group SID (S-1-5-11).
Broad Access: Using this option presents all files as belonging to the "Authenticated Users" group rather than the current user's primary group. This is often used when you want the files to be accessible to any logged-in user on the system while still maintaining a standard group structure. 
Summary Table
Option	Meaning in WinFsp	Windows Equivalent
-ouid=-1	Owner = Process Launcher	Current User's SID
-ogid=-1	Group = Process Launcher's Group	Current User's Primary Group SID
-ogid=11	Group = Authenticated Users	S-1-5-11 (Authenticated Users)
You can combine these as -o uid=-1,gid=11 to ensure that you are the owner of all files while the group ownership is set to a broad, system-recognized group for better compatibility with Windows permissions checks. 
AI responses may include mistakes. For financial advice, consult a professional. Learn more




What are other common WinFsp-FUSE mount options for file system access?

What group SIDs do WinFsp use for common groups?

Explain the use of FUSE_SETATTR_UID and FUSE_SETATTR_GID in this context

undefined

1 site
Frequently Asked Questions - WinFsp
FUSE * Which version of FUSE does WinFsp-FUSE support? It supports both the FUSE 2.8 and FUSE 3.2 API's. For the FUSE 2.8 API incl...

WinFsp

## what are other common WinFsp-FUSE mount options for file system access?
December 29, 2025

In addition to ownership mapping, WinFsp-FUSE supports several common mount options to control security, performance, and compatibility with the Windows environment. 
1. Permissions and Security
-o umask=MASK: Sets the default file creation mask in octal (e.g., 022). This determines which permissions are removed from files.
Note: WinFsp-FUSE often reports a base permission of 0755 for directories and 0644 for files if not otherwise specified.
-o allow_other: Bypasses the security check that restricts a FUSE mount to only the user who mounted it. On Windows, this allows other users or system services to see and access the drive.
-o default_permissions: Forces the kernel (WinFsp driver) to perform standard UNIX-style permission checks based on UID/GID and mode bits before passing the request to the file system. 
2. User and Group Identity
-o uid=-1,gid=-1: Maps all files to the current user and their primary group.
-o gid=11: Explicitly maps group ownership to the Windows "Authenticated Users" group (S-1-5-11).
-o uid=0,gid=0: Often used to simulate "root" ownership, though in a Windows context, this typically maps to a specific SID like the local Administrators group depending on the FUSE implementation. 
3. File System Behavior
-o case_insensitive: Configures the file system to ignore character case in filenames. This is crucial for Windows compatibility, as many Windows applications assume the file system is case-insensitive.
-o ro: Mounts the file system as Read-Only. This prevents any write operations from being passed to the underlying storage.
-o exec / -o noexec: Enables or disables the ability to execute binaries from the mounted volume. 
4. Performance and Debugging
-f: Runs the file system in the foreground (useful for seeing log output directly in the console).
-d or --debug: Enables detailed debug logging for troubleshooting I/O requests.
-o direct_io: Bypasses the OS kernel cache, forcing all I/O to go directly to the file system. While this can improve performance for certain database-like workloads, it may slow down standard file browsing.
-o writeback_cache: Enables asynchronous writes to the underlying storage, which can significantly improve write performance at the cost of potential data loss if the process crashes. 




undefined
undefined
undefined
17 sites
FUSE Mount Options | JuiceFS Document Center
JuiceFS provides several access methods, FUSE is the common one, which is the way to mount the file system locally using the juice...

JuiceFS
Frequently Asked Questions - WinFsp
FUSE * Which version of FUSE does WinFsp-FUSE support? It supports both the FUSE 2.8 and FUSE 3.2 API's. For the FUSE 2.8 API incl...

WinFsp

configuration and mount options for FUSE file systems - Ubuntu Manpage
allow_other This option overrides the security measure restricting file access to the filesystem owner, so that all users (includi...

Ubuntu Manpage
Show all
## when using winfsp with rclone mount on windows, how can i force files on the windows filesystem mount to be owned by my user and my group sid - and not include Everyone?
December 30, 2025

To force files on an rclone mount with WinFsp to be owned strictly by your user and group while removing permissions for "Everyone," you must use a combination of ownership flags and custom permission masks.
Recommended Mount Options
Add the following flags to your rclone mount command:
--dir-perms 0770: Gives full control (Read/Write/Execute) to the Owner and Group, and zero permissions to "Others" (which maps to the Windows Everyone group).
--file-perms 0660: Similar to above, this restricts file access to only the Owner and Group.
-o uid=-1,gid=-1: Automatically maps all files to the current user's SID and their primary group's SID. 
Example Command
powershell
rclone mount remote:path X: --dir-perms 0770 --file-perms 0660 -o uid=-1,gid=-1
Use code with caution.

Advanced: Explicit SID Mapping (FileSecurity)
If the standard permission bits still show "Everyone" due to WinFsp's compatibility defaults, you can use the FileSecurity option (WinFsp 2021/v1.9+) to define a specific Security Descriptor Definition Language (SDDL) string. 
Option: -o FileSecurity="D:P(A;;FA;;;<YOUR_SID>)"
Effect: This ignores POSIX mapping entirely and sets a single "Allow Full Access" (FA) entry for your specific SID.
To find your SID: Run whoami /user in a Command Prompt. 
Summary of Flags for Privacy
Goal 	Flag to Use
Remove "Everyone"	--dir-perms 0770 --file-perms 0660
Own all files	-o uid=-1,gid=-1 (standard for process launcher)
Strict Lockout	-o umask=077 (alternative to perms flags)
Total SID Control	-o FileSecurity="D:P(A;;FA;;;USER_SID)"