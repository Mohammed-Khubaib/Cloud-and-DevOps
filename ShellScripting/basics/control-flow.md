# Shell Scripting - Flow Control

## Table of Contents
- [Conditional Logic](#conditional-logic)
  - [If Statements](#if-statements)
  - [Test Command](#test-command)
  - [Comparison Operators](#comparison-operators)
  - [File Test Operators](#file-test-operators)
  - [Logical Operators](#logical-operators)
- [Case Statements](#case-statements)
- [Loops](#loops)
  - [For Loops](#for-loops)
  - [While Loops](#while-loops)
  - [Until Loops](#until-loops)
  - [Select Loops](#select-loops)
  - [Loop Control](#loop-control)
- [Examples](#examples)
  - [Conditional Logic Example](#conditional-logic-example)
  - [Case Statement Example](#case-statement-example)
  - [For Loop Examples](#for-loop-examples)
  - [While Loop Examples](#while-loop-examples)
  - [Combined Flow Control Example](#combined-flow-control-example)

## Conditional Logic

Conditional logic allows scripts to make decisions and execute different commands based on conditions.

### If Statements

The basic syntax for if statements in shell scripting is:

```bash
if [ condition ]; then
    # commands to execute if condition is true
elif [ another_condition ]; then
    # commands to execute if another_condition is true
else
    # commands to execute if all conditions are false
fi
```

Alternative forms:

```bash
# Single line form
if [ condition ]; then command; fi

# Using double brackets (bash, ksh, zsh)
if [[ condition ]]; then
    # commands
fi

# Using parentheses for arithmetic evaluation
if (( arithmetic_expression )); then
    # commands
fi
```

### Test Command

The `test` command (or its equivalent `[ ]` or `[[ ]]`) evaluates expressions and returns success (0) or failure (non-zero) status:

```bash
# These are equivalent
test expression
[ expression ]

# In Bash, [[ ]] provides extended features
[[ expression ]]
```

### Comparison Operators

#### String Comparison

| Operator | Description | Example |
|----------|-------------|---------|
| `=` or `==` | Equal to | `[ "$a" = "$b" ]` |
| `!=` | Not equal to | `[ "$a" != "$b" ]` |
| `-z` | String is empty | `[ -z "$a" ]` |
| `-n` | String is not empty | `[ -n "$a" ]` |
| `<` | Less than (ASCII) | `[[ "$a" < "$b" ]]` |
| `>` | Greater than (ASCII) | `[[ "$a" > "$b" ]]` |

**Note**: String comparison with `<` and `>` requires double brackets `[[ ]]` or proper escaping in single brackets.

#### Numeric Comparison

| Operator | Description | Example |
|----------|-------------|---------|
| `-eq` | Equal to | `[ "$a" -eq "$b" ]` |
| `-ne` | Not equal to | `[ "$a" -ne "$b" ]` |
| `-lt` | Less than | `[ "$a" -lt "$b" ]` |
| `-le` | Less than or equal to | `[ "$a" -le "$b" ]` |
| `-gt` | Greater than | `[ "$a" -gt "$b" ]` |
| `-ge` | Greater than or equal to | `[ "$a" -ge "$b" ]` |

With double parentheses, you can use C-style operators:

```bash
if (( a == b )); then echo "Equal"; fi
if (( a < b )); then echo "Less than"; fi
if (( a > b )); then echo "Greater than"; fi
```

### File Test Operators

| Operator | Description |
|----------|-------------|
| `-e file` | File exists |
| `-f file` | File is a regular file |
| `-d file` | File is a directory |
| `-r file` | File is readable |
| `-w file` | File is writable |
| `-x file` | File is executable |
| `-s file` | File is not empty |
| `-L file` | File is a symbolic link |
| `-nt file` | File is newer than another file |
| `-ot file` | File is older than another file |

Examples:

```bash
if [ -f "$filename" ]; then
    echo "$filename exists and is a regular file."
fi

if [ -d "$dirname" ] && [ -w "$dirname" ]; then
    echo "$dirname exists, is a directory, and is writable."
fi
```

### Logical Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `&&` | AND | `[ "$a" -eq 1 ] && [ "$b" -eq 2 ]` |
| `\|\|` | OR | `[ "$a" -eq 1 ] \|\| [ "$b" -eq 2 ]` |
| `!` | NOT | `[ ! "$a" -eq 1 ]` |

Within double brackets, you can combine conditions more naturally:

```bash
if [[ "$a" -eq 1 && "$b" -eq 2 ]]; then
    echo "Both conditions are true"
fi

if [[ "$a" -eq 1 || "$b" -eq 2 ]]; then
    echo "At least one condition is true"
fi
```

## Case Statements

The `case` statement provides a cleaner way to match multiple values against a single variable:

```bash
case $variable in
    pattern1)
        # commands for pattern1
        ;;
    pattern2)
        # commands for pattern2
        ;;
    pattern3|pattern4)
        # commands for pattern3 or pattern4
        ;;
    *)
        # default case (optional)
        ;;
esac
```

Key points about case statements:
- Patterns can use wildcards (`*`, `?`, etc.)
- Multiple patterns can be separated with `|`
- Each command block must end with `;;`
- The `*)` pattern serves as the default case

Example:

```bash
case $fruit in
    apple)
        echo "It's an apple"
        ;;
    banana|orange)
        echo "It's a yellow or orange fruit"
        ;;
    *)
        echo "Unknown fruit"
        ;;
esac
```

## Loops

Loops allow executing a block of code repeatedly based on certain conditions.

### For Loops

The for loop executes commands for each item in a list:

#### Standard Syntax

```bash
for variable in list; do
    # commands using $variable
done
```

#### C-style Syntax (Bash)

```bash
for ((initialization; condition; increment)); do
    # commands
done
```

Examples:

```bash
# Loop through a list of values
for color in red green blue; do
    echo "Color: $color"
done

# Loop through a range of numbers
for i in {1..5}; do
    echo "Number: $i"
done

# Loop through a range with step (Bash 4.0+)
for i in {1..10..2}; do
    echo "Odd number: $i"
done

# C-style for loop
for ((i=1; i<=5; i++)); do
    echo "Count: $i"
done

# Loop through command output
for file in $(ls); do
    echo "File: $file"
done

# Loop through array
colors=("red" "green" "blue")
for color in "${colors[@]}"; do
    echo "Color: $color"
done
```

### While Loops

The while loop executes as long as the condition remains true:

```bash
while [ condition ]; do
    # commands
done
```

Examples:

```bash
# Basic while loop with counter
counter=1
while [ $counter -le 5 ]; do
    echo "Counter: $counter"
    counter=$((counter + 1))
done

# Reading file line by line
while read line; do
    echo "Line: $line"
done < filename.txt

# Infinite loop (can be broken with break)
while true; do
    echo "Press q to quit"
    read -n 1 key
    if [ "$key" = "q" ]; then
        break
    fi
done
```

### Until Loops

The until loop executes until the condition becomes true (opposite of while):

```bash
until [ condition ]; do
    # commands
done
```

Example:

```bash
counter=10
until [ $counter -le 0 ]; do
    echo "Countdown: $counter"
    counter=$((counter - 1))
    sleep 1
done
echo "Blast off!"
```

### Select Loops

The select loop creates a simple menu system:

```bash
select option in list; do
    # commands using $option
done
```

Example:

```bash
echo "Select your favorite color:"
select color in "Red" "Green" "Blue" "Quit"; do
    case $color in
        "Red")
            echo "You chose red"
            ;;
        "Green")
            echo "You chose green"
            ;;
        "Blue")
            echo "You chose blue"
            ;;
        "Quit")
            echo "Goodbye!"
            break
            ;;
        *)
            echo "Invalid option"
            ;;
    esac
done
```

### Loop Control

Commands to control loop execution:

- `break`: Exit the current loop
- `continue`: Skip the rest of the current iteration and start the next one
- `break n`: Break out of 'n' levels of nested loops
- `continue n`: Continue at the 'n'th level of nested loops

Examples:

```bash
# Break example
for i in {1..10}; do
    if [ $i -eq 5 ]; then
        echo "Breaking at $i"
        break
    fi
    echo "Number: $i"
done

# Continue example
for i in {1..10}; do
    if [ $i -eq 5 ]; then
        echo "Skipping $i"
        continue
    fi
    echo "Number: $i"
done

# Nested loops with break levels
for i in {1..3}; do
    for j in {1..3}; do
        if [ $i -eq 2 ] && [ $j -eq 2 ]; then
            echo "Breaking out of both loops at i=$i, j=$j"
            break 2
        fi
        echo "i=$i, j=$j"
    done
done
```

## Examples

### Conditional Logic Example

```bash
#!/bin/bash

# Script to check file permissions

file_path=$1

if [ -z "$file_path" ]; then
    echo "Error: No file specified"
    echo "Usage: $0 <file_path>"
    exit 1
fi

if [ ! -e "$file_path" ]; then
    echo "Error: File does not exist"
    exit 1
elif [ -d "$file_path" ]; then
    echo "$file_path is a directory"
else
    echo "$file_path is a file"
    
    if [ -r "$file_path" ]; then
        echo "- Readable: Yes"
    else
        echo "- Readable: No"
    fi
    
    if [ -w "$file_path" ]; then
        echo "- Writable: Yes"
    else
        echo "- Writable: No"
    fi
    
    if [ -x "$file_path" ]; then
        echo "- Executable: Yes"
    else
        echo "- Executable: No"
    fi
    
    size=$(du -h "$file_path" | cut -f1)
    echo "- Size: $size"
fi
```

### Case Statement Example

```bash
#!/bin/bash

# Script to provide information about operating systems

echo "Which operating system would you like to know about?"
echo "1) Linux"
echo "2) macOS"
echo "3) Windows"
echo "4) BSD"
echo "5) Exit"

read -p "Enter your choice (1-5): " choice

case $choice in
    1)
        echo "Linux is an open-source Unix-like operating system kernel."
        echo "Popular distributions include Ubuntu, Fedora, and Debian."
        ;;
    2)
        echo "macOS is a Unix-based operating system developed by Apple."
        echo "It's known for its user-friendly interface and integration with Apple hardware."
        ;;
    3)
        echo "Windows is a proprietary operating system developed by Microsoft."
        echo "It's the most widely used desktop operating system worldwide."
        ;;
    4)
        echo "BSD (Berkeley Software Distribution) is a family of Unix-like operating systems."
        echo "FreeBSD, OpenBSD, and NetBSD are popular BSD variants."
        ;;
    5)
        echo "Goodbye!"
        exit 0
        ;;
    *)
        echo "Invalid choice. Please enter a number between 1 and 5."
        ;;
esac
```

### For Loop Examples

```bash
#!/bin/bash

# Example 1: Process files in a directory
echo "Processing files in current directory:"
for file in *.txt; do
    if [ -f "$file" ]; then
        echo "- Found text file: $file"
        wc -l "$file" | awk '{print "  Lines: " $1}'
    fi
done

# Example 2: Generate a multiplication table
echo -e "\nMultiplication table for 5:"
for i in {1..10}; do
    result=$((5 * i))
    echo "5 × $i = $result"
done

# Example 3: C-style for loop to calculate factorial
echo -e "\nCalculating factorial of 5:"
factorial=1
for ((i=1; i<=5; i++)); do
    factorial=$((factorial * i))
    echo "After multiplying by $i: $factorial"
done
echo "5! = $factorial"
```

### While Loop Examples

```bash
#!/bin/bash

# Example 1: Simple countdown
echo "Countdown from 5:"
counter=5
while [ $counter -gt 0 ]; do
    echo $counter
    counter=$((counter - 1))
    sleep 1
done
echo "Blast off!"

# Example 2: Reading data from a file
echo -e "\nReading /etc/passwd entries (first 5 lines):"
line_count=0
while read -r line && [ $line_count -lt 5 ]; do
    echo "Line $((line_count + 1)): $line"
    line_count=$((line_count + 1))
done < /etc/passwd

# Example 3: Menu-driven program
echo -e "\nSimple Calculator"
while true; do
    echo -e "\n1. Add"
    echo "2. Subtract"
    echo "3. Multiply"
    echo "4. Divide"
    echo "5. Exit"
    
    read -p "Enter your choice (1-5): " choice
    
    if [ "$choice" -eq 5 ]; then
        echo "Goodbye!"
        break
    fi
    
    read -p "Enter first number: " num1
    read -p "Enter second number: " num2
    
    case $choice in
        1)
            echo "Result: $((num1 + num2))"
            ;;
        2)
            echo "Result: $((num1 - num2))"
            ;;
        3)
            echo "Result: $((num1 * num2))"
            ;;
        4)
            if [ "$num2" -eq 0 ]; then
                echo "Error: Cannot divide by zero"
            else
                echo "Result: $((num1 / num2))"
                echo "Remainder: $((num1 % num2))"
            fi
            ;;
        *)
            echo "Invalid choice"
            ;;
    esac
done
```

### Combined Flow Control Example

```bash
#!/bin/bash

# Script to analyze files in a directory

directory=${1:-.}  # Use current directory if none specified

if [ ! -d "$directory" ]; then
    echo "Error: $directory is not a valid directory"
    exit 1
fi

echo "Analyzing directory: $directory"

# Initialize counters
total_files=0
total_dirs=0
total_size=0

# Loop through all items in the directory
for item in "$directory"/*; do
    if [ -f "$item" ]; then
        # It's a file
        total_files=$((total_files + 1))
        file_size=$(du -b "$item" | cut -f1)
        total_size=$((total_size + file_size))
        echo "File: $item (Size: $file_size bytes)"
    elif [ -d "$item" ]; then
        # It's a directory
        total_dirs=$((total_dirs + 1))
        echo "Directory: $item"
    else
        # Other types (e.g., symlinks)
        echo "Other: $item"
    fi
done

# Convert total size to human-readable format
if (( total_size > 1024 )); then
    if (( total_size > 1048576 )); then
        total_size_human=$(echo "scale=2; $total_size / 1048576" | bc)
        total_size_unit="MB"
    else
        total_size_human=$(echo "scale=2; $total_size / 1024" | bc)
        total_size_unit="KB"
    fi
else
    total_size_human=$total_size
    total_size_unit="bytes"
fi

# Display summary
echo -e "\nSummary:"
echo "Total files: $total_files"
echo "Total directories: $total_dirs"
echo "Total size: $total_size_human $total_size_unit"

# Check for empty directory
if [ $total_files -eq 0 ] && [ $total_dirs -eq 0 ]; then
    echo "This directory is empty."
fi

# Check for large files
large_files=$(find "$directory" -type f -size +1M)
if [ -n "$large_files" ]; then
    echo -e "\nWarning: The following files are larger than 1MB:"
    echo "$large_files"
fi

# Check for executable files
executable_files=$(find "$directory" -type f -executable)
if [ -n "$executable_files" ]; then
    echo -e "\nExecutable files found:"
    echo "$executable_files"
fi

# Check for hidden files
hidden_files=$(find "$directory" -name ".*")
if [ -n "$hidden_files" ]; then
    echo -e "\nHidden files found:"
    echo "$hidden_files"
fi

# Final message
echo -e "\nAnalysis complete."

```