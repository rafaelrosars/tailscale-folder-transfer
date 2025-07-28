# tailscale_copy.command

## Overview

**tailscale_copy.command** is a shell script designed to easily copy folders from MacOS to a Windows machine over your Tailscale network. It automatically reconnects and retries if the transfer is interrupted, and sends notifications using [Pushover](https://pushover.net/) when the process completes or encounters an error.

---

## Features

- Drag-and-drop folder selection for MacOS
- Automatic reconnection and retry on failure
- Ignores `.DS_Store` files
- Sends Pushover notifications for success and error events
- Simple, interactive usage
- **NEW**: Local configuration file support for privacy

---

## Prerequisites

- **Tailscale** installed and configured on both MacOS and Windows machines
- **rsync** installed on MacOS
- **curl** installed (usually available by default on MacOS)
- [Pushover account](https://pushover.net/) and API credentials

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
     - Make sure your Windows firewall allows inbound connections to port **22**.

2. **Have your Windows user account set up for SSH access**
   - The username should match the `DEST_USER` in the script.
   - You may need to set up SSH keys or allow password authentication.

3. **Have a writable destination folder**
   - The path set in `DEST_PATH` must exist and be writable by your Windows user.

---

## Configuration

### Option 1: Local Configuration File (Recommended)

1. **Create your local configuration:**
   ```bash
   cp config.example.sh config.local.sh
   ```

2. **Edit `config.local.sh` with your real data:**
   ```bash
   PUSHOVER_USER="your_real_pushover_user_key"
   PUSHOVER_TOKEN="your_real_pushover_api_token"
   DEST_USER="your_windows_username"
   DEST_IP="100.x.x.x"  # Your Windows machine's Tailscale IP
   DEST_PATH="/c/Tailscale"  # Your destination path
   ```

3. **The `config.local.sh` file is ignored by Git** (see `.gitignore`), so your personal data won't be shared publicly.

### Option 2: Direct Script Editing

Edit the variables directly in `tailscale_copy.command` (not recommended for public repositories).

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
    The script will attempt to copy the folder using rsync. If the connection fails, it will retry every 30 seconds.

4. **Notifications**:
    Upon completion or error, you'll receive notifications via Pushover.

---

## Example Configuration

```bash
PUSHOVER_USER="your_pushover_user_key"
PUSHOVER_TOKEN="your_pushover_api_token"
DEST_USER="windows_username"
DEST_IP="100.x.x.x"
DEST_PATH="/c/Tailscale"
```

---

## Privacy & Security

- The `config.local.sh` file contains your personal data and is **NOT** committed to Git
- Your real API keys and IP addresses remain private
- The public repository only contains example/template configurations
- Any improvements you make to the script locally can be safely pushed to the public repository
