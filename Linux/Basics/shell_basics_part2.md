# Linux Basics: Working with Shell - II

## Table of Contents
1. [File Compression and Archival](#file-compression-and-archival)
   - [Viewing File Sizes](#viewing-file-sizes)
   - [Archiving with TAR](#archiving-with-tar)
   - [Compression Tools](#compression-tools)
   - [Decompression Methods](#decompression-methods)
   - [Reading Compressed Files](#reading-compressed-files)
2. [Searching for Files and Patterns](#searching-for-files-and-patterns)
   - [Locating Files](#locating-files)
   - [Using Find Command](#using-find-command)
   - [Using GREP for Pattern Matching](#using-grep-for-pattern-matching)
3. [I/O Redirection](#io-redirection)
   - [Standard Input, Output, and Error](#standard-input-output-and-error)
   - [Redirection Operators](#redirection-operators)
   - [Command Line Pipes](#command-line-pipes)
   - [Using tee Command](#using-tee-command)
4. [VI Editor](#vi-editor)
   - [Starting and Exiting VI](#starting-and-exiting-vi)
   - [VI Modes](#vi-modes)
   - [Navigation Shortcuts](#navigation-shortcuts)
   - [Editing Shortcuts](#editing-shortcuts)
   - [Saving and Quitting Shortcuts](#saving-and-quitting-shortcuts)
   - [Advanced VI Commands](#advanced-vi-commands)

## File Compression and Archival

Working with files in Linux often requires managing, archiving, and compressing them for easier storage and transfer. Let's explore the tools and techniques available in Linux for these tasks.

### Viewing File Sizes

Before compressing or archiving files, it's essential to understand their sizes. Linux provides several commands to view file sizes:

| Command | Description | Example |
|---------|-------------|---------|
| `du -sk filename` | Shows file size in kilobytes | `du -sk test.txt` |
| `du -sh filename` | Shows file size in human-readable format | `du -sh test.txt` |
| `ls -lh filename` | Lists file with size in human-readable format | `ls -lh test.txt` |

```bash
# Examples of viewing file sizes
du -sk test.txt    # Size in kilobytes
du -sh test.txt    # Size in human-readable format (KB, MB, GB)
ls -lh test.txt    # Lists file with permissions and human-readable size
```

### Archiving with TAR

TAR (Tape Archive) is a common utility in Linux used to bundle multiple files into a single archive file, commonly referred to as a "tarball".

| Option | Description |
|--------|-------------|
| `-c` | Create a new archive |
| `-f` | Specify archive filename |
| `-v` | Verbose mode (shows files being processed) |
| `-t` | List contents of an archive |
| `-x` | Extract files from an archive |
| `-z` | Compress archive using gzip |
| `-j` | Compress archive using bzip2 |
| `-J` | Compress archive using xz |
| `-C` | Change to specified directory before performing operation |

```bash
# Basic tar operations
tar -cf test.tar file1 file2 file3           # Create a tar archive
tar -zcf test.tar.gz file1 file2 file3       # Create a gzipped tar archive
tar -jcf test.tar.bz2 file1 file2 file3      # Create a bzip2 compressed tar archive
tar -Jcf test.tar.xz file1 file2 file3       # Create an xz compressed tar archive

# Listing contents of a tar archive
tar -tf test.tar                              # List contents without extracting
tar -tvf test.tar                             # Detailed listing with file permissions and sizes

# Extracting from a tar archive
tar -xf test.tar                              # Extract all files
tar -xf test.tar file1                        # Extract only specific file(s)
tar -xf test.tar -C /path/to/extract          # Extract to a specific directory
```

### Compression Tools

Linux offers several compression utilities, each with its own compression algorithm and efficiency:

| Tool | File Extension | Command to Compress | Typical Usage |
|------|---------------|---------------------|---------------|
| gzip | .gz | `gzip filename` | Fast, good compression ratio |
| bzip2 | .bz2 | `bzip2 filename` | Better compression than gzip but slower |
| xz | .xz | `xz filename` | Best compression ratio, but slowest |

```bash
# Compression commands
gzip test.txt       # Creates test.txt.gz and removes original file
bzip2 test.txt      # Creates test.txt.bz2 and removes original file
xz test.txt         # Creates test.txt.xz and removes original file

# Preserve original file during compression
gzip -k test.txt    # Keep original file
bzip2 -k test.txt   # Keep original file
xz -k test.txt      # Keep original file

# Compress with different compression levels (1-9, where 9 is highest)
gzip -9 test.txt    # Maximum compression
bzip2 -1 test.txt   # Fastest compression
xz -6 test.txt      # Default level compression
```

### Decompression Methods

Each compression tool has its corresponding decompression command:

```bash
# Decompression commands
gunzip test.txt.gz      # or gzip -d test.txt.gz
bunzip2 test.txt.bz2    # or bzip2 -d test.txt.bz2
unxz test.txt.xz        # or xz -d test.txt.xz

# Decompressing to stdout (without creating a file)
gzip -dc test.txt.gz    # -c outputs to stdout, -d decompresses
bzip2 -dc test.txt.bz2  # Same as above for bzip2
xz -dc test.txt.xz      # Same as above for xz
```

### Reading Compressed Files

Linux provides specialized tools to view the contents of compressed files without decompressing them:

```bash
# Reading compressed files directly
zcat file.txt.gz        # For gzip compressed files
bzcat file.txt.bz2      # For bzip2 compressed files
xzcat file.txt.xz       # For xz compressed files

# Variations for viewing
zless file.txt.gz       # Page through gzipped file
bzless file.txt.bz2     # Page through bzip2 compressed file
xzless file.txt.xz      # Page through xz compressed file

# Grep through compressed files
zgrep "pattern" file.txt.gz    # Search in gzipped file
bzgrep "pattern" file.txt.bz2  # Search in bzip2 compressed file
xzgrep "pattern" file.txt.xz   # Search in xz compressed file
```

## Searching for Files and Patterns

Linux provides powerful tools for searching both files and their contents.

### Locating Files

The `locate` command provides a quick way to find files by name from a database:

```bash
# Basic locate usage
locate filename         # Find files named "filename"
locate -i filename      # Case-insensitive search

# Update the locate database
sudo updatedb           # Must be run to update the database after file changes

# Limit search by pattern or location
locate "*.txt"          # Find all .txt files
locate -r "file[0-9]+"  # Using regular expressions
```

Note: The `locate` command relies on a database that is typically updated once a day by a cron job. Use `updatedb` to manually update this database.

### Using Find Command

The `find` command is more powerful and flexible than `locate`, allowing for searching by various criteria:

```bash
# Basic find usage
find /path/to/search -name "filename"      # Find by exact name
find /home -name "*.txt"                   # Find all .txt files
find / -name "file.txt" 2>/dev/null        # Suppress permission denied errors

# Find by file type
find /home -type f                         # Find regular files
find /home -type d                         # Find directories
find /home -type l                         # Find symbolic links

# Find by size
find /home -size +10M                      # Files larger than 10 MB
find /home -size -1M                       # Files smaller than 1 MB
find /home -size 5M                        # Files exactly 5 MB

# Find by permissions
find /home -perm 644                       # Find files with exact permissions
find /home -perm -u=r                      # Find files readable by owner

# Find by ownership
find /home -user username                  # Find files owned by user
find /home -group groupname                # Find files owned by group

# Find by time
find /home -mtime -7                       # Modified in the last 7 days
find /home -atime +30                      # Accessed more than 30 days ago
find /home -ctime 0                        # Changed today

# Combining criteria
find /home -name "*.log" -size +100M       # Large log files
find /home -type f -not -name "*.txt"      # Files that are not .txt

# Executing commands on found files
find /home -name "*.tmp" -delete           # Delete all .tmp files
find /home -name "*.log" -exec gzip {} \;  # Compress all log files
find /home -type f -exec chmod 644 {} \;   # Change permissions
```

### Using GREP for Pattern Matching

GREP (Global Regular Expression Print) is used to search for text patterns within files:

| Option | Description | Example |
|--------|-------------|---------|
| `-i` | Case insensitive search | `grep -i "text" file.txt` |
| `-r` | Recursive search in directory | `grep -r "text" /home` |
| `-v` | Invert match (non-matching lines) | `grep -v "text" file.txt` |
| `-w` | Match whole words only | `grep -w "word" file.txt` |
| `-n` | Show line numbers | `grep -n "text" file.txt` |
| `-l` | Show only filenames with matches | `grep -l "text" *.txt` |
| `-c` | Count matching lines | `grep -c "text" file.txt` |
| `-A n` | Show n lines after match | `grep -A2 "text" file.txt` |
| `-B n` | Show n lines before match | `grep -B1 "text" file.txt` |
| `-C n` | Show n lines before and after | `grep -C1 "text" file.txt` |
| `-E` | Use extended regular expressions | `grep -E "pattern1|pattern2" file.txt` |
| `-F` | Fixed strings (no regex) | `grep -F "literal$text" file.txt` |

```bash
# Basic grep examples
grep "some text" file.txt                 # Search for "some text" in file.txt
grep -i "some text" file.txt              # Case-insensitive search
grep -r "some text" /home/xyz             # Recursive search in directory
grep -v "some text" file.txt              # Show lines NOT containing "some text"
grep -w "some text" file.txt              # Match only whole words
grep -vw "some text" file.txt             # Combine options (not whole word)

# Context control
grep -A1 "some text" file.txt             # Show 1 line after match
grep -An "some text" file.txt             # Show n lines after match
grep -B1 "some text" file.txt             # Show 1 line before match
grep -A1 -B1 "some text" file.txt         # Show 1 line before and after
grep -C2 "some text" file.txt             # Show 2 lines before and after (shorthand)

# Regular expressions with grep
grep "^start" file.txt                    # Lines starting with "start"
grep "end$" file.txt                      # Lines ending with "end"
grep -E "pattern1|pattern2" file.txt      # Either pattern1 or pattern2
grep "[0-9]+" file.txt                    # One or more digits
grep "^[A-Z].*\.$" file.txt               # Starts with capital, ends with period

# Grep with other commands
ps aux | grep "process"                   # Find a running process
history | grep "command"                  # Find command in history
cat file.txt | grep -v "^#"               # Remove comment lines
```

## I/O Redirection

Input/Output (I/O) redirection is a powerful feature in Linux that allows the manipulation of input and output streams.

### Standard Input, Output, and Error

In Linux, there are three standard file descriptors:

| File Descriptor | Name | Description | Default Destination |
|-----------------|------|-------------|---------------------|
| 0 | stdin | Standard Input | Keyboard |
| 1 | stdout | Standard Output | Terminal |
| 2 | stderr | Standard Error | Terminal |

### Redirection Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `>` | Redirect stdout to a file (overwrite) | `command > file.txt` |
| `>>` | Redirect stdout to a file (append) | `command >> file.txt` |
| `2>` | Redirect stderr to a file | `command 2> errors.txt` |
| `2>>` | Append stderr to a file | `command 2>> errors.txt` |
| `&>` | Redirect both stdout and stderr | `command &> all_output.txt` |
| `<` | Take input from a file | `command < input.txt` |
| `<<` | Here document (input until delimiter) | `command << EOF ... EOF` |

```bash
# Standard output redirection
echo $SHELL > shell.txt                   # Write shell name to file (overwrites)
echo "This is a bash shell" >> shell.txt   # Append text to file

# Standard error redirection
cat missing_file 2> error.txt             # Redirect error message to file
cat missing_file 2>> error_log.txt        # Append error message to file

# Discarding output
cat missing_file 2> /dev/null             # Discard error messages
find / -name "*.tmp" 2>/dev/null          # Only show successful results

# Combining stdout and stderr
ls -la > output.txt 2>&1                  # Redirect both to same file (old syntax)
ls -la &> output.txt                      # Redirect both (new syntax)
ls -la >> output.txt 2>&1                 # Append both to same file

# Input redirection
sort < unsorted.txt                       # Sort contents of file
mail -s "Subject" user@example.com < message.txt  # Send email with content

# Here document (multiline input)
cat << EOF > script.sh
#!/bin/bash
echo "This is a generated script"
exit 0
EOF
```

### Command Line Pipes

Pipes (`|`) connect the output of one command to the input of another:

```bash
# Basic pipe examples
ls -l | grep "Aug"                        # List files modified in August
cat file.txt | grep "error" | wc -l       # Count error occurrences
ps aux | grep apache | grep -v grep       # Find Apache processes

# More complex examples
find /var/log -name "*.log" | xargs ls -lh  # List all log files with sizes
cat /etc/passwd | cut -d: -f1 | sort       # List all users alphabetically
du -sh /home/* | sort -hr                   # Sort home directories by size
```

### Using tee Command

The `tee` command reads from standard input and writes to both standard output and files:

```bash
# Basic tee usage
echo $SHELL | tee shell.txt                # Display and save to file
echo "This is a bash shell" | tee -a shell.txt  # Append to file

# tee with pipes
ls -l | tee file_list.txt | grep "Aug"      # Save and filter output
cat log.txt | grep "ERROR" | tee errors.txt | wc -l  # Save errors and count them

# Multiple output files
echo "test" | tee file1.txt file2.txt       # Write to multiple files
find /etc -type f | tee files.txt | wc -l   # Save list and count
```

## VI Editor

VI is a powerful text editor available on virtually all Linux distributions. Its successor, VIM (VI Improved), offers enhanced functionality but maintains the same core commands.

### Starting and Exiting VI

```bash
# Starting VI
vi filename              # Open existing file or create new file
vi +10 filename          # Open file and go to line 10
vi +/pattern filename    # Open file and go to first occurrence of pattern
vi -R filename           # Open file in read-only mode (view mode)

# Exiting VI
:q                       # Quit (fails if there are unsaved changes)
:q!                      # Quit and discard unsaved changes
:wq                      # Save and quit
:x                       # Save and quit (same as :wq)
ZZ                       # Save and quit (shortcut for :wq)
```

### VI Modes

VI operates in three primary modes:

1. **Command Mode** (default): Used for navigation and entering commands
2. **Insert Mode**: Used for editing text
3. **Ex Mode**: Used for executing commands (started with `:`)

### Navigation Shortcuts

| Command | Description |
|---------|-------------|
| `h` | Move left |
| `j` | Move down |
| `k` | Move up |
| `l` | Move right |
| `w` | Move to start of next word |
| `b` | Move to start of previous word |
| `e` | Move to end of current word |
| `0` | Move to start of line |
| `$` | Move to end of line |
| `gg` | Go to first line of file |
| `G` | Go to last line of file |
| `nG` | Go to line n |
| `:n` | Go to line n |
| `Ctrl+f` | Page down |
| `Ctrl+b` | Page up |
| `Ctrl+d` | Half page down |
| `Ctrl+u` | Half page up |
| `%` | Move to matching bracket |
| `{` | Move to start of paragraph |
| `}` | Move to end of paragraph |

### Editing Shortcuts

| Command | Description |
|---------|-------------|
| `i` | Insert before cursor |
| `I` | Insert at beginning of line |
| `a` | Append after cursor |
| `A` | Append at end of line |
| `o` | Open new line below cursor |
| `O` | Open new line above cursor |
| `r` | Replace single character |
| `R` | Replace mode (overwrite) |
| `s` | Substitute character |
| `S` | Substitute entire line |
| `x` | Delete character under cursor |
| `X` | Delete character before cursor |
| `dd` | Delete current line |
| `dw` | Delete word |
| `d$` | Delete to end of line |
| `d0` | Delete to beginning of line |
| `dG` | Delete to end of file |
| `yy` | Yank (copy) current line |
| `yw` | Yank word |
| `y$` | Yank to end of line |
| `p` | Paste after cursor |
| `P` | Paste before cursor |
| `u` | Undo last change |
| `Ctrl+r` | Redo last undone change |
| `.` | Repeat last command |

### Saving and Quitting Shortcuts

| Command | Description |
|---------|-------------|
| `:w` | Write (save) file |
| `:w filename` | Save as filename |
| `:wq` | Save and quit |
| `:x` | Save and quit |
| `ZZ` | Save and quit |
| `:q` | Quit (fails if unsaved changes) |
| `:q!` | Quit without saving |
| `:wq!` | Save and quit (override protection) |

### Advanced VI Commands

| Command | Description |
|---------|-------------|
| `/pattern` | Search forward for pattern |
| `?pattern` | Search backward for pattern |
| `n` | Repeat last search (same direction) |
| `N` | Repeat last search (opposite direction) |
| `:%s/old/new/g` | Replace all occurrences of "old" with "new" |
| `:s/old/new/g` | Replace all occurrences in current line |
| `:n,m s/old/new/g` | Replace all occurrences between lines n and m |
| `!!command` | Replace current line with command output |
| `:r filename` | Insert contents of filename |
| `:r !command` | Insert output of command |
| `v` | Start visual mode (character selection) |
| `V` | Start visual line mode (line selection) |
| `Ctrl+v` | Start visual block mode (block selection) |
| `:split` | Split window horizontally |
| `:vsplit` | Split window vertically |
| `Ctrl+w + arrow` | Navigate between windows |
| `:set number` | Show line numbers |
| `:set nonumber` | Hide line numbers |
| `:set syntax=on` | Enable syntax highlighting (in Vim) |
| `:help` | Open help |