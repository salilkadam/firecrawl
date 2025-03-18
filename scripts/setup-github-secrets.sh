#!/bin/bash

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) is not installed. Please install it first:"
    echo "https://cli.github.com/"
    exit 1
fi

# Check if logged in to GitHub
if ! gh auth status &> /dev/null; then
    echo "Please login to GitHub first using: gh auth login"
    exit 1
fi

# Read .env file
if [ ! -f .env ]; then
    echo ".env file not found!"
    exit 1
fi

# Function to set a secret
set_secret() {
    local secret_name=$1
    local secret_value=$2
    echo "Setting $secret_name..."
    echo "$secret_value" | gh secret set "$secret_name"
}

# Set Docker Hub credentials
read -p "Enter Docker Hub username: " DOCKERHUB_USERNAME
read -s -p "Enter Docker Hub token: " DOCKERHUB_TOKEN
echo

set_secret "DOCKERHUB_USERNAME" "$DOCKERHUB_USERNAME"
set_secret "DOCKERHUB_TOKEN" "$DOCKERHUB_TOKEN"

# Read and set secrets from .env file
while IFS='=' read -r key value || [ -n "$key" ]; do
    # Skip comments and empty lines
    [[ $key =~ ^#.*$ ]] && continue
    [[ -z "$key" ]] && continue
    
    # Remove any quotes from the value
    value=$(echo "$value" | tr -d '"' | tr -d "'")
    
    # Convert to uppercase and replace special characters
    secret_name=$(echo "$key" | tr '[:lower:]' '[:upper:]' | tr '.' '_')
    
    set_secret "$secret_name" "$value"
done < .env

echo "All secrets have been set successfully!" 