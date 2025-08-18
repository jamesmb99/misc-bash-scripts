#!/usr/bin/env bash
set -e

MODULE_URL="git@github.com:JH-HIT-DataPlatform/terraform-databricks-package.git"
LATEST_TAG=$(git ls-remote --tags ${MODULE_URL} | awk -F'/' '{print $NF}' | sort -V | tail -n1)

# check $LATEST_TAG is not empty
if [ -z "$LATEST_TAG" ]; then
    echo "Failed to fetch the latest tag."
    exit 1
fi

echo "Latest tag found:  $LATEST_TAG"

# Search and Extract $CURRENT_TAG (vX.Y.Z) from .tf files.
#grep -o "git@github.com:JH-HIT-DataPlatform/terraform-databricks-package.git//[^?]*\?ref=[^ ]*" *.tf */*.tf
CURRENT_TAG=$(grep -o "${MODULE_URL}//[^?]*?ref=[^ ]*" *.tf */*.tf 2>/dev/null | head -n 1 | sed -E 's/.*ref=([^"]+).*/\1/')
echo current tag found: ${CURRENT_TAG}

# Check if $CURRENT_TAG is not empty
if [ -z "${CURRENT_TAG}" ]; then
    echo "Failed to fetch the current tag."
    exit 1
fi

# Checks if $CURRENT_TAG matches the $LATEST_TAG
# if its a match, exit with a status code of 0.
if [[ "${CURRENT_TAG}" == "${LATEST_TAG}" ]]; then
    echo "Current version ($CURRENT_TAG) is already the latest or newer. No update needed."
    exit 0
fi

# Loop through all Terraform files and update the module version
for FILE in $(git ls-files "*.tf"); do
    if [ -f "$FILE" ]; then
        echo "Updating $FILE..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s|${CURRENT_TAG}|${LATEST_TAG}|g" "$FILE"
        else
            sed -i "s|${CURRENT_TAG}|${LATEST_TAG}|g" "$FILE"
        fi
    fi
done

echo "Updated Terraform module to the latest version: ${LATEST_TAG}"
