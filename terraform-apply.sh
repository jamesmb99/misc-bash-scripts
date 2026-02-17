#!/bin/bash

set -euo pipefail

# List of folders to update
REPO_LIST="dbw-tf-repos.txt"
GIT_MESSAGE="Adding DLT compute"

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

  REPO_PATH_DIR="$BASE_DIR/$folder"

  # Ensure folder exists
  if [ ! -d "$REPO_PATH_DIR" ]; then
      echo "Folder $folder does not exist"
      exit 1
  fi

  cd "$REPO_PATH_DIR"

  # Ensure it's a git repo
  if [ ! -d ".git" ]; then
      echo "$folder is not a git repository"
      exit 1
  fi

  echo "Pulling latest changes from Git..."
  git pull

  echo "Initializing Terraform..."
  terraform init -upgrade

  echo "Applying Terraform changes..."
  terraform apply

  echo "Committing and pushing changes..."
  git add -A

  # Only commit if there are changes
  if ! git diff --cached --quiet; then
      git commit -m "${GIT_MESSAGE}" --no-verify
      git push
  else
      echo "No changes to commit in $folder"
  fi

  cd "$BASE_DIR"
done

echo "All Terraform folders processed successfully"
