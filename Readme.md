# tailscale_copy.command

## Overview

A shell script designed to easily copy folders from MacOS to a Windows machine over your Tailscale network. It automatically reconnects and retries if the transfer is interrupted, and sends notifications using [Pushover](https://pushover.net/) when the process completes or encounters an error.

---

## Features

- Drag-and-drop folder selection for MacOS
- Automatic reconnection and retry on failure
- Ignores `.DS_Store` files
- Sends Pushover notifications for success and error events
- Simple, interactive usage
- SSH key-based authentication (no passwords)

---

## Prerequisites

- **Tailscale** installed and configured on both MacOS and Windows machines
- **rsync** installed on MacOS
- [Pushover account](https://pushover.net/) and API credentials
- **SSH key pair** for authentication

---

## Windows Requirements

To receive folders from MacOS using this script, your Windows machine must:

1. **Have an SSH server installed and running**
   - The easiest way is to install the built-in OpenSSH Server:
     - Go to **Settings > Apps > Optional Features**
     - Click **Add a feature** and search for "OpenSSH Server"
     - Install it, then start the service:
       ```powershell
       Start-Service sshd
       Set-Service -Name sshd -StartupType 'Automatic'
       ```
     

2. **Have your Windows user account set up for SSH access**
   - The username should match the `DEST_USER` in the script.
   - You may need to set up SSH keys or allow password authentication.

3. **Have a writable destination folder**
   - The path set in `DEST_PATH` must exist and be writable by your Windows user.

---

## SSH Key Setup

### 1. Generate SSH Key Pair on MacOS

```bash
# Generate a new SSH key pair
ssh-keygen -t rsa -b 4096 -f ~/.ssh/winsshtailcopy -C "tailscale_copy_script"

# This creates:
# - ~/.ssh/winsshtailcopy (private key)
# - ~/.ssh/winsshtailcopy.pub (public key)
```

### 2. Copy Public Key to Windows

**Option A: Using ssh-copy-id (if available)**
```bash
ssh-copy-id -i ~/.ssh/winsshtailcopy.pub office@100.98.188.37
```

**Option B: Manual copy**
```bash
# Copy the public key content
cat ~/.ssh/winsshtailcopy.pub

# Then manually add it to Windows:
# 1. Open PowerShell as Administrator
# 2. Create the .ssh directory if it doesn't exist:
mkdir -p C:\Users\username\.ssh

# 3. Add the public key to authorized_keys:
echo "YOUR_PUBLIC_KEY_CONTENT_HERE" >> C:\Users\username\.ssh\authorized_keys
```

### 3. Test SSH Connection

```bash
# Test the connection (should work without password)
ssh -i ~/.ssh/winsshtailcopy username@100.xxx.xxxx.xxx
```

---

## Configuration

### First Run Setup

1. **Run the script for the first time:**
   ```bash
   ./tailscale_copy.command
   ```

2. **The script will automatically create `config.local.sh`** with default settings.

3. **Edit `config.local.sh` with your real data:**
   ```bash
   # Pushover (notifications)
   PUSHOVER_USER="your_real_pushover_user_key"
   PUSHOVER_TOKEN="your_real_pushover_api_token"
   
   # Destination (Windows machine via SSH)
   DEST_USER="your_windows_username"
   DEST_HOST="100.x.x.x"  # Your Windows machine's Tailscale IP
   DEST_PATH="/c/Tailscale"  # Your destination path on Windows
   SSH_KEY="~/.ssh/winsshtailcopy"  # Path to your SSH key
   ```

### Configuration Options

- **PUSHOVER_USER/PUSHOVER_TOKEN**: For notifications (optional - leave empty if not using)
- **DEST_USER**: Your Windows username
- **DEST_HOST**: Your Windows machine's Tailscale IP address
- **DEST_PATH**: Destination path on Windows (e.g., `/c/Tailscale`)
- **SSH_KEY**: Path to your SSH private key

---

## Usage

1. **Run the script**:  
   Double-click `tailscale_copy.command` or run it in Terminal:
   ```sh
   ./tailscale_copy.command
   ```

2. **Drag and Drop**:
    Drag a folder from Finder into the Terminal window and press Enter.

3. **Automatic Transfer**:
    The script will attempt to copy the folder using rsync over SSH. If the connection fails, it will retry every 30 seconds.

4. **Notifications**:
    Upon completion or error, you'll receive notifications via Pushover.

---

## Troubleshooting

### SSH Connection Issues

1. **Verify SSH server is running on Windows:**
   ```powershell
   Get-Service sshd
   ```

2. **Check SSH key permissions:**
   ```bash
   chmod 600 ~/.ssh/winsshtailcopy
   chmod 644 ~/.ssh/winsshtailcopy.pub
   ```

3. **Test SSH connection manually:**
   ```bash
   ssh -i ~/.ssh/winsshtailcopy username@100.xxx.xxx.xxx
   ```

### Permission Issues

1. **Ensure the destination folder exists and is writable**
2. **Check Windows user permissions**
3. **Verify SSH key is in the correct user's authorized_keys**
