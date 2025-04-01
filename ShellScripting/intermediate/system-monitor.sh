#!/bin/bash
#
# Advanced System Resource Monitoring Script
# This script monitors system resources and logs/alerts based on thresholds
#

# Set strict error handling
set -eo pipefail

# Configuration variables
LOG_FILE="/var/log/system_monitor.log"
ALERT_EMAIL="admin@example.com"
CPU_THRESHOLD=80
MEM_THRESHOLD=80
DISK_THRESHOLD=90
PROCESS_LIMIT=5

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to handle script termination
cleanup() {
    echo -e "${BLUE}$(date '+%Y-%m-%d %H:%M:%S')${NC} - System monitor script terminated" | tee -a "$LOG_FILE"
    exit 0
}

# Register the cleanup function for these signals
trap cleanup SIGINT SIGTERM

# Function to log messages
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$level" in
        "INFO")
            echo -e "${GREEN}${timestamp} - INFO: ${message}${NC}" | tee -a "$LOG_FILE"
            ;;
        "WARNING")
            echo -e "${YELLOW}${timestamp} - WARNING: ${message}${NC}" | tee -a "$LOG_FILE"
            ;;
        "CRITICAL")
            echo -e "${RED}${timestamp} - CRITICAL: ${message}${NC}" | tee -a "$LOG_FILE"
            # Send email alert
            echo "${timestamp} - CRITICAL: ${message}" | mail -s "SYSTEM ALERT: ${message}" "$ALERT_EMAIL"
            ;;
        *)
            echo -e "${timestamp} - ${message}" | tee -a "$LOG_FILE"
            ;;
    esac
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check required commands
for cmd in top free df ps mail; do
    if ! command_exists "$cmd"; then
        log_message "CRITICAL" "Required command '$cmd' not found. Please install it and try again."
        exit 1
    fi
done

# Create log file if it doesn't exist
if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE" 2>/dev/null || {
        echo "Unable to create log file: $LOG_FILE"
        echo "Please check permissions or run with sudo"
        exit 1
    }
fi

# Function to check CPU usage
check_cpu() {
    # Get CPU usage using top in batch mode
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    local cpu_int=${cpu_usage%.*}
    
    if [ "$cpu_int" -ge "$CPU_THRESHOLD" ]; then
        log_message "CRITICAL" "CPU usage is at ${cpu_usage}% (threshold: ${CPU_THRESHOLD}%)"
        
        # Get top CPU consuming processes
        log_message "INFO" "Top CPU consuming processes:"
        ps aux --sort=-%cpu | head -n $((PROCESS_LIMIT + 1)) | awk 'NR>1 {printf "  %s %s %s%%\n", $11, $2, $3}' | 
            while read -r process pid cpu; do
                echo -e "  ${YELLOW}Process:${NC} $process ${YELLOW}PID:${NC} $pid ${YELLOW}CPU:${NC} $cpu" | tee -a "$LOG_FILE"
            done
    else
        log_message "INFO" "CPU usage is at ${cpu_usage}% (threshold: ${CPU_THRESHOLD}%)"
    fi
}

# Function to check memory usage
check_memory() {
    # Get memory usage using free command
    local mem_info=$(free | grep Mem)
    local total=$(echo "$mem_info" | awk '{print $2}')
    local used=$(echo "$mem_info" | awk '{print $3}')
    local mem_percentage=$(( (used * 100) / total ))
    
    if [ "$mem_percentage" -ge "$MEM_THRESHOLD" ]; then
        log_message "CRITICAL" "Memory usage is at ${mem_percentage}% (threshold: ${MEM_THRESHOLD}%)"
        
        # Get top memory consuming processes
        log_message "INFO" "Top memory consuming processes:"
        ps aux --sort=-%mem | head -n $((PROCESS_LIMIT + 1)) | awk 'NR>1 {printf "  %s %s %s%%\n", $11, $2, $4}' | 
            while read -r process pid mem; do
                echo -e "  ${YELLOW}Process:${NC} $process ${YELLOW}PID:${NC} $pid ${YELLOW}Memory:${NC} $mem" | tee -a "$LOG_FILE"
            done
    else
        log_message "INFO" "Memory usage is at ${mem_percentage}% (threshold: ${MEM_THRESHOLD}%)"
    fi
}

# Function to check disk usage
check_disk() {
    # Get disk usage for all mounted file systems
    log_message "INFO" "Checking disk usage:"
    df -h | grep -vE "^Filesystem|tmpfs|cdrom" | awk '{ print $5 " " $1 " " $6 }' | 
        while read -r used filesystem mountpoint; do
            used_percentage=${used%?}
            
            if [ "$used_percentage" -ge "$DISK_THRESHOLD" ]; then
                log_message "CRITICAL" "Disk usage on ${filesystem} (${mountpoint}) is at ${used}% (threshold: ${DISK_THRESHOLD}%)"
            else
                log_message "INFO" "Disk usage on ${filesystem} (${mountpoint}) is at ${used}% (threshold: ${DISK_THRESHOLD}%)"
            fi
        done
}

# Function to check system load
check_load() {
    local load_avg=$(cat /proc/loadavg | awk '{print $1, $2, $3}')
    local cpu_count=$(nproc)
    local one_min=$(echo "$load_avg" | awk '{print $1}')
    local five_min=$(echo "$load_avg" | awk '{print $2}')
    local fifteen_min=$(echo "$load_avg" | awk '{print $3}')
    
    log_message "INFO" "System load averages: $one_min (1m), $five_min (5m), $fifteen_min (15m) - CPU count: $cpu_count"
    
    # Check if 1-minute load average is higher than CPU count
    if (( $(echo "$one_min > $cpu_count" | bc -l) )); then
        log_message "WARNING" "Load average is higher than CPU count"
    fi
}

# Function to check for zombie processes
check_zombies() {
    local zombie_count=$(ps aux | grep -w Z | grep -v grep | wc -l)
    
    if [ "$zombie_count" -gt 0 ]; then
        log_message "WARNING" "Found $zombie_count zombie processes"
        ps aux | grep -w Z | grep -v grep | 
            while read -r line; do
                echo -e "  ${YELLOW}Zombie process:${NC} $line" | tee -a "$LOG_FILE"
            done
    else
        log_message "INFO" "No zombie processes found"
    fi
}

# Main function to run all checks
run_checks() {
    log_message "INFO" "Starting system resource monitoring"
    
    check_cpu
    check_memory
    check_disk
    check_load
    check_zombies
    
    log_message "INFO" "System resource monitoring completed"
    echo -e "${BLUE}----------------------------------------${NC}" | tee -a "$LOG_FILE"
}

# Check if script is running as root
if [ "$(id -u)" -ne 0 ]; then
    log_message "WARNING" "This script is not running as root. Some system information may not be accessible."
fi

# Parse command line arguments
while getopts ":c:m:d:i:h" opt; do
    case $opt in
        c)
            CPU_THRESHOLD="$OPTARG"
            ;;
        m)
            MEM_THRESHOLD="$OPTARG"
            ;;
        d)
            DISK_THRESHOLD="$OPTARG"
            ;;
        i)
            INTERVAL="$OPTARG"
            ;;
        h)
            echo "Usage: $0 [-c cpu_threshold] [-m memory_threshold] [-d disk_threshold] [-i interval_seconds]"
            echo "  -c: CPU threshold in percentage (default: 80)"
            echo "  -m: Memory threshold in percentage (default: 80)"
            echo "  -d: Disk threshold in percentage (default: 90)"
            echo "  -i: Monitoring interval in seconds (default: runs once)"
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done

# Run once by default, or continuously with specified interval
if [ -z "$INTERVAL" ]; then
    run_checks
else
    while true; do
        run_checks
        sleep "$INTERVAL"
    done
fi