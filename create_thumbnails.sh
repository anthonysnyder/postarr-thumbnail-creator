#!/bin/bash

# Specify the directories to monitor
DIRECTORIES=(
    "XX_PLACEHOLDER_DIR_XX"
    "XX_PLACEHOLDER_DIR_XX"
)

# Initialize counters for success and failure
success_count=0
failure_count=0
failed_folders=()

# Function to process files in a directory
process_files_in_directory() {
    local DIRECTORY="$1"
    # Loop through each movie folder
    find "$DIRECTORY" -type d -print0 | while IFS= read -r -d '' MOVIE_DIR; do
        process_movie_directory "$MOVIE_DIR"
    done
}

# Function to process each movie directory
process_movie_directory() {
    local MOVIE_DIR="$1"
    local POSTER_PATH=""
    # Check if the poster.ext exists
    for ext in jpg jpeg png; do
        if [ -f "$MOVIE_DIR/poster.$ext" ]; then
            POSTER_PATH="$MOVIE_DIR/poster.$ext"
            break
        fi
    done
    
    if [ -n "$POSTER_PATH" ]; then
        # Generate the thumbnail
        if create_thumbnail "$POSTER_PATH" "$MOVIE_DIR"; then
            echo "Successfully created thumbnail in $MOVIE_DIR"
            ((success_count++))
        else
            echo "Failed to create thumbnail in $MOVIE_DIR"
            ((failure_count++))
            failed_folders+=("$MOVIE_DIR")
        fi
    else
        echo "No poster found in $MOVIE_DIR"
    fi
}

# Function to create a thumbnail
create_thumbnail() {
    local POSTER_PATH="$1"
    local MOVIE_DIR="$2"
    local THUMB_PATH="$MOVIE_DIR/poster-thumb.jpg"
    
    # Use imagemagick to create a thumbnail
    convert "$POSTER_PATH" -resize 300x450 "$THUMB_PATH"
    
    if [ $? -eq 0 ]; then
        return 0  # Success
    else
        return 1  # Failure
    fi
}

# Loop through each directory
for DIRECTORY in "${DIRECTORIES[@]}"; do
    process_files_in_directory "$DIRECTORY"
done

# Final output
echo ""
echo "Process completed."
echo "Successes: $success_count"
echo "Failures: $failure_count"

if [ $failure_count -gt 0 ]; then
    echo "Failed folders:"
    for folder in "${failed_folders[@]}"; do
        echo "$folder"
    done
fi
