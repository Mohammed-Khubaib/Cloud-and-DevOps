# Shell Scripting - Introduction

## Table of Contents
- [Shell Scripting Basics](#shell-scripting-basics)
- [Shebang](#shebang)
- [Variables](#variables)
- [Command Line Arguments](#command-line-arguments)
- [Reading User Input](#reading-user-input)
- [Color Codes for Terminal Output](#color-codes-for-terminal-output)
- [Arithmetic Operations](#arithmetic-operations)
- [Examples](#examples)
  - [Basic Script Example](#basic-script-example)
  - [Variables and Arithmetic Example](#variables-and-arithmetic-example)
  - [Command Line Arguments Example](#command-line-arguments-example)
  - [Reading Input Example](#reading-input-example)
  - [Colorful Output Example](#colorful-output-example)

## Shell Scripting Basics

Shell scripting is a method of automating tasks in Unix/Linux environments by writing sequences of commands in a file that can be executed as a program. The shell is the command-line interpreter that provides an interface between the user and the operating system kernel.

Common shells include:
- **Bash** (Bourne Again Shell) - The most widely used shell in Linux systems
- **sh** (Bourne Shell) - The original Unix shell
- **zsh** (Z Shell) - An extended version of Bash with additional features
- **ksh** (Korn Shell) - Another extended shell with many features

To create a shell script:
1. Create a text file with the extension `.sh` (e.g., `myscript.sh`)
2. Add shell commands to the file
3. Make it executable with `chmod +x myscript.sh`
4. Execute it with `./myscript.sh`

## Shebang

The shebang (also called hashbang) is the first line of a script that specifies which interpreter should be used to execute the script. It begins with `#!` followed by the path to the interpreter.

```bash
#!/bin/bash    # Use Bash as interpreter
#!/bin/sh      # Use Bourne shell as interpreter
#!/usr/bin/env bash  # More portable way to specify Bash
```

The `#!/usr/bin/env bash` form is often preferred as it uses the `env` command to locate the interpreter in the user's PATH, making scripts more portable across systems.

## Variables

Variables in shell scripts store data that can be referenced and manipulated. In Bash, variables:
- Are created when you first assign a value
- Don't have declared types (they're essentially strings)
- Are referenced by adding a `$` prefix
- By convention, are named using uppercase for constants and lowercase for variables

```bash
# Variable assignment (no spaces around =)
name="John"
age=30
PI=3.14159

# Accessing variables
echo "Hello, $name!"
echo "You are ${age} years old."  # Braces are useful for clarity

# Special variables
echo "Current process ID: $$"
echo "Script name: $0"
```

### Variable Types:

1. **Local Variables**: Available only in the current shell
2. **Environment Variables**: Available to all processes spawned from the current shell 
3. **Shell Variables**: Special variables used by the shell itself

### Important Variable Conventions:

- No spaces around the equals sign
- Use quotes around values with spaces or special characters
- Use curly braces `${variable}` when needed for clarity or concatenation

## Command Line Arguments

Shell scripts can accept arguments passed from the command line, which are accessible through positional parameters:

| Parameter | Description |
|-----------|-------------|
| `$0`      | The name of the script |
| `$1`      | The first argument |
| `$2`      | The second argument |
| `$n`      | The nth argument |
| `$#`      | The number of arguments |
| `$*`      | All arguments as a single string |
| `$@`      | All arguments as separate strings |

Example usage:
```bash
echo "Script name: $0"
echo "First argument: $1" 
echo "Second argument: $2"
echo "Total arguments: $#"
echo "All arguments: $*"
```

## Reading User Input

The `read` command allows shell scripts to accept user input during execution:

```bash
# Basic read
echo "What is your name?"
read name
echo "Hello, $name!"

# Read with prompt
read -p "Enter your age: " age
echo "You are $age years old."

# Read with timeout
read -t 5 -p "Quick! Enter a number (5 sec timeout): " number
echo "You entered: $number"

# Read multiple values
read -p "Enter first and last name: " first_name last_name
echo "First name: $first_name, Last name: $last_name"

# Read password (without displaying input)
read -s -p "Enter password: " password
echo -e "\nPassword received"
```

### Key Read Options:

| Option | Description |
|--------|-------------|
| `-p`   | Display a prompt |
| `-s`   | Silent mode (no echo) - useful for passwords |
| `-t N` | Timeout after N seconds |
| `-n N` | Read only N characters |
| `-r`   | Raw mode (doesn't treat backslash as escape) |

## Color Codes for Terminal Output

Shell scripts can produce colored text using ANSI escape sequences:

```bash
# Format: \e[CODEm or \033[CODEm
# Reset: \e[0m

# Text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color (reset)

# Usage
echo -e "${RED}This is red text${NC}"
echo -e "${GREEN}This is green text${NC}"
echo -e "${BLUE}This is blue text${NC}"
```

### Common Color Codes:

| Code | Text Color | Code | Background |
|------|------------|------|------------|
| 30   | Black      | 40   | Black      |
| 31   | Red        | 41   | Red        |
| 32   | Green      | 42   | Green      |
| 33   | Yellow     | 43   | Yellow     |
| 34   | Blue       | 44   | Blue       |
| 35   | Purple     | 45   | Purple     |
| 36   | Cyan       | 46   | Cyan       |
| 37   | White      | 47   | White      |

### Format Codes:

| Code | Format     |
|------|------------|
| 0    | Reset      |
| 1    | Bold       |
| 2    | Dim        |
| 4    | Underlined |
| 5    | Blink      |
| 7    | Reverse    |
| 8    | Hidden     |

## Arithmetic Operations

Shell provides several ways to perform arithmetic operations:

### 1. Using `expr` (older method):

```bash
result=`expr 5 + 3`
echo $result  # Outputs: 8

# Multiplication requires escape character
result=`expr 5 \* 3`
echo $result  # Outputs: 15
```

### 2. Using `$(( ))` (preferred method):

```bash
result=$((5 + 3))
echo $result  # Outputs: 8

# Multiplication works without escaping
result=$((5 * 3))
echo $result  # Outputs: 15

# Variables can be used with or without $
a=5
b=3
result=$((a + b))
echo $result  # Outputs: 8

# All basic operations are supported
addition=$((a + b))
subtraction=$((a - b))
multiplication=$((a * b))
division=$((a / b))
remainder=$((a % b))
exponentiation=$((a ** b))
```

### 3. Using `let` command:

```bash
let "result = 5 + 3"
echo $result  # Outputs: 8

let "a = 5"
let "b = 3"
let "result = a * b"
echo $result  # Outputs: 15
```

### 4. Using `bc` for floating-point arithmetic:

```bash
result=$(echo "5.5 + 3.2" | bc)
echo $result  # Outputs: 8.7

result=$(echo "scale=2; 10 / 3" | bc)
echo $result  # Outputs: 3.33
```

## Examples

### Basic Script Example

```bash
#!/bin/bash
# This is a comment
echo "Hello, world!"
echo "This is my first shell script."
```

### Variables and Arithmetic Example

```bash
#!/bin/bash

# Define variables
name="Alice"
age=30

# Perform arithmetic
future_age=$((age + 10))

# Output with variable interpolation
echo "Hello, $name!"
echo "You are $age years old."
echo "In 10 years, you will be $future_age years old."

# More complex arithmetic using bc
weight=68.5
height=1.75
bmi=$(echo "scale=2; $weight / ($height * $height)" | bc)
echo "Your BMI is: $bmi"
```

### Command Line Arguments Example

```bash
#!/bin/bash

# Check if arguments are provided
if [ $# -eq 0 ]; then
    echo "No arguments provided. Usage: $0 <name> <age>"
    exit 1
fi

# Use command line arguments
echo "Hello, $1!"

if [ $# -ge 2 ]; then
    echo "You are $2 years old."
fi

echo "Script was called with $# argument(s)"
echo "All arguments: $@"
```

### Reading Input Example

```bash
#!/bin/bash

# Ask user for information
read -p "Enter your name: " name
read -p "Enter your age: " age
read -s -p "Enter your password: " password
echo

# Calculate birth year (approximately)
current_year=$(date +%Y)
birth_year=$((current_year - age))

# Output information
echo "Hello, $name!"
echo "You were born around $birth_year."
echo "Your password has ${#password} characters."
```

### Colorful Output Example

```bash
#!/bin/bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Display colorful output
echo -e "${RED}Error:${NC} Something went wrong!"
echo -e "${GREEN}Success:${NC} Operation completed."
echo -e "${YELLOW}Warning:${NC} Disk space is low."
echo -e "${BLUE}Info:${NC} Processing files..."

# Create a simple progress bar
echo -n "Loading: ["
for i in {1..20}; do
    echo -n -e "${GREEN}#${NC}"
    sleep 0.1
done
echo "] Done!"
```