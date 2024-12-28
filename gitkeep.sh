#!/bin/bash

# Check if the current directory is a Git repository
if [ ! -d ".git" ]; then
    echo "This is not a Git repository!"
    exit 1
fi

# Find all empty directories and add a .gitkeep file
find . -type d -empty -exec touch {}/.gitkeep \;

# Stage the .gitkeep files
git add .gitkeep

echo "Added .gitkeep to empty directories."
