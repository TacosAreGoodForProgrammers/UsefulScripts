#!/bin/bash

# Default project directory
PROJECT_DIR="./"

# Default file extensions to include in line count
FILE_EXTENSIONS=("*.c" "*.h" "*.asm" "*.sh" "*.md")

# Function to count lines of code in a specific file type
count_lines_in_files() {
    local extensions=("$@")
    local total_lines=0

    # Loop through each file type and count the lines
    for ext in "${extensions[@]}"; do
        # Use find to get files recursively and count lines
        find "$PROJECT_DIR" -type f -name "$ext" | while read file; do
            lines_in_file=$(wc -l < "$file")
            total_lines=$((total_lines + lines_in_file))
        done
    done

    echo "$total_lines"
}

# Function to display usage/help
show_help() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -d <directory>    Set the project directory (default: current directory)"
    echo "  -e <extensions>   Comma-separated list of file extensions to include (default: .c,.h,.asm,.sh,.md)"
    echo "  -h                Show this help message"
    exit 1
}

# Parse command-line arguments
while getopts "d:e:h" opt; do
    case "$opt" in
        d)
            PROJECT_DIR="$OPTARG"
            ;;
        e)
            IFS=',' read -r -a FILE_EXTENSIONS <<< "$OPTARG"
            ;;
        h)
            show_help
            ;;
        *)
            show_help
            ;;
    esac
done

# Count the lines and display the result
total_lines=$(count_lines_in_files "${FILE_EXTENSIONS[@]}")
echo "Total lines of code in the project: $total_lines"
