#!/bin/bash

# Configuration
DIRECTORY="$1"
SLEEP_INTERVAL=20  # Sleep interval in seconds
LOG_FILE="../terraform_automation.log"

# Function to log messages with timestamp
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to run the terraform automation workflow
run_terraform_workflow() {
    log_message "Starting Terraform automation workflow..."
    
    # Change to target directory
    if ! cd "$DIRECTORY"; then
        log_message "ERROR: Failed to change to directory: $DIRECTORY"
        return 1
    fi
    
    # Git init
    log_message "Initializing git repository..."
    git init || { log_message "ERROR: Git init failed"; return 1; }

     # Git pull
    log_message "Pulling latest changes..."
    git pull || log_message "WARNING: Git pull failed or no remote configured"

    # First pre-commit run
    log_message "Running pre-commit (first pass)..."
    pre-commit run --all-files || log_message "WARNING: pre-commit failed"
    
    # First terraform init upgrade
    log_message "Running initial terraform init..."
    terraform init -upgrade || { log_message "ERROR: Initial terraform init failed"; return 1; }
    
    # Terraform apply
    log_message "Running terraform apply..."
    terraform apply || { log_message "ERROR: Terraform apply failed"; return 1; }
    
    # Git operations
    log_message "Adding terraform lock file..."
    git add .terraform.lock.hcl || log_message "WARNING: Failed to add .terraform.lock.hcl"
    
    log_message "Adding all files..."
    git add . || log_message "WARNING: Git add failed"

    log_message "Current git status:"
    git status

    log_message "Committing changes..."
    git commit -m "Upgrading providers and re-configuring serverless budget policy" || log_message "WARNING: Git commit failed (maybe no changes)"
    
    log_message "Adding all files..."
    git add . || log_message "WARNING: Git add failed"

    log_message "Committing changes..."
    git commit -m "Upgrading providers and re-configuring serverless budget policy" || log_message "WARNING: Git commit failed (maybe no changes)"

    log_message "Pushing changes..."
    git push || log_message "WARNING: First git push failed"
    
    git pull || log_message "WARNING: Git pull after push failed"
    git push || log_message "WARNING: Second git push failed"
    
    log_message "Final git status:"
    git status
    
    log_message "Running terraform plan..."
    terraform plan || log_message "WARNING: Terraform plan failed"
    
    log_message "Terraform automation workflow completed successfully!"
    return 0
}

# Main continuous loop
main() {
    # Validate input
    if [ -z "$DIRECTORY" ]; then
        echo "Usage: $0 <directory>"
        echo "Example: $0 /path/to/terraform/project"
        exit 1
    fi
    
    if [ ! -d "$DIRECTORY" ]; then
        log_message "ERROR: Directory does not exist: $DIRECTORY"
        exit 1
    fi
    
    log_message "Starting continuous Terraform automation for directory: $DIRECTORY"
    log_message "Sleep interval between runs: $SLEEP_INTERVAL seconds"
    log_message "Press Ctrl+C to stop..."
    
    # Trap Ctrl+C to exit gracefully
    trap 'log_message "Received interrupt signal. Exiting..."; exit 0' INT TERM
    
    # Continuous loop
    while true; do
        if run_terraform_workflow; then
            log_message "Workflow completed successfully. Waiting $SLEEP_INTERVAL seconds before next run..."
        else
            log_message "Workflow failed. Waiting $SLEEP_INTERVAL seconds before retry..."
        fi
        sleep "$SLEEP_INTERVAL"
    done
}

# Run the main function
main "$@"
