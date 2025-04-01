#!/bin/bash
#
# Incremental Backup Script
# Creates incremental backups using rsync with rotation and compression
#

# Set strict error handling
set -eo pipefail

# Configuration variables
SOURCE_DIR=""
BACKUP_DIR=""
MAX_BACKUPS=5
EXCLUDE_FILE=""
COMPRESSION_LEVEL=6
BACKUP_PREFIX="backup"
TIMESTAMP_FORMAT="%Y%m%d_%H%M%S"
LOG_FILE="backup.log"
VERBOSE=false
DRY_RUN=false

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to show help message
show_help() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -s, --source DIR      Source directory to backup (required)"
    echo "  -d, --destination DIR Destination directory for backups (required)"
    echo "  -e, --exclude FILE    File containing patterns to exclude"
    echo "  -m, --max-backups N   Maximum number of backups to keep (default: 5)"
    echo "  -c, --compression N   Compression level (0-9, default: 6)"
    echo "  -p, --prefix NAME     Backup prefix (default: 'backup')"
    echo "  -l, --log FILE        Log file (default: 'backup.log')"
    echo "  -v, --verbose         Verbose output"
    echo "  -n, --dry-run         Show what would be done without making changes"
    echo "  -h, --help            Show this help message"
    echo
    echo "Example:"
    echo "  $0 -s /home/user/data -d /mnt/backups -e exclude.txt -m 7"
}

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
    "ERROR")
        echo -e "${RED}${timestamp} - ERROR: ${message}${NC}" | tee -a "$LOG_FILE"
        ;;
    *)
        echo -e "${timestamp} - ${message}" | tee -a "$LOG_FILE"
        ;;
    esac
}

# Parse command line arguments using getopt
TEMP=$(getopt -o s:d:e:m:c:p:l:vnh --long source:,destination:,exclude:,max-backups:,compression:,prefix:,log:,verbose,dry-run,help -n 'backup.sh' -- "$@")

if [ $? != 0 ]; then
    echo "Error parsing arguments. Try '$0 --help' for more information."
    exit 1
fi

# Note the quotes around $TEMP: they are essential!
eval set -- "$TEMP"

# Process options
while true; do
    case "$1" in
    -s | --source)
        SOURCE_DIR="$2"
        shift 2
        ;;
    -d | --destination)
        BACKUP_DIR="$2"
        shift 2
        ;;
    -e | --exclude)
        EXCLUDE_FILE="$2"
        shift 2
        ;;
    -m | --max-backups)
        MAX_BACKUPS="$2"
        shift 2
        ;;
    -c | --compression)
        COMPRESSION_LEVEL="$2"
        shift 2
        ;;
    -p | --prefix)
        BACKUP_PREFIX="$2"
        shift 2
        ;;
    -l | --log)
        LOG_FILE="$2"
        shift 2
        ;;
    -v | --verbose)
        VERBOSE=true
        shift
        ;;
    -n | --dry-run)
        DRY_RUN=true
        shift
        ;;
    -h | --help)
        show_help
        exit 0
        ;;
    --)
        shift
        break
        ;;
    *)
        echo "Internal error!"
        exit 1
        ;;
    esac
done

# Validate required arguments
if [ -z "$SOURCE_DIR" ] || [ -z "$BACKUP_DIR" ]; then
    log_message "ERROR" "Source and destination directories are required"
    show_help
    exit 1
fi

# Validate source directory
if [ ! -d "$SOURCE_DIR" ]; then
    log_message "ERROR" "Source directory does not exist: $SOURCE_DIR"
    exit 1
fi

# Create backup directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ] && [ "$DRY_RUN" = false ]; then
    mkdir -p "$BACKUP_DIR" || {
        log_message "ERROR" "Failed to create backup directory: $BACKUP_DIR"
        exit 1
    }
    log_message "INFO" "Created backup directory: $BACKUP_DIR"
fi

# Validate exclude file if specified
if [ -n "$EXCLUDE_FILE" ] && [ ! -f "$EXCLUDE_FILE" ]; then
    log_message "ERROR" "Exclude file does not exist: $EXCLUDE_FILE"
    exit 1
fi

# Validate numeric arguments
if ! [[ "$MAX_BACKUPS" =~ ^[0-9]+$ ]]; then
    log_message "ERROR" "Max backups must be a positive integer: $MAX_BACKUPS"
    exit 1
fi

if ! [[ "$COMPRESSION_LEVEL" =~ ^[0-9]$ ]]; then
    log_message "ERROR" "Compression level must be between
    0 and 9: $COMPRESSION_LEVEL"
        exit 1
    fi

# Generate timestamp for the current backup
TIMESTAMP=$(date +"$TIMESTAMP_FORMAT")
BACKUP_NAME="${BACKUP_PREFIX}_${TIMESTAMP}"
CURRENT_BACKUP_DIR="$BACKUP_DIR/$BACKUP_NAME"

# Function to perform the backup
perform_backup() {
    local rsync_options=()

    # Add verbosity if enabled
    if [ "$VERBOSE" = true ]; then
        rsync_options+=("-v")
    fi

    # Add dry-run mode if enabled
    if [ "$DRY_RUN" = true ]; then
        rsync_options+=("--dry-run")
    fi

    # Add exclude file if specified
    if [ -n "$EXCLUDE_FILE" ]; then
        rsync_options+=("--exclude-from=$EXCLUDE_FILE")
    fi

    # Add compression level
    rsync_options+=("--compress-level=$COMPRESSION_LEVEL")

    # Add incremental backup options
    rsync_options+=("--link-dest=$BACKUP_DIR/current")

    # Perform the backup using rsync
    log_message "INFO" "Starting backup: $SOURCE_DIR -> $CURRENT_BACKUP_DIR"
    rsync "${rsync_options[@]}" -a --delete "$SOURCE_DIR/" "$CURRENT_BACKUP_DIR/"

    # Create a symbolic link to the latest backup
    if [ "$DRY_RUN" = false ]; then
        ln -sfn "$CURRENT_BACKUP_DIR" "$BACKUP_DIR/current"
        log_message "INFO" "Updated 'current' symbolic link to point to: $CURRENT_BACKUP_DIR"
    fi
}

# Function to rotate backups
rotate_backups() {
    log_message "INFO" "Rotating backups in: $BACKUP_DIR"
    cd "$BACKUP_DIR" || {
        log_message "ERROR" "Failed to access backup directory: $BACKUP_DIR"
        exit 1
    }

    # List all backups excluding the 'current' symlink
    local backups=($(ls -d ${BACKUP_PREFIX}_* 2>/dev/null | sort -r))

    # Remove old backups beyond the maximum limit
    if [ "${#backups[@]}" -gt "$MAX_BACKUPS" ]; then
        for ((i = MAX_BACKUPS; i < ${#backups[@]}; i++)); do
            local old_backup="${backups[$i]}"
            log_message "INFO" "Removing old backup: $old_backup"
            if [ "$DRY_RUN" = false ]; then
                rm -rf "$old_backup"
            fi
        done
    else
        log_message "INFO" "No old backups to remove."
    fi
}

# Main script execution
log_message "INFO" "Backup script started."

# Step 1: Perform the backup
perform_backup

# Step 2: Rotate backups
rotate_backups

log_message "INFO" "Backup completed successfully."
exit 0
