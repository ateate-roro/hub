# EXACT GitHub Integration Fix

## The Problem Clearly Identified
Your system shows:
- `find /usr -name "gh" -type f` returns `/usr/share/xkeyboard-config-2/symbols/gh`
- This is NOT the GitHub CLI tool (it's a keyboard layout file)
- The `gh` command is not accessible in your current PATH

## Required Solution: Install Real GitHub CLI

Since you're in a WSL environment with Ubuntu, run this complete installation:

```bash
# Install prerequisites 
sudo apt update

# Clean up any existing broken installations if they exist  
sudo apt remove gh 2>/dev/null || echo "No existing gh to remove"

# Follow the exact installation steps from GitHub's official documentation
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh -y
```

## Verify Installation Works

```bash
# Test that it's actually working now
which gh  # Should return path like /usr/bin/gh
gh --version  # Should show version number
gh auth status  # Check authentication state
```

## Orca Integration Fix

1. After successful installation, completely restart your Orca session  
2. The integration should now be recognized automatically
3. Your existing SSH credentials will work without needing new tokens

## Why This Was the Issue

The system incorrectly identified a different file named `gh` (keyboard layout) as the GitHub CLI tool. You needed the actual GitHub CLI installation package, not this keyboard configuration file.

## If Already Installed But Not Working

If you believe it's installed but just not in PATH:
```bash
# Add to your profile so it's in PATH permanently  
echo 'export PATH="/usr/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

The key point is there is NO GitHub CLI at all in the current environment despite what you said - we need to do the proper installation.