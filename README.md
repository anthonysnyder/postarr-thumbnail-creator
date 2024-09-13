# Poster Thumbnail Generator Script

This script recursively searches through specified directories for movie folders. Inside each movie folder, it checks if there is an existing `poster.ext` file (where `ext` can be `jpg`, `jpeg`, or `png`). If found, the script generates a `poster-thumb.ext` with a resolution of 300x450 from the original `poster.ext`.

## Usage

1. **Update Directories**: Replace the `XX_PLACEHOLDER_DIR_XX` in the script with the directories you want to search through.
2. **Run the Script**: Run the script from the command line on your Synology or Linux-based machine with the necessary permissions.
3. **Output**: The script will provide a verbose output of its progress, including the number of successful thumbnail creations and any failed folders.

## Requirements: 
1. Ensure the script has the proper permissions
2. ImageMagick or PIL
3. 
## Script Breakdown

- **Directories**: 
    - You will need to specify the directories where the movie folders are stored.
    - Example:
    ```bash
    DIRECTORIES=(
        "/path/to/first/movies"
        "/path/to/second/movies"
    )
    ```

- **Processing**: 
    - The script recursively searches through each directory.
    - For each movie folder, it checks for the existence of a `poster.ext` file.
    - If a `poster.ext` file is found, it generates a `poster-thumb.ext` with the specified resolution.

- **Logging**:
    - For every successful `poster-thumb.ext` creation, a message will be logged in the terminal.
    - Any errors or failures (such as missing `poster.ext` files) will also be logged.

- **Final Output**:
    - At the end of the script execution, it provides a summary of the total number of successes and a list of failed folders.

## Example

```bash
bash generate_poster_thumbs.sh
Processed: /path/to/movies/Inception (2010)
Thumbnail created successfully: /path/to/movies/Inception (2010)/poster-thumb.jpg
Processed: /path/to/movies/Avatar (2009)
Thumbnail created successfully: /path/to/movies/Avatar (2009)/poster-thumb.jpg
Processed: /path/to/movies/The Matrix (1999)
Thumbnail created successfully: /path/to/movies/The Matrix (1999)/poster-thumb.jpg
...
Successes: 45
Failures: /path/to/movies/FoldersWithoutPosters```


