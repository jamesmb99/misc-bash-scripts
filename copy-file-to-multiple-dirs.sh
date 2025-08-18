#!/bin/bash

exec > log.txt 2>&1

parentDir="/databricks-workspaces/"
updateFile="update_terraform_module.sh"
precommitFile=".pre-commit-config.yaml"

count=0

for dir in ${parentDir}/*; do
  if [[ -d "$dir" && $(basename "$dir") == dbw-* ]]; then
    echo "${count} Copying files to $dir"
    cp ${updateFile} ${precommitFile} "$dir"
    ((count++))
  fi
done
