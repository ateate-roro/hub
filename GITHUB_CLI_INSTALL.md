# Installing GitHub CLI for Orca Integration

## Problem Identified
Your Orca environment is missing the GitHub CLI (`gh`) which is required for full GitHub integration capabilities including:
- Pull requests
- Issues
- Checks
- Repository management

## Solution: Install GitHub CLI

Since you're on Ubuntu 26.04 LTS, run these commands:

```bash
# Add GitHub's official GPG key
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg

# Add GitHub's repository to APT sources
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# Update package list
sudo apt update

# Install GitHub CLI
sudo apt install gh -y
```

## Verify Installation
After installation, verify it works:
```bash
gh --version
gh auth status
```

## Complete Orca Integration Fix
Once installed:
1. Restart your Orca session
2. The GitHub integration should now be recognized as active
3. All GitHub features (pull requests, issues, checks) will become available

## For Orca-Specific Integration
If you're still seeing issues after installation, also run:
```bash
# Configure gh to work with your existing Git setup
gh auth login --with-token <your-github-token>
```

Note: Your SSH keys are already properly configured (as shown by ssh -T git@github.com working), so the CLI installation will make Orca recognize the full integration capability.