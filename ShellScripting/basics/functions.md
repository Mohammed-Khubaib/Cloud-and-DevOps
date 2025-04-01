# Shell Scripting - Functions

## Table of Contents
- [Function Basics](#function-basics)
  - [Defining Functions](#defining-functions)
  - [Calling Functions](#calling-functions)
  - [Function Parameters](#function-parameters)
  - [Variable Scope](#variable-scope)
- [Return Values](#return-values)
  - [Exit Codes](#exit-codes)
  - [Returning Data](#returning-data)
- [Advanced Function Techniques](#advanced-function-techniques)
  - [Recursive Functions](#recursive-functions)
  - [Function Libraries](#function-libraries)
  - [Command Substitution](#command-substitution)
  - [Function Debugging](#function-debugging)
- [Examples](#examples)
  - [Basic Function Example](#basic-function-example)
  - [Function Parameters Example](#function-parameters-example)
  - [Return Values Example](#return-values-example)
  - [Library Functions Example](#library-functions-example)
  - [Advanced Function Example](#advanced-function-example)

## Function Basics

Functions are reusable blocks of code that perform specific tasks. They help make scripts more modular, maintainable, and reduce code duplication.

### Defining Functions

There are two common ways to define functions in shell scripts:

```bash
# Method 1: Using the 'function' keyword (Bash, ksh, zsh)
function function_name {
    # Commands
}

# Method 2: Traditional POSIX-compliant method (works in all shells)
function_name() {
    # Commands
}
```

Example:

```bash
# A simple greeting function
greeting() {
    echo "Hello, world!"
}

# Function with commands
display_date() {
    echo "Today is: $(date +%Y-%m-%d)"
    echo "Current time: $(date +%H:%M:%S)"
}
```

### Calling Functions

To call a function, simply use its name:

```bash
greeting          # Calls the greeting function
display_date      # Calls the display_date function
```

**Important**: Functions must be defined before they are called. The shell reads and executes scripts line by line.

### Function Parameters

Functions can accept parameters, which are accessed using positional parameters similar to script arguments:

| Parameter | Description |
|-----------|-------------|
| `$1` | First parameter |
| `$2` | Second parameter |
| `$n` | nth parameter |
| `$#` | Number of parameters |
| `$*` | All parameters as a single string |
| `$@` | All parameters as separate strings |

Example:

```bash
# Function with parameters
greet_person() {
    echo "Hello, $1!"
    echo "Nice to meet you."
}

# Function with multiple parameters
calculate_sum() {
    echo "Adding $1 and $2"
    sum=$(($1 + $2))
    echo "Result: $sum"
}

# Call functions with parameters
greet_person "John"
calculate_sum 5 7
```

Unlike some programming languages, shell functions don't have formal parameter declarations. They simply use the positional parameters that are passed when the function is called.

### Variable Scope

By default, variables in shell scripts are global. This means:

1. Variables defined outside functions can be accessed inside functions
2. Variables defined inside functions can be accessed outside after the function is called

To create local variables (only accessible within the function), use the `local` keyword:

```bash
my_function() {
    local local_var="I am local"    # Only accessible within the function
    global_var="I am global"        # Accessible everywhere after function call
    echo "Inside function: $local_var"
    echo "Inside function: $global_var"
}

my_function
echo "Outside function: $global_var"
echo "Outside function: $local_var"  # This will be empty or cause an error
```

**Note**: The `local` keyword is available in Bash, ksh, and zsh, but not in all POSIX-compliant shells.

## Return Values

Shell functions handle return values differently from many programming languages.

### Exit Codes

Functions, like commands and scripts, return an exit status (a number between 0 and 255):

- `0` indicates success
- Any non-zero value indicates an error or failure

You can explicitly set the return value using the `return` statement:

```bash
check_number() {
    if [ "$1" -gt 10 ]; then
        echo "$1 is greater than 10"
        return 0  # Success
    else
        echo "$1 is not greater than 10"
        return 1  # Failure
    fi
}

# Call the function and check its return value
check_number 15
if [ $? -eq 0 ]; then
    echo "Function succeeded"
else
    echo "Function failed"
fi
```

**Note**: The `$?` variable contains the exit status of the most recently executed command or function.

### Returning Data

Since shell functions can only return exit codes, there are several ways to "return" actual data:

1. **Echo the result** (most common):

```bash
get_square() {
    local result=$(($1 * $1))
    echo $result
}

# Capture the output using command substitution
square_of_5=$(get_square 5)
echo "The square of 5 is $square_of_5"
```

2. **Modify a global variable**:

```bash
calculate_area() {
    area=$(($1 * $2))  # Modifies global variable
}

# Call function and use the global variable
calculate_area 5 3
echo "The area is $area"
```

3. **Use a reference parameter** (Bash 4.3+):

```bash
calculate_values() {
    local num=$1
    local -n square_ref=$2
    local -n cube_ref=$3
    
    square_ref=$((num * num))
    cube_ref=$((num * num * num))
}

# Call function with variable references
square_result=0
cube_result=0
calculate_values 5 square_result cube_result
echo "Square: $square_result, Cube: $cube_result"
```

## Advanced Function Techniques

### Recursive Functions

Shell functions can call themselves (recursion), but it's important to have a base case to prevent infinite recursion:

```bash
factorial() {
    if [ $1 -le 1 ]; then
        echo 1
    else
        local sub_result=$(factorial $(($1 - 1)))
        echo $(($1 * sub_result))
    fi
}

result=$(factorial 5)
echo "5! = $result"
```

**Note**: Shell scripts aren't optimized for deep recursion. For complex recursive operations, consider using a different language.

### Function Libraries

You can create function libraries by putting related functions in a separate file and sourcing it in your scripts:

```bash
# math_functions.sh
add() {
    echo $(($1 + $2))
}

subtract() {
    echo $(($1 - $2))
}

multiply() {
    echo $(($1 * $2))
}

divide() {
    if [ $2 -eq 0 ]; then
        echo "Error: Division by zero"
        return 1
    fi
    echo $(($1 / $2))
}
```

Using the library in your script:

```bash
#!/bin/bash

# Source the function library
source ./math_functions.sh
# or
. ./math_functions.sh

# Use the functions
sum=$(add 10 5)
difference=$(subtract 10 5)
product=$(multiply 10 5)
quotient=$(divide 10 5)

echo "Sum: $sum"
echo "Difference: $difference"
echo "Product: $product"
echo "Quotient: $quotient"
```

### Command Substitution

Functions can be used with command substitution to process data in pipelines:

```bash
extract_domain() {
    # Extract domain from email address
    echo "$1" | cut -d '@' -f 2
}

# Use in a pipeline
echo "user@example.com" | xargs -I{} bash -c 'extract_domain "$@"' _ {}
```

### Function Debugging

To debug functions, you can use the `set -x` command to enable tracing:

```bash
debug_function() {
    set -x          # Enable debugging
    local a=5
    local b=3
    local result=$((a + b))
    echo "Result: $result"
    set +x          # Disable debugging
}

debug_function
```

## Examples

### Basic Function Example

```bash
#!/bin/bash

# Simple function to display a separator line
separator() {
    echo "-----------------------------------------"
}

# Function to display a header
header() {
    separator
    echo "$1"
    separator
}

# Using the functions
header "System Information"
echo "Hostname: $(hostname)"
echo "Kernel: $(uname -r)"
echo "Uptime: $(uptime -p)"

header "Disk Usage"
df -h | grep -E '(/dev/sd|/dev/nvme)'
```

### Function Parameters Example

```bash
#!/bin/bash

# Function to create a backup of a file
backup_file() {
    local file="$1"
    local backup_dir="${2:-./backups}"
    
    # Check if file exists
    if [ ! -f "$file" ]; then
        echo "Error: File '$file' does not exist"
        return 1
    fi
    
    # Create backup directory if it doesn't exist
    if [ ! -d "$backup_dir" ]; then
        mkdir -p "$backup_dir"
        echo "Created backup directory: $backup_dir"
    fi
    
    # Create backup with timestamp
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local filename=$(basename "$file")
    local backup_file="$backup_dir/${filename}_${timestamp}.bak"
    
    cp "$file" "$backup_file"
    
    if [ $? -eq 0 ]; then
        echo "Backup created: $backup_file"
        return 0
    else
        echo "Error: Failed to create backup"
        return 1
    fi
}

# Call the function with different parameters
backup_file "/etc/hosts"
backup_file "/etc/passwd" "/tmp/my_backups"
```

### Return Values Example

```bash
#!/bin/bash

# Function to check if a number is prime
is_prime() {
    local num=$1
    
    # Check edge cases
    if [ $num -lt 2 ]; then
        return 1  # Not prime
    fi
    
    if [ $num -eq 2 ] || [ $num -eq 3 ]; then
        return 0  # Prime
    fi
    
    # Check if divisible by 2
    if [ $((num % 2)) -eq 0 ]; then
        return 1  # Not prime
    fi
    
    # Check odd divisors up to square root
    local max=$(echo "sqrt($num)" | bc)
    for ((i = 3; i <= max; i += 2)); do
        if [ $((num % i)) -eq 0 ]; then
            return 1  # Not prime
        fi
    done
    
    return 0  # Prime
}

# Function to get the next prime number
next_prime() {
    local num=$1
    local next=$((num + 1))
    
    while true; do
        is_prime $next
        if [ $? -eq 0 ]; then
            echo $next
            return 0
        fi
        next=$((next + 1))
    done
}

# Test the functions
echo "Testing prime numbers:"
for num in 1 2 3 4 5 6 7 8 9 10; do
    is_prime $num
    if [ $? -eq 0 ]; then
        echo "$num is prime"
    else
        echo "$num is not prime"
    fi
done

echo -e "\nNext prime after 20: $(next_prime 20)"
echo "Next prime after 100: $(next_prime 100)"
```

### Library Functions Example

```bash
#!/bin/bash

# Define a library of logging functions
log_info() {
    echo "[INFO] $(date +"%Y-%m-%d %H:%M:%S") - $1"
}

log_warning() {
    echo "[WARNING] $(date +"%Y-%m-%d %H:%M:%S") - $1" >&2
}

log_error() {
    echo "[ERROR] $(date +"%Y-%m-%d %H:%M:%S") - $1" >&2
}

log_debug() {
    if [ "${DEBUG:-0}" -eq 1 ]; then
        echo "[DEBUG] $(date +"%Y-%m-%d %H:%M:%S") - $1" >&2
    fi
}

# Function to execute a command with logging
execute_command() {
    local cmd="$1"
    local description="${2:-Executing command}"
    
    log_info "$description: $cmd"
    
    # Execute the command and capture status
    eval $cmd
    local status=$?
    
    if [ $status -eq 0 ]; then
        log_info "Command completed successfully"
    else
        log_error "Command failed with status $status"
    fi
    
    return $status
}

# Example usage
DEBUG=1
log_info "Script started"
log_debug "Debug mode enabled"

execute_command "ls -la" "Listing directory contents"
execute_command "grep 'pattern' non_existent_file" "Searching for pattern"

log_warning "This is a warning message"
log_error "This is an error message"
log_info "Script completed"
```

### Advanced Function Example

```bash
#!/bin/bash

# Function to process a batch of files
process_files() {
    local directory="$1"
    local pattern="$2"
    local action="$3"
    local count=0
    local errors=0
    
    # Validate inputs
    if [ -z "$directory" ] || [ -z "$pattern" ] || [ -z "$action" ]; then
        echo "Error: Missing required parameters"
        echo "Usage: process_files directory pattern action"
        return 1
    fi
    
    if [ ! -d "$directory" ]; then
        echo "Error: Directory '$directory' does not exist"
        return 1
    fi
    
    # Process files
    echo "Processing files in '$directory' matching '$pattern'..."
    
    for file in "$directory"/*; do
        # Skip if not a file or doesn't match pattern
        if [ ! -f "$file" ] || ! [[ $(basename "$file") == $pattern ]]; then
            continue
        fi
        
        # Execute the action on the file
        eval "$action \"$file\""
        
        if [ $? -eq 0 ]; then
            count=$((count + 1))
        else
            errors=$((errors + 1))
        fi
    done
    
    # Return results
    echo "Processing complete."
    echo "Files processed: $count"
    echo "Errors: $errors"
    
    if [ $errors -gt 0 ]; then
        return 1
    else
        return 0
    fi
}

# Example usage

# Define actions as functions
compress_file() {
    echo "Compressing $1"
    gzip -k "$1"
}

backup_file() {
    echo "Backing up $1"
    cp "$1" "$1.bak"
}

# Process text files with compression
process_files "/tmp" "*.txt" "compress_file"

# Process log files with backup
process_files "/var/log" "*.log" "backup_file"

# Process with inline command
process_files "/home/user/documents" "*.doc" "echo 'Found document:'"
```