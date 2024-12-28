#!/bin/bash

# Ensure required commands are installed
declare -a REQUIRED_COMMANDS=("tree" "file")
for cmd in "${REQUIRED_COMMANDS[@]}"; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "Error: '$cmd' command not found. Please install it first."
    exit 1
  fi
done

# Set the target directory (default to current directory if not provided)
TARGET_DIR=${1:-.}

# Define the log file (always save as tree.log)
LOG_FILE="./tree.log"

# Check if the target directory exists and is accessible
if [ ! -d "$TARGET_DIR" ]; then
  echo "Error: Target directory '$TARGET_DIR' does not exist or is not accessible."
  exit 1
fi

# Load ignore patterns from .treeignore if it exists
IGNORE_FILE="$TARGET_DIR/.treeignore"
IGNORE_PATTERNS=()
if [ -f "$IGNORE_FILE" ]; then
  while read -r line; do
    # Skip empty lines or lines starting with #
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    IGNORE_PATTERNS+=("$line")
  done < "$IGNORE_FILE"
fi

# Construct the ignore string for the tree command
IGNORE_ARGS=""
if [ ${#IGNORE_PATTERNS[@]} -gt 0 ]; then
  IGNORE_ARGS="-I \"$(IFS="|"; echo "${IGNORE_PATTERNS[*]}")\""
fi

# Display the directory structure and write it to the log file
echo "Directory structure of $TARGET_DIR:" > "$LOG_FILE"
eval tree "$TARGET_DIR" $IGNORE_ARGS >> "$LOG_FILE" || {
  echo "Error: Failed to generate directory structure."
  exit 1
}

# Find human-readable files and output their content, excluding ignored files
echo -e "\nContents of human-readable files:" >> "$LOG_FILE"
find "$TARGET_DIR" -type f \( ! -name "$(basename "$LOG_FILE")" \) | grep -v "/\.git/" | while read -r file; do
  # Skip files matching .treeignore patterns
  for pattern in "${IGNORE_PATTERNS[@]}"; do
    [[ "$file" == *"$pattern"* ]] && continue 2
  done

  if file "$file" | grep -q "text"; then
    echo -e "\n--- File: $file ---" >> "$LOG_FILE"
    cat "$file" >> "$LOG_FILE" 2>/dev/null || echo "Error: Unable to read $file" >> "$LOG_FILE"
  fi
done

# Notify the user of the completed log generation
echo "Log file generated: $LOG_FILE"
