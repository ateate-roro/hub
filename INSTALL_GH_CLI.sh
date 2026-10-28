#!/bin/bash

# GitHub CLI Installation Script
# Run this script with sudo privileges when you have terminal access

echo "=== GitHub CLI Installation Script ==="
echo "This script will install the GitHub CLI (gh) for full Orca integration support."

# Check if running as root/sudo
if [[ $EUID -eq 0 ]]; then
    echo "Running as root - proceeding with installation..."
else
    echo "Error: This script must be run with sudo privileges"
    echo "Run with: sudo ./INSTALL_GH_CLI.sh"
    exit 1
fi

# Add GitHub's official GPG key
echo "Adding GitHub GPG key..."
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg

# Add GitHub's repository to APT sources
echo "Adding GitHub repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# Update package list
echo "Updating package list..."
apt update

# Install GitHub CLI
echo "Installing GitHub CLI..."
apt install gh -y

echo ""
echo "=== Installation Complete ==="
echo "GitHub CLI has been installed successfully."
echo ""
echo "To complete your integration setup:"
echo "1. Run: gh auth login --git-protocol ssh"
echo "2. Restart your Orca session"
echo "3. Your GitHub integrations should now be recognized as active"