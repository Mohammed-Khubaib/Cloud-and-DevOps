# Working with Shell - Part I

## Table of Contents
- [Introduction to Shell](#introduction-to-shell)
  - [What is a Shell?](#what-is-a-shell)
  - [Shell vs Terminal](#shell-vs-terminal)
- [Types of Shell](#types-of-shell)
  - [Bash Shell](#bash-shell)
  - [Other Common Shells](#other-common-shells)
  - [Identifying Your Shell](#identifying-your-shell)
- [Basic Linux Commands](#basic-linux-commands)
  - [Navigation Commands](#navigation-commands)
  - [File and Directory Management](#file-and-directory-management)
  - [Directory Stack Commands](#directory-stack-commands)
  - [File Viewing Commands](#file-viewing-commands)
  - [System Information Commands](#system-information-commands)
- [Command Line Help](#command-line-help)
  - [Man Pages](#man-pages)
  - [Info Command](#info-command)
  - [Help Options](#help-options)
  - [Apropos and Whatis](#apropos-and-whatis)
- [Bash Prompt Customization](#bash-prompt-customization)
  - [Understanding the Default Prompt](#understanding-the-default-prompt)
  - [Customizing Your Prompt](#customizing-your-prompt)

## Introduction to Shell

### What is a Shell?

A shell is a command-line interpreter that provides a user interface for the Unix/Linux operating system. It acts as an intermediary between the user and the kernel, allowing users to interact with the system by executing commands.

The shell:
- Interprets commands typed by the user
- Executes programs and utilities
- Provides programming constructs (variables, loops, conditionals)
- Manages input/output redirection and piping
- Offers environment control

### Shell vs Terminal

Many people confuse shell and terminal:

- **Terminal**: A program that provides a text-based interface to the shell. Examples include GNOME Terminal, Konsole, xterm, and iTerm2.
- **Shell**: The command interpreter that processes commands and returns output. Examples include Bash, Zsh, and Fish.

Think of the terminal as the window and the shell as the engine processing your commands.

## Types of Shell

Linux supports multiple shells, each with its own features and syntax. The shell can be identified by examining the value of the `$SHELL` environment variable:

```bash
echo $SHELL
```

### Bash Shell

Bash (Bourne Again SHell) is the default shell for most Linux distributions. It was created as an enhanced version of the original Bourne Shell (sh) and includes features from other shells like the Korn Shell (ksh) and C Shell (csh).

Key Bash features:
- Command history (accessible via up/down arrows)
- Tab completion
- Aliases
- Command substitution
- Job control
- Scripting capabilities with conditionals, loops, and functions

### Other Common Shells

While Bash is the most common, several other shells are worth knowing:

1. **sh** (Bourne Shell): The original Unix shell
2. **zsh** (Z Shell): An extended version of Bash with improved features
3. **fish** (Friendly Interactive Shell): A user-friendly shell with modern features
4. **ksh** (Korn Shell): A powerful shell with strong scripting capabilities
5. **csh/tcsh** (C Shell): A shell with C-like syntax

### Identifying Your Shell

To determine the type of a command, use the `type` command:

```bash
type echo
type cd
type bash
```

This will show if the command is a shell builtin, an executable file, or an alias.

## Basic Linux Commands

### Navigation Commands

```bash
pwd         # Print working directory
cd          # Change to home directory
cd /path    # Change to specified directory
cd ..       # Move up one directory
cd -        # Return to previous directory
ls          # List directory contents
ls -l       # Long format listing
ls -a       # Show hidden files
ls -lh      # Human-readable file sizes
ls -R       # Recursive listing
```

### File and Directory Management

```bash
touch file.txt         # Create empty file or update timestamp
mkdir directory        # Create directory
mkdir -p dir1/dir2     # Create parent directories as needed
rm file.txt            # Remove file
rm -r directory        # Remove directory and contents
rm -f file.txt         # Force remove without confirmation
cp file1 file2         # Copy file1 to file2
cp -r dir1 dir2        # Copy directory recursively
mv file1 file2         # Move/rename file1 to file2
```

### Directory Stack Commands

The directory stack allows you to store and retrieve directories:

```bash
pushd /path/to/dir     # Push directory onto stack and change to it
popd                   # Pop top directory off stack and change to it
dirs                   # Display directory stack
```

### File Viewing Commands

For viewing file contents:

```bash
cat file.txt           # Display entire file content
more file.txt          # Page through file (space to advance, q to quit)
less file.txt          # More capable pager (arrows to navigate, / to search, q to quit)
head file.txt          # Display first 10 lines
head -n 20 file.txt    # Display first 20 lines
tail file.txt          # Display last 10 lines
tail -n 20 file.txt    # Display last 20 lines
tail -f file.txt       # Follow file additions in real-time
```

Key differences between `more` and `less`:
- `more`: Basic pager; space to advance, b to go back
- `less`: Advanced pager; arrow keys to navigate, / to search, q to quit

### System Information Commands

```bash
uname                  # Print system information
uname -a               # Print all system information
uname -r               # Print kernel release
date                   # Display current date and time
whoami                 # Display current user
who                    # Show who is logged in
w                      # Show who is logged in and what they're doing
```

## Command Line Help

Linux provides several ways to get help about commands.

### Man Pages

The `man` (manual) command is the primary way to access documentation:

```bash
man command            # Display manual page for command
man 5 passwd           # Display section 5 manual page for passwd
man -k keyword         # Search for keyword in man pages
```

Man pages are divided into numbered sections:
1. User commands
2. System calls
3. C library functions
4. Special files
5. File formats
6. Games
7. Miscellaneous
8. System administration commands

### Info Command

The `info` command provides more extensive documentation:

```bash
info command           # Display info documentation for command
```

### Help Options

Most commands support a `--help` or `-h` option:

```bash
command --help         # Display brief help message
ls --help
git --help
```

For shell built-in commands, use the `help` command:

```bash
help cd                # Get help for the cd builtin
```

### Apropos and Whatis

To find relevant commands:

```bash
apropos keyword        # Search for commands related to keyword
whatis command         # Display one-line description of command
```

Example:
```bash
apropos git            # Find commands related to git
whatis git             # Show what git is
```

For Git specifically, you can use:
```bash
git help -a            # List all git commands
git help command       # Get help for a specific git command
git help status        # Help for git status
```

## Bash Prompt Customization

### Understanding the Default Prompt

The Bash prompt is controlled by the `PS1` environment variable. To see your current prompt setting:

```bash
echo $PS1
```

A typical default prompt might look like:
```
[\u@\h \W]\$
```

Where:
- `\u` - Username
- `\h` - Hostname
- `\W` - Current directory (basename only)
- `\$` - # for root, $ for normal users

### Customizing Your Prompt

You can modify your prompt by changing the PS1 variable in your `~/.bashrc` file:

```bash
# Example prompt customization
PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
```

Common prompt escape sequences:
- `\u` - Username
- `\h` - Hostname
- `\H` - Full hostname
- `\w` - Current directory (full path)
- `\W` - Current directory (basename only)
- `\d` - Date in weekday month day format
- `\t` - Time in 24-hour format
- `\T` - Time in 12-hour format
- `\@` - Time in 12-hour am/pm format
- `\n` - Newline
- `\$` - # for root, $ for normal users

Color codes:
- `\[\033[00m\]` - Reset color
- `\[\033[01;32m\]` - Bold green
- `\[\033[01;34m\]` - Bold blue
- `\[\033[01;31m\]` - Bold red

To make the changes permanent, add your PS1 customization to your `~/.bashrc` file and then execute:

```bash
source ~/.bashrc
```

This will reload your bash configuration with the new prompt.