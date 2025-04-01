# Linux Service Management with systemd

## Table of Contents
1. [Introduction to systemd](#introduction-to-systemd)
2. [Key Concepts](#key-concepts)
   - [Units](#units)
   - [Targets](#targets)
   - [Dependencies](#dependencies)
3. [Creating a systemd Service](#creating-a-systemd-service)
   - [Service Unit File Structure](#service-unit-file-structure)
   - [Step-by-Step Guide](#step-by-step-guide)
   - [Example Service Files](#example-service-files)
4. [systemd Tools](#systemd-tools)
   - [systemctl Commands](#systemctl-commands)
   - [journalctl](#journalctl)
   - [System Management](#system-management)
5. [Practical Examples](#practical-examples)
   - [Managing Web Servers](#managing-web-servers)
   - [Creating Custom Services](#creating-custom-services)
   - [Troubleshooting Services](#troubleshooting-services)
6. [Best Practices](#best-practices)

## Introduction to systemd

systemd is a system and service manager for Linux operating systems. It has replaced traditional init systems like SysV init or Upstart on most modern Linux distributions. systemd provides several key advantages:

- **Parallel Service Startup**: Improves boot time by starting services simultaneously when possible
- **On-Demand Service Activation**: Starts services only when needed
- **Dependency Management**: Automatically handles service dependencies
- **Process Tracking**: Tracks processes using control groups (cgroups)
- **Logging**: Provides integrated logging through the journal
- **Consistency**: Offers consistent management interfaces for all system components

systemd has become the standard initialization system for major distributions including Red Hat Enterprise Linux, CentOS, Fedora, Ubuntu, Debian, and many others.

## Key Concepts

### Units

Units are systemd's basic building blocks. Each unit represents a resource that systemd manages. The most common unit types include:

| Unit Type | File Extension | Purpose |
|-----------|----------------|---------|
| Service   | .service       | System services |
| Socket    | .socket        | IPC socket or network socket activation |
| Target    | .target        | Group of units (similar to runlevels) |
| Timer     | .timer         | Scheduled activation (cron-like functionality) |
| Mount     | .mount         | Filesystem mount points |
| Device    | .device        | Device units |
| Path      | .path          | Filesystem path monitoring |

### Targets

Targets are special unit files that group multiple units together, similar to runlevels in SysV init systems. Common targets include:

| Target | Equivalent Runlevel | Description |
|--------|---------------------|-------------|
| poweroff.target | 0 | System shutdown |
| rescue.target | 1 | Single user mode |
| multi-user.target | 3 | Multi-user, non-graphical |
| graphical.target | 5 | Multi-user, graphical |
| reboot.target | 6 | System reboot |

### Dependencies

systemd manages dependencies between units through several directives:

- **Requires**: Strict dependency; if a dependency fails, the unit will not start
- **Wants**: Soft dependency; the unit will start even if the dependency fails
- **After/Before**: Ordering information, specifying the sequence of unit activation
- **Conflicts**: Units that cannot run together with this unit
- **BindsTo**: Similar to Requires, but also causes the unit to stop if the dependency stops

## Creating a systemd Service

### Service Unit File Structure

A systemd service unit file typically consists of three sections:

1. **[Unit]**: General information about the unit, including description and dependencies
2. **[Service]**: Service-specific configuration
3. **[Install]**: Installation information, determining when the service is activated

### Step-by-Step Guide

Creating a systemd service involves the following steps:

1. **Create a Service File**: Write a unit file that describes your service
2. **Install the Service File**: Place it in the appropriate directory
3. **Enable the Service**: Configure it to start automatically if needed
4. **Start and Test the Service**: Ensure it functions as expected

Let's explore each step in detail:

#### 1. Create a Service File

Create a service file with the `.service` extension that defines your service. Here's a template:

```ini
[Unit]
Description=Description of your service
Documentation=https://example.com/documentation
After=network.target
Wants=network-online.target

[Service]
Type=simple
User=serviceuser
Group=servicegroup
ExecStart=/path/to/your/program --with --arguments
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=5s
WorkingDirectory=/path/to/working/directory
Environment="VAR1=value1" "VAR2=value2"

[Install]
WantedBy=multi-user.target
```

Key fields explained:

**[Unit] Section**:
- `Description`: User-readable description
- `Documentation`: Where to find documentation
- `After`: Start after these units
- `Wants`: Soft dependencies

**[Service] Section**:
- `Type`: How to determine if the service is ready (simple, forking, oneshot, etc.)
- `User`/`Group`: Run the service as this user/group
- `ExecStart`: Command to start the service
- `ExecReload`: Command to reload the service
- `Restart`: When to restart the service (always, on-failure, etc.)
- `RestartSec`: Time to wait before restarting
- `WorkingDirectory`: Working directory for the service
- `Environment`: Environment variables

**[Install] Section**:
- `WantedBy`: Target that will "want" this service when enabled

#### 2. Install the Service File

Place your service file in one of these locations:

- `/etc/systemd/system/`: For system-specific services (administrator created)
- `/usr/lib/systemd/system/`: For distribution-provided services (package managed)

```bash
sudo cp myservice.service /etc/systemd/system/
```

#### 3. Enable the Service

After creating the service file, reload the systemd manager configuration:

```bash
sudo systemctl daemon-reload
```

To configure the service to start at boot:

```bash
sudo systemctl enable myservice.service
```

#### 4. Start and Test the Service

Start the service:

```bash
sudo systemctl start myservice.service
```

Check its status:

```bash
sudo systemctl status myservice.service
```

### Example Service Files

#### Simple Web Server Service

```ini
[Unit]
Description=Simple HTTP Server
After=network.target

[Service]
Type=simple
User=webuser
WorkingDirectory=/var/www/html
ExecStart=/usr/bin/python3 -m http.server 8080
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

#### Database Service

```ini
[Unit]
Description=PostgreSQL Database Service
After=network.target
Wants=network-online.target

[Service]
Type=forking
User=postgres
Group=postgres
Environment=PGDATA=/var/lib/postgresql/data
ExecStart=/usr/bin/pg_ctl start -D ${PGDATA} -s -o "-c listen_addresses=0.0.0.0"
ExecReload=/usr/bin/pg_ctl reload -D ${PGDATA} -s
ExecStop=/usr/bin/pg_ctl stop -D ${PGDATA} -s -m fast
TimeoutSec=30
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

#### Backup Script Service with Timer

Service file (`backup.service`):
```ini
[Unit]
Description=Backup Script Service
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup.sh
User=backup
Group=backup
```

Timer file (`backup.timer`):
```ini
[Unit]
Description=Run backup daily

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
```

## systemd Tools

### systemctl Commands

systemctl is the primary command-line utility for managing systemd services and units:

#### Service Management

```bash
# Start a service
systemctl start <servicename>

# Stop a service
systemctl stop <servicename>

# Restart a service (stop then start)
systemctl restart <servicename>

# Reload a service configuration without stopping
systemctl reload <servicename>

# Enable a service to start at boot
systemctl enable <servicename>

# Disable a service from starting at boot
systemctl disable <servicename>

# Check the status of a service
systemctl status <servicename>

# Reload systemd manager configuration
systemctl daemon-reload
```

#### Viewing and Editing Unit Files

```bash
# View a service unit file
systemctl cat <servicename>

# Edit a service unit file
systemctl edit <servicename.service> --full

# Create a drop-in configuration file
systemctl edit <servicename.service>
```

#### System Management

```bash
# View current default target
systemctl get-default

# Change the default target
systemctl set-default <target.target>
# Example: systemctl set-default multi-user.target

# List all active units
systemctl list-units

# List all units, including inactive
systemctl list-units --all

# List all services
systemctl list-units --type=service

# View service dependencies
systemctl list-dependencies <servicename>

# Power management
systemctl poweroff    # Shutdown
systemctl reboot      # Reboot
systemctl suspend     # Suspend
```

### journalctl

journalctl is systemd's logging utility that provides access to the systemd journal. The journal collects and stores logging data from various sources including:

- Kernel messages
- System service logs
- Application logs that use systemd-journald
- Standard output and error from systemd services

Common journalctl commands:

```bash
# View all logs
journalctl

# View logs from the current boot
journalctl -b

# View logs for a specific unit
journalctl -u <UNIT>
# Example
journalctl -u docker.service

# Follow logs in real time (like tail -f)
journalctl -f

# View logs from a specific time period
journalctl --since="2023-06-01" --until="2023-06-02"

# View logs for a specific priority
journalctl -p err

# Show specific number of recent log entries
journalctl -n 100

# View kernel messages
journalctl -k
```

Additional useful journalctl commands:

```bash
# View logs from a specific executable
journalctl /usr/bin/sshd

# View logs from a specific PID
journalctl _PID=1234

# View logs with JSON output
journalctl -o json

# View logs from a specific user
journalctl _UID=1000
```

### System Management

systemd provides tools for managing system boot targets (similar to runlevels in SysV init):

```bash
# List all available targets
systemctl list-units --type=target

# Get the current default target
systemctl get-default

# Set a new default target
systemctl set-default multi-user.target  # Console mode
systemctl set-default graphical.target   # GUI mode

# Temporarily switch to a target
systemctl isolate multi-user.target

# Enter rescue mode
systemctl rescue
```

## Practical Examples

### Managing Web Servers

#### Nginx Service Management

```bash
# Start Nginx
sudo systemctl start nginx

# Enable Nginx to start at boot
sudo systemctl enable nginx

# Check Nginx status
sudo systemctl status nginx

# View Nginx logs
sudo journalctl -u nginx.service

# Reload Nginx after configuration changes
sudo systemctl reload nginx
```

#### Creating a Custom Web Application Service

```ini
[Unit]
Description=My Web Application
After=network.target postgresql.service
Requires=postgresql.service

[Service]
Type=simple
User=webapp
WorkingDirectory=/opt/mywebapp
ExecStart=/usr/bin/node app.js
Restart=always
Environment=NODE_ENV=production PORT=3000

[Install]
WantedBy=multi-user.target
```

### Creating Custom Services

#### One-Shot Backup Service

```ini
[Unit]
Description=Database Backup Service
After=postgresql.service

[Service]
Type=oneshot
User=postgres
ExecStart=/usr/local/bin/backup_database.sh
```

#### Timer to Run the Backup Daily

```ini
[Unit]
Description=Run database backup daily
Requires=backup.service

[Timer]
OnCalendar=*-*-* 02:00:00
Persistent=true

[Install]
WantedBy=timers.target
```

Enable and start the timer:

```bash
sudo systemctl enable backup.timer
sudo systemctl start backup.timer
```

### Troubleshooting Services

#### Checking Service Status

```bash
# View detailed status
sudo systemctl status myservice

# View recent logs
sudo journalctl -u myservice.service -n 50

# Follow logs in real-time
sudo journalctl -u myservice.service -f
```

#### Common Service Issues

1. **Service won't start**:
   - Check syntax in unit file: `systemd-analyze verify myservice.service`
   - Check for errors in the logs: `journalctl -u myservice.service`
   - Verify executable permissions and paths

2. **Service starts but immediately exits**:
   - Check for configuration issues in the application
   - Verify if the application needs specific environment variables
   - Check if required dependencies are running

3. **Service fails after system update**:
   - Check for path changes to executables
   - Verify compatibility with updated libraries

4. **Service configuration changes not applied**:
   - Remember to run `systemctl daemon-reload` after editing unit files
   - Restart the service to apply changes: `systemctl restart myservice`

## Best Practices

1. **Use Clear Descriptions**: Make your service descriptions clear and informative
2. **Proper Dependencies**: Accurately specify dependencies to ensure proper startup order
3. **User and Group**: Run services with the minimum required privileges
4. **Handle Failures**: Configure appropriate restart policies
5. **Environment Variables**: Use Environment directives for configuration
6. **Resource Limits**: Use resource control directives to limit service resource consumption:
   ```ini
   [Service]
   CPUQuota=30%
   MemoryLimit=512M
   ```
7. **Timeouts**: Configure appropriate timeouts for service startup and shutdown
8. **Documentation**: Include documentation references in your unit files
9. **Security Directives**: Use security directives to harden your services:
   ```ini
   [Service]
   PrivateTmp=true
   ProtectSystem=full
   ProtectHome=true
   ReadOnlyDirectories=/var /etc
   NoNewPrivileges=true
   ```