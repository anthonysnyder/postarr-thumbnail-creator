#!/bin/bash

# Specify the directories to monitor (replace with your actual directories)
DIRECTORIES=(
    "XX_PLACEHOLDER_DIR_XX"
    "XX_PLACEHOLDER_DIR_XX"
)

# Initialize counters for summary
total_successes=0
total_failures=0
total_no_poster=0
failed_folders=()

# Log file
LOG_FILE="thumbnail_creation.log"

# Function to process each movie folder
process_movie_folder() {
    local FOLDER="$1"

    echo "Processing folder: $FOLDER" | tee -a "$LOG_FILE"
    
    # Check for an existing poster in different formats
    local poster_file=""
    for ext in jpg jpeg png; do
        if [ -f "$FOLDER/poster.$ext" ]; then
            poster_file="$FOLDER/poster.$ext"
            break
        fi
    done

    if [ -z "$poster_file" ]; then
        echo "No poster file found in folder: $FOLDER" | tee -a "$LOG_FILE"
        ((total_no_poster++))
        return
    fi

    # Check if thumbnail already exists
    if [ -f "$FOLDER/poster-thumb.jpg" ]; then
        echo "Thumbnail already exists, skipping folder: $FOLDER" | tee -a "$LOG_FILE"
        return
    fi

    # Attempt to create a thumbnail
    convert "$poster_file" -resize 300x450 "$FOLDER/poster-thumb.jpg" 2>>"$LOG_FILE"
    if [ $? -eq 0 ]; then
        echo "Thumbnail created successfully: $FOLDER/poster-thumb.jpg" | tee -a "$LOG_FILE"
        ((total_successes++))
    else
        echo "Failed to create thumbnail for: $FOLDER" | tee -a "$LOG_FILE"
        ((total_failures++))
        failed_folders+=("$FOLDER")
    fi
}

# Function to process all directories
process_directories() {
    for DIRECTORY in "${DIRECTORIES[@]}"; do
        if [ -d "$DIRECTORY" ]; then
            echo "Processing directory: $DIRECTORY" | tee -a "$LOG_FILE"
            find "$DIRECTORY" -mindepth 1 -maxdepth 1 -type d | while read -r movie_folder; do
                process_movie_folder "$movie_folder"
            done
        else
            echo "Directory not found: $DIRECTORY" | tee -a "$LOG_FILE"
        fi
    done

    # Final summary
    echo "Summary:" | tee -a "$LOG_FILE"
    echo "Total Thumbnails Created: $total_successes" | tee -a "$LOG_FILE"
    echo "Total Folders with Failures: $total_failures" | tee -a "$LOG_FILE"
    echo "Total Folders with No Poster Found: $total_no_poster" | tee -a "$LOG_FILE"
    
    if [ $total_failures -gt 0 ]; then
        echo "Failed folders:" | tee -a "$LOG_FILE"
        for folder in "${failed_folders[@]}"; do
            echo "$folder" | tee -a "$LOG_FILE"
        done
    fi
}

# Start the script
process_directories
