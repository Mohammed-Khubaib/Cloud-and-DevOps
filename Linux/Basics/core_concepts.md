# Linux Core Concepts

## Table of Contents
- [Linux Kernel](#linux-kernel)
  - [What is the Kernel?](#what-is-the-kernel)
  - [Kernel Functions](#kernel-functions)
  - [Kernel Space vs User Space](#kernel-space-vs-user-space)
  - [Kernel Versions](#kernel-versions)
  - [Working with Hardware](#working-with-hardware)
- [Linux Boot Sequence](#linux-boot-sequence)
  - [BIOS/UEFI Stage](#biosuefi-stage)
  - [Boot Loader Stage](#boot-loader-stage)
  - [Kernel Initialization](#kernel-initialization)
  - [systemd Initialization](#systemd-initialization)
- [Runlevels and Targets](#runlevels-and-targets)
  - [Traditional SysV Runlevels](#traditional-sysv-runlevels)
  - [systemd Targets](#systemd-targets)
  - [Managing Targets](#managing-targets)
- [File Types in Linux](#file-types-in-linux)
  - [Regular Files](#regular-files)
  - [Directories](#directories)
  - [Special Files](#special-files)
  - [Identifying File Types](#identifying-file-types)
- [File System Hierarchy](#file-system-hierarchy)
  - [Root Directory Structure](#root-directory-structure)
  - [Important Directories](#important-directories)
  - [Configuration Files](#configuration-files)

## Linux Kernel

### What is the Kernel?

The Linux kernel is the core component of the Linux operating system. It serves as the main interface between the computer's hardware and its processes. The kernel has complete control over everything in the system and manages the following core functions:

- Process management
- Memory management
- Device management
- System calls and security
- File system management

### Kernel Functions

1. **Process Management:**
   - Schedules processes for execution
   - Allocates resources to processes
   - Facilitates inter-process communication

2. **Memory Management:**
   - Manages physical and virtual memory
   - Implements memory protection
   - Handles memory allocation and deallocation

3. **Device Management:**
   - Provides device drivers for hardware
   - Manages device communication
   - Handles interrupts

4. **System Calls and Security:**
   - Provides API for user programs to access kernel services
   - Enforces access permissions
   - Implements security policies

5. **File System Management:**
   - Manages file storage and organization
   - Provides file access control
   - Supports various file systems

### Kernel Space vs User Space

Linux architecture is divided into two distinct spaces:

**Kernel Space**:
- Protected memory area
- Full access to hardware
- Runs kernel code and device drivers
- Executes with highest privileges
- Handles critical system operations

**User Space**:
- Where applications and user processes run
- Limited access to hardware
- Requires system calls to access kernel services
- Runs with restricted privileges
- Provides isolation between processes

This separation enhances system stability and security by preventing user applications from directly accessing hardware or interfering with other applications.

### Kernel Versions

Linux kernel uses a versioning scheme consisting of three or four numbers:

`<major>.<minor>.<patch>-<distribution-specific>`

For example, in kernel version `5.10.76-linuxkit`:
- `5` is the major version
- `10` is the minor version
- `76` is the patch level
- `linuxkit` is the distribution-specific tag

To check your kernel version, use the following commands:

```bash
uname -r          # Display kernel release version
uname -a          # Display all system information including kernel
```

### Working with Hardware

Linux provides several commands to get information about hardware:

```bash
sudo dmesg                                  # Display kernel messages, including hardware detection
lspci                                       # List PCI devices
lsusb                                       # List USB devices
lsblk                                       # List block devices (storage)
sudo lshw                                   # Comprehensive hardware listing
lscpu                                       # Display CPU information
lsmem --summary                             # Display memory information
free -m                                     # Display memory usage in megabytes
free -g                                     # Display memory usage in gigabytes
free -k                                     # Display memory usage in kilobytes
udevadm info --query=path --name=/dev/sda5  # Query device information
udevadm monitor                             # Monitor udev events
```

## Linux Boot Sequence

The Linux boot process consists of several stages that occur in sequence after powering on the system. Understanding this process is crucial for troubleshooting boot problems and configuring system startup behavior.

### BIOS/UEFI Stage

1. **Power-On Self Test (POST)**:
   - Basic hardware check performed by the BIOS/UEFI
   - Verifies essential hardware components (CPU, memory, storage)
   - Initializes hardware and sets up the environment
  
2. **Boot Device Selection**:
   - BIOS/UEFI looks for bootable devices based on the boot order configuration
   - Identifies the Master Boot Record (MBR) for BIOS or EFI System Partition (ESP) for UEFI

### Boot Loader Stage

1. **Boot Loader Execution**:
   - GRUB2 (GRand Unified Bootloader version 2) is the most common Linux boot loader
   - Displays boot menu with available operating systems and kernel options
   - Allows selection of kernel version and boot parameters

2. **Boot Loader Functions**:
   - Loads the selected kernel into memory
   - Passes initial RAM disk (initrd/initramfs) to the kernel
   - Provides kernel parameters and boot options

### Kernel Initialization

1. **Kernel Loading**:
   - Kernel is decompressed and loaded into memory
   - initrd/initramfs (temporary root file system) is mounted
   - Essential drivers needed to mount the real root file system are loaded

2. **Hardware Detection**:
   - Kernel detects and initializes hardware
   - Loads appropriate device drivers
   - Sets up memory management

3. **Root File System Mount**:
   - Kernel mounts the actual root file system
   - Switches from the temporary initrd/initramfs to the real root file system

### systemd Initialization

1. **Init Process**:
   - systemd (PID 1) is started as the first user-space process
   - In older systems, this might be SysV init instead of systemd
   - Check which init system is used:
     ```bash
     ls -l /sbin/init
     ```

2. **System Initialization**:
   - systemd reads its configuration files
   - Brings the system to the default target (runlevel)
   - Starts system services in parallel

3. **User Space Initialization**:
   - Services are started according to dependencies
   - Network, filesystem, and other services become available
   - Display manager starts (for systems with GUI)
   - System becomes ready for user login

## Runlevels and Targets

Linux uses the concept of runlevels (in SysV init) or targets (in systemd) to define the state of the system and which services should be running.

### Traditional SysV Runlevels

In older SysV init systems, there are 7 standard runlevels (0-6):

| Runlevel | Description | Purpose |
|----------|-------------|---------|
| 0 | Halt | System shutdown |
| 1 | Single-user mode | Maintenance and recovery (no networking) |
| 2 | Multi-user mode | Basic multi-user without networking (rarely used) |
| 3 | Multi-user with networking | Full multi-user text mode (no GUI) |
| 4 | User-definable | Typically not used (distribution specific) |
| 5 | Multi-user with GUI | Full multi-user with network and graphical interface |
| 6 | Reboot | System restart |

Check the current runlevel using:
```bash
runlevel
```

### systemd Targets

Modern Linux distributions use systemd targets instead of runlevels:

| systemd Target | SysV Equivalent | Description |
|----------------|----------------|-------------|
| poweroff.target | 0 | Shutdown the system |
| rescue.target | 1 | Single-user mode/rescue shell |
| multi-user.target | 3 | Multi-user with networking (no GUI) |
| graphical.target | 5 | Multi-user with networking and GUI |
| reboot.target | 6 | Reboot the system |
| emergency.target | - | Emergency shell for system recovery |

### Managing Targets

View the current default target:
```bash
systemctl get-default
```

Set a different default target:
```bash
systemctl set-default multi-user.target    # Text-based login
systemctl set-default graphical.target     # GUI login
```

Check the target configuration:
```bash
ls -ltr /etc/systemd/system/default.target
```

Change to a different target temporarily:
```bash
systemctl isolate multi-user.target        # Switch to text mode
systemctl isolate graphical.target         # Switch to GUI mode
```

## File Types in Linux

Linux treats everything as a file, but different types of files serve various purposes in the system.

### Regular Files

These are the most common files containing data, text, or program instructions.

Types of regular files:
- **Text files**: Human-readable content (configuration files, scripts)
- **Binary files**: Executable programs, libraries, compiled code
- **Data files**: Files with specific formats for applications (images, documents)

### Directories

Directories are special files that contain references to other files and directories, creating the file system hierarchy.

```bash
ls -ld /home/username/     # View directory attributes
```

### Special Files

Linux has several types of special files, each serving a specific purpose:

1. **Character Device Files**:
   - Provide unbuffered, direct access to hardware
   - Transfer data character by character
   - Examples: terminals, keyboards, serial ports
   - Usually found in `/dev`

2. **Block Device Files**:
   - Provide buffered access to hardware
   - Transfer data in blocks (more efficient for large data)
   - Examples: hard drives, USB drives, CD-ROMs
   - Usually found in `/dev`

3. **Link Files**:
   - **Hard Links**: 
     - Additional directory entries pointing to the same inode
     - Cannot cross file system boundaries
     - Cannot link to directories (usually)
   
   - **Symbolic Links (Soft Links)**:
     - Special files containing a reference (path) to another file
     - Can link across file systems
     - Can link to directories
     - Broken if the target is deleted

4. **Socket Files**:
   - Enable inter-process communication
   - Allow processes to exchange data
   - Examples: X11 sockets, systemd sockets
   - Usually found in `/run` or `/tmp`

5. **Named Pipes (FIFOs)**:
   - Allow communication between processes
   - Data written to a pipe can be read by another process
   - Exist as named entities in the file system

### Identifying File Types

Linux provides several ways to identify file types:

1. Using the `file` command:
```bash
file /home/username           # Identifies as a directory
file bash-script.sh           # Identifies as a shell script
file .insync1000.sock         # Identifies as a socket
file /home/username/link      # Identifies as a symbolic link
```

2. Using `ls -l` (first character of the output):
```
- Regular file
d Directory
l Symbolic link
c Character device
b Block device
s Socket
p Named pipe
```

Example:
```bash
ls -l /dev/sda
# brw-rw---- 1 root disk 8, 0 Jan 28 10:04 /dev/sda
# The 'b' indicates a block device

ls -l /dev/tty
# crw-rw-rw- 1 root tty 5, 0 Jan 28 10:04 /dev/tty
# The 'c' indicates a character device
```

## File System Hierarchy

Linux follows the Filesystem Hierarchy Standard (FHS), which defines the directory structure and content in Linux distributions.

### Root Directory Structure

The file system starts at the root directory (`/`), with all other directories branching from it.

```
/
├── bin/       - Essential user binaries
├── boot/      - Boot loader files and kernel
├── dev/       - Device files
├── etc/       - System configuration files
├── home/      - User home directories
├── lib/       - Essential shared libraries
├── media/     - Mount points for removable media
├── mnt/       - Mount points for temporary filesystems
├── opt/       - Optional add-on applications
├── proc/      - Process and kernel information
├── root/      - Root user's home directory
├── run/       - Runtime variable data
├── sbin/      - System binaries
├── srv/       - Service data
├── sys/       - Virtual filesystem for system information
├── tmp/       - Temporary files
├── usr/       - User utilities and applications
└── var/       - Variable files (logs, spool, cache)
```

### Important Directories

1. **/bin and /sbin**:
   - Essential command binaries for all users (/bin)
   - Essential system binaries for system administration (/sbin)
   - In modern distributions, often symbolic links to /usr/bin and /usr/sbin

2. **/boot**:
   - Contains boot loader files, kernel images, and initial RAM disk images
   - Usually a separate partition

3. **/dev**:
   - Contains device files representing hardware devices
   - Managed by the udev system

4. **/etc**:
   - System-wide configuration files
   - No executable binaries
   - Configuration for system services and applications

5. **/home**:
   - User home directories
   - Personal files, user-specific configurations
   - Usually a separate partition

6. **/lib and /lib64**:
   - Essential shared libraries for /bin and /sbin
   - Kernel modules

7. **/proc and /sys**:
   - Virtual file systems providing information about running processes and system
   - Interface to kernel data structures

8. **/usr**:
   - Secondary hierarchy for user data
   - Contains non-essential utilities, applications, libraries, and documentation
   - Usually the largest directory in terms of disk usage

9. **/var**:
   - Variable data files
   - Includes logs, spool directories, and cache data
   - Content expected to grow in size
   - Often a separate partition

### Configuration Files

Important configuration files and directories:

- **/etc/passwd**: User account information
- **/etc/shadow**: Encrypted user passwords
- **/etc/group**: Group information
- **/etc/fstab**: File system mount configuration
- **/etc/hosts**: Static host name to IP mapping
- **/etc/resolv.conf**: DNS resolver configuration
- **/etc/sysconfig/**: System configuration files (Red Hat-based systems)
- **/etc/default/**: Default values for various utilities (Debian-based systems)
- **/etc/systemd/**: systemd configuration files