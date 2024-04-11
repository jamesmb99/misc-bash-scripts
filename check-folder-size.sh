#!/bin/bash

get_folder_size() {
    du -sb "$1"
}

# Function to get the size of a folder in GB
get_folder_size_gb() {
    du -sb "$1" | awk '{ printf "%.2f", $1 / (1024*1024*1024) }'
}

check_folder_sizes_to_csv() {
    echo "Folder,Size (GB),Size,Original Path"
    for folder in "${folders[@]}"; do
        folder_path="/fileservices/persistent/${folder}/persistent"
        if [ -d "$folder_path" ]; then
            folder_size_gb=$(get_folder_size_gb "$folder_path" | awk '{ print $1 }')
            folder_size=$(get_folder_size "$folder_path" | awk '{ print $1 }')
            echo "${folder},${folder_size_gb},${folder_size},${folder_path}"
        else
            echo "${folder}, Folder not found"
        fi
    done
}

# List of folders
folders=(
'a'
'b'
'c'
'd'
'e'
'f'
)

# Main execution: Output to CSV file
check_folder_sizes_to_csv > folder_sizes.csv
