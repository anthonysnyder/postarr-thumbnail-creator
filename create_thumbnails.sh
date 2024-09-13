#!/bin/bash

# Specify the directories to monitor
DIRECTORIES=(
    "XX_PLACEHOLDER_DIR_XX"
)

# Initialize counters for summary
success_count=0
poster_not_found_count=0
failure_count=0

# Initialize arrays to store the results
thumbnails_created=()
no_poster_found=()
failures=()

# Function to create thumbnail
create_thumbnail() {
    local poster_path="$1"
    local thumb_path="$2"
    
    # Check if Pillow is available
    if ! command -v convert &> /dev/null; then
        echo "Pillow (ImageMagick) is not installed. Install it to use this script."
        exit 1
    fi
    
    # Create the thumbnail
    convert "$poster_path" -resize 300x450 "$thumb_path"
}

# Function to process each movie folder
process_folder() {
    local folder="$1"
    local poster_path=""
    local thumb_path=""

    # Look for poster.jpg, poster.jpeg, or poster.png (case-insensitive)
    for ext in jpg jpeg png; do
        if [ -f "$folder/poster.$ext" ]; then
            poster_path="$folder/poster.$ext"
            thumb_path="$folder/poster-thumb.jpg"
            break
        fi
    done

    if [ -n "$poster_path" ]; then
        if [ ! -f "$thumb_path" ]; then
            # Try to create a thumbnail
            if create_thumbnail "$poster_path" "$thumb_path"; then
                echo "Thumbnail created successfully: $thumb_path"
                thumbnails_created+=("$thumb_path")
                success_count=$((success_count + 1))
            else
                echo "Failed to create thumbnail for: $folder"
                failures+=("$folder")
                failure_count=$((failure_count + 1))
            fi
        fi
    else
        echo "No poster file found in folder: $folder"
        no_poster_found+=("$folder")
        poster_not_found_count=$((poster_not_found_count + 1))
    fi
}

# Loop through directories and their movie folders (only first level of subdirectories)
for dir in "${DIRECTORIES[@]}"; do
    find "$dir" -mindepth 1 -maxdepth 1 -type d | while read -r folder; do
        process_folder "$folder"
    done
done

# Final output report
echo -e "\nFinal Report:\n"

echo "Thumbnails Created:"
if [ ${#thumbnails_created[@]} -eq 0 ]; then
    echo "None"
else
    for thumb in "${thumbnails_created[@]}"; do
        echo "$thumb"
    done
fi

echo -e "\nNo Poster Found:"
if [ ${#no_poster_found[@]} -eq 0 ]; then
    echo "None"
else
    for folder in "${no_poster_found[@]}"; do
        echo "$folder"
    done
fi

echo -e "\nFailures:"
if [ ${#failures[@]} -eq 0 ]; then
    echo "None"
else
    for failure in "${failures[@]}"; do
        echo "$failure"
    done
fi
