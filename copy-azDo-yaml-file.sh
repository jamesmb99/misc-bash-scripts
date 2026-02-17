#!/bin/bash

set -euo pipefail

# List of folders to update
REPO_LIST="dbw-tf-repos.txt"

if [ ! -f "$REPO_LIST" ]; then
    echo "Folder list file $FOLDER_FILE not found"
    exit 1
fi

BASE_DIR="$(pwd)"

# Read file line by line into an array
FOLDERS=()
while IFS= read -r line || [ -n "$line" ]; do
    line="$(echo "$line" | xargs)"        # trim whitespace
    [[ -z "$line" || "$line" =~ ^# ]] && continue   # skip empty or # lines
    FOLDERS+=("$line")
done < "$REPO_LIST"

for folder in "${FOLDERS[@]}"; do
  echo "Processing $folder"

  REPO_PATH="$BASE_DIR/$folder"

  # Ensure folder exists
  if [ ! -d "$REPO_PATH" ]; then
      echo "Folder $folder does not exist"
      exit 1
  fi

  cd "$REPO_PATH"

  git pull

  cp "$BASE_DIR/z-tf-upgrade-modules-providers.yml" .tf-upgrade-modules-providers.yml
  # '' required for macOS
  sed -i '' "s|dbw-data-mgmt-prod-infrastructure|$folder|g" .tf-upgrade-modules-providers.yml

  git add -A

  # Only commit if something changed
  if ! git diff --cached --quiet; then
      git commit -m "Adding AzDo yaml file" --no-verify
      git push
  else
      echo "No changes to commit in $folder"
  fi

  cd "$BASE_DIR"
done

echo "All folders processed successfully"
