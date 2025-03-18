#!/bin/bash

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "kubectl is not installed. Please install it first."
    exit 1
fi

# Check if .env file exists
if [ ! -f .env ]; then
    echo ".env file not found!"
    exit 1
fi

# Create namespace if it doesn't exist
kubectl create namespace firecrawl 2>/dev/null || true

# Read .env file and create a temporary secrets file
echo "apiVersion: v1
kind: Secret
metadata:
  name: firecrawl-secrets
  namespace: firecrawl
type: Opaque
stringData:" > temp-secrets.yaml

# Add each environment variable to the secrets file
while IFS='=' read -r key value || [ -n "$key" ]; do
    # Skip comments and empty lines
    [[ $key =~ ^#.*$ ]] && continue
    [[ -z "$key" ]] && continue
    
    # Remove any quotes and leading/trailing whitespace from key and value
    key=$(echo "$key" | tr -d '"' | tr -d "'" | xargs)
    value=$(echo "$value" | tr -d '"' | tr -d "'" | xargs)
    
    # Add to secrets file
    echo "  $key: \"$value\"" >> temp-secrets.yaml
done < .env

# Apply the secrets
kubectl apply -f temp-secrets.yaml

# Clean up
rm temp-secrets.yaml

echo "Secrets have been created in the firecrawl namespace!" 