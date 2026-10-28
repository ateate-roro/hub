#!/bin/bash

# Fix GitHub Integration in Orca Session
# Run this script to ensure proper setup and refresh of GitHub credentials

echo "=== Fixing GitHub Integration ==="

# Verify Git configuration
echo "Checking Git configuration..."
git config --global user.name
git config --global user.email

# Test SSH connection to GitHub
echo "Testing SSH connection to GitHub..."
ssh -T git@github.com 2>&1 | head -n 1

# Refresh credential helper if needed
echo "Refreshing credentials setup..."
if [ -f "/home/svarog/.local/bin/gh-credential-helper" ]; then
    echo "Credential helper found. Ensuring proper Git configuration."
    git config --global credential.helper /home/svarog/.local/bin/gh-credential-helper
fi

# Verify remote is set correctly 
echo "Verifying remote URL..."
git remote -v

echo "=== GitHub Integration Status ==="
echo "If this shows your repository correctly and SSH works, integration is functional."
echo "If Orca still doesn't recognize it, try restarting Orca or refreshing session."