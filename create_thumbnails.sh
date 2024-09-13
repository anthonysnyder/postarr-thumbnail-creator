#!/bin/bash

# Specify the directories to monitor
DIRECTORIES=(
    "XX_PLACEHOLDER_DIR_XX"
)

# Variables to track results
total_created=0
total_failures=0
total_no_poster=0
total_thumbnail_exists=0
failed_folders=()

# Function to log messages
log() {
    local message="$1"
    echo "$message"
    echo "$message" >> thumbnail_creation.log
}

# Function to process files in a directory
process_folder() {
    local folder="$1"
    
    # Ignore @eaDir and any hidden folders
    if [[ "$folder" == *"/@eaDir"* || "$folder" == */.* ]]; then
        return
    fi

    log "Processing folder: $folder"

    # Check if the folder has a poster (jpg, jpeg, or png)
    poster_file=""
    for ext in jpg jpeg png; do
        if [[ -f "$folder/poster.$ext" ]]; then
            poster_file="$folder/poster.$ext"
            break
        fi
    done

    if [[ -n "$poster_file" ]]; then
        # Check if thumbnail already exists
        if [[ -f "$folder/poster-thumb.jpg" ]]; then
            log "Thumbnail already exists, skipping folder: $folder"
            total_thumbnail_exists=$((total_thumbnail_exists + 1))
        else
            # Try to create a thumbnail
            convert "$poster_file" -resize 300x450 "$folder/poster-thumb.jpg"
            if [[ $? -eq 0 ]]; then
                log "Thumbnail created successfully: $folder/poster-thumb.jpg"
                total_created=$((total_created + 1))
            else
                log "Failed to create thumbnail for: $folder"
                total_failures=$((total_failures + 1))
                failed_folders+=("$folder")
            fi
        fi
    else
        log "No poster file found in folder: $folder"
        total_no_poster=$((total_no_poster + 1))
    fi
}

# Loop through each directory and its first-level subdirectories
for dir in "${DIRECTORIES[@]}"; do
    find "$dir" -mindepth 1 -maxdepth 1 -type d | while read -r folder; do
        process_folder "$folder"
    done
done

# Summary of results
log "Summary:"
log "Total Thumbnails Created: $total_created"
log "Total Thumbnails Present: $total_thumbnail_exists"
log "Total Folders with Failures: $total_failures"
log "Total Folders with No Poster Found: $total_no_poster"

if [[ $total_failures -gt 0 ]]; then
    log "Failed folders:"
    for folder in "${failed_folders[@]}"; do
        log "$folder"
    done
fi
